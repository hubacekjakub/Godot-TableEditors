@tool
extends VBoxContainer

## Class Table Dock UI Controller - Plugin 2: GDScript Class Integration

const CLASS_SELECTION_SCENE := preload("res://addons/class_table_editor/ui/class_selection_dialog.tscn")
const TYPED_CELL_EDITOR_FACTORY := preload("res://addons/class_table_editor/utils/typed_cell_editor_factory.gd")
const GRID_BUILDER := preload("res://addons/class_table_editor/utils/grid_builder.gd")
const CELL_MANAGER := preload("res://addons/class_table_editor/editors/cell_manager.gd")

signal column_added
signal row_added
signal column_deleted(col: int)
signal row_deleted(row: int)
signal column_renamed(col: int, new_name: String)
signal row_renamed(row: int, new_name: String)
signal data_cleared
signal save_requested
signal load_requested
signal close_requested
signal new_sheet_requested
signal sheet_selected(path: String)
signal create_table_requested(table_name: String, file_name: String, rows: int, columns: int, save_path: String)

# UI References (automatically connected from scene)
@onready var file_menu: MenuButton = %FileMenu
@onready var edit_menu: MenuButton = %EditMenu
@onready var add_row_btn: Button = %AddRowBtn
@onready var columns_label: Label = %ColumnsLabel
@onready var rows_label: Label = %RowsLabel
@onready var recent_sheets_list: ItemList = %RecentSheetsList
@onready var grid_container: GridContainer = %GridContainer

var class_select_dialog: ConfirmationDialog = null  # Lazy instantiated in _show_class_select_dialog()
var editor_interface: EditorInterface = null  # Reference to editor interface

var current_sheet: Resource = null
var recent_sheets: Array[String] = []  # Store recent sheet paths
const MAX_RECENT_SHEETS := 10

var editor_settings: EditorSettings

# Grid management components
var grid_builder: GridBuilder
var cell_manager: CellManager


func _ready() -> void:
	if editor_interface:
		editor_settings = editor_interface.get_editor_settings()
		if editor_settings.has_setting("class_table_editor/recent_tables"):
			var loaded = editor_settings.get_setting("class_table_editor/recent_tables")
			if loaded is Array:
				recent_sheets = loaded as Array[String]

		# Validate recent sheets - remove any that don't exist
		var valid_sheets: Array[String] = []
		for path in recent_sheets:
			if FileAccess.file_exists(path):
				valid_sheets.append(path)
		recent_sheets = valid_sheets

		if recent_sheets.size() > MAX_RECENT_SHEETS:
			recent_sheets = recent_sheets.slice(-MAX_RECENT_SHEETS)

	_setup_menus()
	_connect_signals()
	_update_recent_sheets_list()

	# Initialize grid management components
	grid_builder = GRID_BUILDER.new(grid_container, CELL_MANAGER.new(self))

	# Connect GridBuilder signals
	grid_builder.column_renamed.connect(_on_column_renamed)
	grid_builder.column_header_focus_exited.connect(_on_column_header_focus_exited)
	grid_builder.column_header_gui_input.connect(_on_column_header_gui_input)

	# Connect CellManager signals
	grid_builder.cell_manager.typed_cell_changed.connect(_on_typed_cell_changed)
	grid_builder.cell_manager.typed_cell_submitted.connect(_on_typed_cell_submitted)
	grid_builder.cell_manager.cell_focus_entered.connect(_on_cell_focus_entered)
	grid_builder.cell_manager.cell_gui_input.connect(_on_cell_gui_input)


func _exit_tree() -> void:
	"""Clean up resources to prevent memory leaks"""
	# Clean up dialogs
	if class_select_dialog and is_instance_valid(class_select_dialog):
		class_select_dialog.queue_free()
		class_select_dialog = null


func _setup_menus() -> void:
	# Setup File menu
	var file_popup := file_menu.get_popup()
	file_popup.clear()
	file_popup.add_item("New", 0)
	file_popup.add_item("Load", 1)
	file_popup.add_item("Save", 2)
	file_popup.add_separator()
	file_popup.add_item("Close", 3)
	file_popup.id_pressed.connect(_on_file_menu_pressed)

	# Setup Edit menu
	var edit_popup := edit_menu.get_popup()
	edit_popup.clear()
	edit_popup.add_item("Add Row", 0)
	edit_popup.add_separator()
	edit_popup.add_item("Clear All", 1)
	edit_popup.id_pressed.connect(_on_edit_menu_pressed)


func _connect_signals() -> void:
	add_row_btn.pressed.connect(_on_add_row_pressed)
	recent_sheets_list.item_selected.connect(_on_recent_sheet_selected)


func _get_sheet() -> ClassTableResource:
	if current_sheet is ClassTableResource:
		return current_sheet as ClassTableResource
	return null


func set_sheet(sheet: Resource) -> void:
	## Set the current sheet and update the UI.
	current_sheet = sheet
	if sheet and sheet.resource_path:
		add_to_recent_sheets(sheet.resource_path)
	grid_builder.set_sheet(_get_sheet())
	update_ui()


func update_ui() -> void:
	## Update the UI to reflect the current sheet data.
	var sheet := _get_sheet()
	if not sheet:
		columns_label.text = "Columns: 0"
		rows_label.text = "Rows: 0"
		grid_builder.rebuild_grid()
		_update_recent_sheets_list()
		return

	columns_label.text = "Columns: %d" % sheet.column_count
	rows_label.text = "Rows: %d" % sheet.row_count
	grid_builder.rebuild_grid()
	_update_recent_sheets_list()

func _on_cell_focus_entered(row: int, col: int, cell: Control) -> void:
	## Track focused cell and select all text for easy editing.
	# Only select all text for LineEdit controls
	if cell is LineEdit:
		cell.select_all()


func _on_cell_gui_input(event: InputEvent, row: int, col: int) -> void:
	## Handle keyboard navigation in cells.
	if event is InputEventKey and event.pressed and not event.echo:
		match event.keycode:
			KEY_UP:
				if event.ctrl_pressed:
					_move_to_cell(row - 1, col)
					get_viewport().set_input_as_handled()
			KEY_DOWN:
				if event.ctrl_pressed:
					_move_to_cell(row + 1, col)
					get_viewport().set_input_as_handled()
			KEY_LEFT:
				if event.ctrl_pressed:
					_move_to_cell(row, col - 1)
					get_viewport().set_input_as_handled()
			KEY_RIGHT:
				if event.ctrl_pressed:
					_move_to_cell(row, col + 1)
					get_viewport().set_input_as_handled()
			KEY_TAB:
				if event.shift_pressed:
					_move_to_cell(row, col - 1)
				else:
					_move_to_cell(row, col + 1)
				get_viewport().set_input_as_handled()


func _move_to_cell(target_row: int, target_col: int) -> void:
	## Move focus to a specific cell when it exists.
	var sheet := _get_sheet()
	if not sheet:
		return

	# Validate target position
	if target_row < 0 or target_row >= sheet.row_count:
		return
	if target_col < 0 or target_col >= sheet.column_count:
		return

	# Calculate cell index in grid layout
	# Grid: [col headers...] [row1 cells...] [row2 cells...]
	var cell_index := sheet.column_count + (target_row * sheet.column_count) + target_col

	var children := grid_container.get_children()
	if cell_index >= 0 and cell_index < children.size():
		var target_cell := children[cell_index]
		if target_cell is LineEdit:
			target_cell.grab_focus()


func _on_file_menu_pressed(id: int) -> void:
	match id:
		0:  # New
			_show_class_select_dialog()
		1:  # Load
			load_requested.emit()
		2:  # Save
			save_requested.emit()
		3:  # Close
			close_requested.emit()


func _on_edit_menu_pressed(id: int) -> void:
	match id:
		0:  # Add Row
			_on_add_row_pressed()
		1:  # Clear All
			data_cleared.emit()


func _on_add_row_pressed() -> void:
	row_added.emit()



## Forward column rename notifications.
func _on_column_renamed(new_name: String, col: int) -> void:
	column_renamed.emit(col, new_name)


## Save column name when header loses focus.
func _on_column_header_focus_exited(col: int, header_edit: LineEdit) -> void:
	var new_name := header_edit.text
	var sheet := _get_sheet()
	if not sheet:
		return

	if new_name != sheet.get_column_name(col):
		column_renamed.emit(col, new_name)


## Handle column header input - disabled since columns cannot be added.
func _on_column_header_gui_input(event: InputEvent, col: int) -> void:
	# Column operations disabled
	pass


func _on_row_renamed(new_name: String, row: int) -> void:
	## Forward row rename notifications.
	row_renamed.emit(row, new_name)


func _on_row_header_focus_exited(row: int, header_edit: LineEdit) -> void:
	## Save row name when header loses focus.
	var new_name := header_edit.text
	var sheet := _get_sheet()
	if not sheet:
		return

	if new_name != sheet.get_row_name(row):
		row_renamed.emit(row, new_name)


func _on_row_header_gui_input(event: InputEvent, row: int) -> void:
	## Show context menu on right-click for row operations.
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_show_row_context_menu(row, event.global_position)
			get_viewport().set_input_as_handled()


## Display context menu for row operations.
func _show_row_context_menu(row: int, position: Vector2) -> void:
	var popup := PopupMenu.new()
	popup.add_item("Delete Row", 0)
	popup.id_pressed.connect(func(id):
		if id == 0:
			row_deleted.emit(row)
		popup.queue_free()
	)
	add_child(popup)
	popup.popup(Rect2i(position, Vector2i(150, 50)))


## Add a sheet path to the recent sheets list.
func add_to_recent_sheets(path: String) -> void:
	if path.is_empty():
		return

	# Only add if not already in the list (don't reorder existing items)
	if not path in recent_sheets:
		recent_sheets.append(path)

		if recent_sheets.size() > MAX_RECENT_SHEETS:
			recent_sheets.pop_front()

	_update_recent_sheets_list()

	# Save to settings
	if editor_settings:
		editor_settings.set_setting("class_table_editor/recent_tables", recent_sheets)


## Set the entire recent sheets list (for loading from settings).
func set_recent_sheets(sheets: Array[String]) -> void:
	recent_sheets = sheets.duplicate()
	if recent_sheets.size() > MAX_RECENT_SHEETS:
		recent_sheets = recent_sheets.slice(-MAX_RECENT_SHEETS)
	_update_recent_sheets_list()

	# Save to settings
	if editor_settings:
		editor_settings.set_setting("class_table_editor/recent_tables", recent_sheets)


## Update the ItemList display with recent sheets.
func _update_recent_sheets_list() -> void:
	recent_sheets_list.clear()

	for i in range(recent_sheets.size()):
		var path := recent_sheets[i]
		var file_name := path.get_file()
		recent_sheets_list.add_item(file_name)
		recent_sheets_list.set_item_tooltip(i, path)

		# Highlight the currently active sheet
		if current_sheet and current_sheet.resource_path == path:
			recent_sheets_list.set_item_custom_bg_color(i, Color(0.3, 0.5, 0.7, 0.3))  # Light blue highlight
			recent_sheets_list.set_item_custom_fg_color(i, Color(1, 1, 1, 1))  # White text for contrast


## Handle selection of a recent sheet from the list.
func _on_recent_sheet_selected(index: int) -> void:
	if index >= 0 and index < recent_sheets.size():
		var path := recent_sheets[index]
		if FileAccess.file_exists(path):
			sheet_selected.emit(path)
		else:
			# Remove invalid path from recent sheets
			recent_sheets.remove_at(index)
			_update_recent_sheets_list()
			if editor_settings:
				editor_settings.set_setting("class_table_editor/recent_tables", recent_sheets)


## Show the Class Selection dialog.
func _show_class_select_dialog() -> void:
	# Instantiate new class selection dialog if it doesn't exist
	if not class_select_dialog:
		class_select_dialog = CLASS_SELECTION_SCENE.instantiate()

		# Connect signals from the new dialog
		class_select_dialog.table_created.connect(_on_class_table_created)

		# Add as child of the dock to ensure proper modal behavior
		add_child(class_select_dialog)

	# Reset and show the dialog
	class_select_dialog.reset_to_defaults()
	class_select_dialog.popup_centered()
	class_select_dialog.grab_focus()


## Handle class table creation from class selection dialog.
func _on_class_table_created(resource_path: String, class_info: Dictionary) -> void:
	if OS.is_debug_build():
		print("Class table created: %s" % resource_path)
		print("  From class: %s" % class_info.get("class_name", ""))

	# Load and display the newly created table
	var table_resource = load(resource_path) as ClassTableResource
	if table_resource:
		set_sheet(table_resource)
		if OS.is_debug_build():
			print("Table loaded and displayed in dock")

		# IMPORTANT: Make the plugin aware of this resource by editing it
		# This will trigger the plugin's _edit() method which sets current_sheet
		if editor_interface:
			editor_interface.edit_resource(table_resource)
			if OS.is_debug_build():
				print("Resource registered with editor")
		else:
			push_warning("Editor interface not available - plugin may not be aware of new table")


## === NEW: Type-Safe Editing Methods ===


## Handle cell value changes with type validation.
func _on_typed_cell_changed(new_value: Variant, row: int, col: int, editor: Control) -> void:
	var sheet := _get_sheet()
	if not sheet:
		return

	var type_id = editor.get_meta("type_id", TYPE_NIL)

	# Get value from editor
	var value = TYPED_CELL_EDITOR_FACTORY.get_editor_value(editor)

	# Validate value
	var validation = TYPED_CELL_EDITOR_FACTORY.validate_value(type_id, value)
	if not validation["valid"]:
		# Show validation error
		_show_validation_error(editor, validation["error"])
		return

	# Clear any previous validation error display
	_clear_validation_error(editor)

	# Convert value to string for storage
	var value_str = _value_to_string(value, type_id)
	sheet.set_cell(row, col, value_str)


## Handle cell submission (Enter key)
func _on_typed_cell_submitted(new_value: Variant, row: int, col: int, editor: Control) -> void:
	## Move to next row when Enter is pressed.
	_move_to_cell(row + 1, col)


## Show validation error in UI
func _show_validation_error(editor: Control, error_message: String) -> void:
	## Display validation error for a cell editor.
	# Add error border styling
	if editor is LineEdit:
		var error_style := StyleBoxFlat.new()
		error_style.bg_color = Color(0.4, 0.2, 0.2, 1)  # Red tint
		error_style.border_width_left = 2
		error_style.border_width_right = 2
		error_style.border_width_top = 2
		error_style.border_width_bottom = 2
		error_style.border_color = Color(1.0, 0.3, 0.3, 1)  # Bright red border
		editor.add_theme_stylebox_override("normal", error_style)

	# Set tooltip with error message
	editor.tooltip_text = "Error: " + error_message

	# TODO: Could show error panel at bottom of dock in future


## Clear validation error display.
func _clear_validation_error(editor: Control) -> void:
	if editor is LineEdit:
		# Restore normal styling
		var row = editor.get_meta("row", 0)
		var cell_style := StyleBoxFlat.new()
		if row % 2 == 0:
			cell_style.bg_color = Color(0.24, 0.24, 0.24, 1)
		else:
			cell_style.bg_color = Color(0.22, 0.22, 0.22, 1)
		cell_style.border_width_right = 1
		cell_style.border_width_bottom = 1
		cell_style.border_color = Color(0.3, 0.3, 0.3, 1)
		editor.add_theme_stylebox_override("normal", cell_style)

	# Restore tooltip to show type info
	var type_name = editor.get_meta("type_name", "Variant")
	editor.tooltip_text = "Type: " + type_name


## Convert typed value to string for storage.
func _value_to_string(value: Variant, type_id: int) -> String:
	if value == null:
		return ""

	match type_id:
		TYPE_BOOL:
			return "true" if value else "false"
		TYPE_INT, TYPE_FLOAT:
			return str(value)
		TYPE_STRING:
			return value
		TYPE_VECTOR2:
			return "(%s, %s)" % [value.x, value.y]
		TYPE_VECTOR3:
			return "(%s, %s, %s)" % [value.x, value.y, value.z]
		TYPE_COLOR:
			return value.to_html()
		_:
			return str(value)


