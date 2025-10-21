@tool
extends VBoxContainer

## Class Table Dock UI Controller - Plugin 2: GDScript Class Integration

const CLASS_SELECTION_SCENE := preload("res://addons/class_table_editor/class_selection_dialog.tscn")
const TYPED_CELL_EDITOR_FACTORY = preload("res://addons/class_table_editor/typed_cell_editor_factory.gd")

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
@onready var add_column_btn: Button = %AddColumnBtn
@onready var add_row_btn: Button = %AddRowBtn
@onready var columns_label: Label = %ColumnsLabel
@onready var rows_label: Label = %RowsLabel
@onready var recent_sheets_list: ItemList = %RecentSheetsList
@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var grid_container: GridContainer = %GridContainer

var class_select_dialog: ConfirmationDialog = null
var editor_interface: EditorInterface = null  # Reference to editor interface

var current_sheet: Resource = null
var current_focused_row: int = -1
var current_focused_col: int = -1
var recent_sheets: Array[String] = []  # Store recent sheet paths
const MAX_RECENT_SHEETS = 10


func _ready() -> void:
	_setup_menus()
	_connect_signals()
	_update_recent_sheets_list()


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
	edit_popup.add_item("Add Column", 0)
	edit_popup.add_item("Add Row", 1)
	edit_popup.add_separator()
	edit_popup.add_item("Clear All", 2)
	edit_popup.id_pressed.connect(_on_edit_menu_pressed)


func _connect_signals() -> void:
	add_column_btn.pressed.connect(_on_add_column_pressed)
	add_row_btn.pressed.connect(_on_add_row_pressed)
	recent_sheets_list.item_selected.connect(_on_recent_sheet_selected)


func set_sheet(sheet: Resource) -> void:
	"""Set the current sheet and update the UI"""
	current_sheet = sheet
	update_ui()


func update_ui() -> void:
	"""Update the UI to reflect the current sheet data"""
	if not current_sheet or not current_sheet is ClassTableResource:
		columns_label.text = "Columns: 0"
		rows_label.text = "Rows: 0"
		_rebuild_grid.call_deferred()
		_update_recent_sheets_list()
		return

	var sheet := current_sheet as ClassTableResource
	columns_label.text = "Columns: %d" % sheet.column_count
	rows_label.text = "Rows: %d" % sheet.row_count
	_rebuild_grid.call_deferred()
	_update_recent_sheets_list()


func _rebuild_grid() -> void:
	"""Rebuild the entire grid based on current sheet data"""
	# Clear existing grid
	for child in grid_container.get_children():
		child.queue_free()

	if not current_sheet or not current_sheet is ClassTableResource:
		var label := Label.new()
		label.text = "No sheet loaded"
		grid_container.add_child(label)
		return

	var sheet := current_sheet as ClassTableResource

	# Set grid columns (no row header column anymore)
	grid_container.columns = max(1, sheet.column_count)

	# Add spacing between cells for a cleaner look
	grid_container.add_theme_constant_override("h_separation", 0)
	grid_container.add_theme_constant_override("v_separation", 0)

	# If empty sheet, show a placeholder
	if sheet.column_count == 0 or sheet.row_count == 0:
		var label := Label.new()
		label.text = "Add columns and rows to start editing"
		grid_container.add_child(label)
		return

	# Create editable column headers with Excel-style letters (A, B, C...)
	for col in range(sheet.column_count):
		var header_edit := LineEdit.new()

		# Get type info for this column
		var type_info = sheet.get_column_type_info(col)
		var col_type_name = type_info.get("type_name", "Variant")
		var col_name = sheet.get_column_name(col)

		# Display column name with type hint (P2-028)
		header_edit.text = col_name
		header_edit.tooltip_text = "Type: %s" % col_type_name
		header_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
		# Make columns wider to accommodate longer property names
		var column_width = max(120, col_name.length() * 8)
		header_edit.custom_minimum_size = Vector2(column_width, 30)
		header_edit.placeholder_text = "%s (%s)" % [_get_column_letter(col), col_type_name]
		header_edit.set_meta("column_index", col)

		# Style column headers like Excel with type-based color coding (P2-019)
		var header_style := StyleBoxFlat.new()
		header_style.bg_color = _get_type_header_color(type_info.get("type", TYPE_NIL))
		header_style.border_width_right = 1
		header_style.border_width_bottom = 2
		header_style.border_color = Color(0.4, 0.4, 0.4, 1)
		header_edit.add_theme_stylebox_override("normal", header_style)
		header_edit.add_theme_stylebox_override("focus", header_style)

		header_edit.text_submitted.connect(_on_column_renamed.bind(col))
		header_edit.focus_exited.connect(_on_column_header_focus_exited.bind(col, header_edit))
		header_edit.gui_input.connect(_on_column_header_gui_input.bind(col))

		grid_container.add_child(header_edit)

	# Create data rows (no row headers)
	for row in range(sheet.row_count):
		# Create data cells for this row
		for col in range(sheet.column_count):
			# Get type info for this column (P2-020)
			var type_info = sheet.get_column_type_info(col)
			var type_id = type_info.get("type", TYPE_NIL)
			var type_name = type_info.get("type_name", "Variant")

			# Create type-specific editor (P2-020, P2-023, P2-024, P2-025)
			var cell_editor = TYPED_CELL_EDITOR_FACTORY.create_editor(type_id, type_name, type_info)
			cell_editor.set_meta("row", row)
			cell_editor.set_meta("col", col)
			cell_editor.set_meta("type_id", type_id)
			cell_editor.set_meta("type_name", type_name)

			# Make cells match column width
			var col_name = sheet.get_column_name(col)
			var cell_width = max(120, col_name.length() * 8)
			cell_editor.custom_minimum_size = Vector2(cell_width, 30)

			# Set current value
			var current_value = sheet.get_cell(row, col)
			TYPED_CELL_EDITOR_FACTORY.set_editor_value(cell_editor, current_value)

			# Style data cells with subtle alternating row colors
			var cell_style := StyleBoxFlat.new()
			# Use standard Godot theme colors with subtle alternation
			if row % 2 == 0:
				cell_style.bg_color = Color(0.24, 0.24, 0.24, 1)  # Slightly lighter
			else:
				cell_style.bg_color = Color(0.22, 0.22, 0.22, 1)  # Standard
			cell_style.border_width_right = 1
			cell_style.border_width_bottom = 1
			cell_style.border_color = Color(0.3, 0.3, 0.3, 1)

			# Apply styles based on control type
			if cell_editor is LineEdit:
				cell_editor.add_theme_stylebox_override("normal", cell_style)
				var focus_style := StyleBoxFlat.new()
				focus_style.bg_color = Color(0.25, 0.35, 0.45, 1)
				focus_style.border_width_left = 2
				focus_style.border_width_right = 2
				focus_style.border_width_top = 2
				focus_style.border_width_bottom = 2
				focus_style.border_color = Color(0.4, 0.6, 0.8, 1)
				cell_editor.add_theme_stylebox_override("focus", focus_style)
			elif cell_editor is Panel or cell_editor is PanelContainer:
				cell_editor.add_theme_stylebox_override("panel", cell_style)

			# Connect signals based on control type (P2-019, P2-026, P2-027)
			if cell_editor is LineEdit:
				cell_editor.text_changed.connect(_on_typed_cell_changed.bind(row, col, cell_editor))
				cell_editor.text_submitted.connect(_on_typed_cell_submitted.bind(row, col, cell_editor))
				cell_editor.focus_entered.connect(_on_cell_focus_entered.bind(row, col, cell_editor))
				cell_editor.gui_input.connect(_on_cell_gui_input.bind(row, col))
			elif cell_editor is CheckBox:
				cell_editor.toggled.connect(_on_typed_cell_changed.bind(row, col, cell_editor))
				cell_editor.focus_entered.connect(_on_cell_focus_entered.bind(row, col, cell_editor))
				cell_editor.gui_input.connect(_on_cell_gui_input.bind(row, col))
			elif cell_editor is SpinBox:
				cell_editor.value_changed.connect(_on_typed_cell_changed.bind(row, col, cell_editor))
				cell_editor.get_line_edit().focus_entered.connect(_on_cell_focus_entered.bind(row, col, cell_editor))
				cell_editor.gui_input.connect(_on_cell_gui_input.bind(row, col))
			elif cell_editor is ColorPickerButton:
				cell_editor.color_changed.connect(_on_typed_cell_changed.bind(row, col, cell_editor))
				cell_editor.focus_entered.connect(_on_cell_focus_entered.bind(row, col, cell_editor))
				cell_editor.gui_input.connect(_on_cell_gui_input.bind(row, col))
			elif cell_editor is HBoxContainer:
				# Vector2/Vector3 editors
				cell_editor.gui_input.connect(_on_cell_gui_input.bind(row, col))
				for child in cell_editor.get_children():
					if child is SpinBox:
						child.value_changed.connect(_on_typed_cell_changed.bind(row, col, cell_editor))
						child.get_line_edit().focus_entered.connect(_on_cell_focus_entered.bind(row, col, cell_editor))

			grid_container.add_child(cell_editor)


func _get_column_letter(col_index: int) -> String:
	"""Convert column index to Excel-style letter (0=A, 1=B, ..., 26=AA, etc.)"""
	var result := ""
	var index := col_index

	while true:
		result = char(65 + (index % 26)) + result
		index = index / 26
		if index == 0:
			break
		index -= 1

	return result


func _on_cell_text_changed(new_text: String, row: int, col: int) -> void:
	"""Update cell data when text changes"""
	if not current_sheet or not current_sheet is ClassTableResource:
		return

	var sheet := current_sheet as ClassTableResource
	sheet.set_cell(row, col, new_text)


func _on_cell_text_submitted(new_text: String, row: int, col: int, current_cell: LineEdit) -> void:
	"""Move to next row when Enter is pressed"""
	_move_to_cell(row + 1, col)


func _on_cell_focus_entered(row: int, col: int, cell: Control) -> void:
	"""Track focused cell and select all text for easy editing"""
	current_focused_row = row
	current_focused_col = col
	# Only select all text for LineEdit controls
	if cell is LineEdit:
		cell.select_all()


func _on_cell_gui_input(event: InputEvent, row: int, col: int) -> void:
	"""Handle keyboard navigation in cells"""
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
	"""Move focus to a specific cell if it exists"""
	if not current_sheet or not current_sheet is ClassTableResource:
		return

	var sheet := current_sheet as ClassTableResource

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
		0:  # Add Column
			_on_add_column_pressed()
		1:  # Add Row
			_on_add_row_pressed()
		2:  # Clear All
			data_cleared.emit()


func _on_add_column_pressed() -> void:
	column_added.emit()


func _on_add_row_pressed() -> void:
	row_added.emit()


func _on_column_renamed(new_name: String, col: int) -> void:
	"""Emit signal when column is renamed"""
	column_renamed.emit(col, new_name)


func _on_column_header_focus_exited(col: int, header_edit: LineEdit) -> void:
	"""Save column name when header loses focus"""
	var new_name := header_edit.text
	if not current_sheet or not current_sheet is ClassTableResource:
		return

	var sheet := current_sheet as ClassTableResource
	if new_name != sheet.get_column_name(col):
		column_renamed.emit(col, new_name)


func _on_column_header_gui_input(event: InputEvent, col: int) -> void:
	"""Show context menu on right-click for column operations"""
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_show_column_context_menu(col, event.global_position)
			get_viewport().set_input_as_handled()


func _on_row_renamed(new_name: String, row: int) -> void:
	"""Emit signal when row is renamed"""
	row_renamed.emit(row, new_name)


func _on_row_header_focus_exited(row: int, header_edit: LineEdit) -> void:
	"""Save row name when header loses focus"""
	var new_name := header_edit.text
	if not current_sheet or not current_sheet is ClassTableResource:
		return

	var sheet := current_sheet as ClassTableResource
	if new_name != sheet.get_row_name(row):
		row_renamed.emit(row, new_name)


func _on_row_header_gui_input(event: InputEvent, row: int) -> void:
	"""Show context menu on right-click for row operations"""
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_show_row_context_menu(row, event.global_position)
			get_viewport().set_input_as_handled()


func _show_column_context_menu(col: int, position: Vector2) -> void:
	"""Display context menu for column operations"""
	var popup := PopupMenu.new()
	popup.add_item("Delete Column", 0)
	popup.id_pressed.connect(func(id):
		if id == 0:
			column_deleted.emit(col)
		popup.queue_free()
	)
	add_child(popup)
	popup.popup(Rect2i(position, Vector2i(150, 50)))


func _show_row_context_menu(row: int, position: Vector2) -> void:
	"""Display context menu for row operations"""
	var popup := PopupMenu.new()
	popup.add_item("Delete Row", 0)
	popup.id_pressed.connect(func(id):
		if id == 0:
			row_deleted.emit(row)
		popup.queue_free()
	)
	add_child(popup)
	popup.popup(Rect2i(position, Vector2i(150, 50)))


func add_to_recent_sheets(path: String) -> void:
	"""Add a sheet path to the recent sheets list"""
	if path.is_empty():
		return

	# Don't add if already exists (keep original order)
	if path in recent_sheets:
		return

	# Add to end of list
	recent_sheets.append(path)

	# Limit to MAX_RECENT_SHEETS
	if recent_sheets.size() > MAX_RECENT_SHEETS:
		recent_sheets.pop_front()  # Remove oldest

	_update_recent_sheets_list()


func _update_recent_sheets_list() -> void:
	"""Update the ItemList display with recent sheets"""
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


func _on_recent_sheet_selected(index: int) -> void:
	"""Handle selection of a recent sheet from the list"""
	if index >= 0 and index < recent_sheets.size():
		var path := recent_sheets[index]
		sheet_selected.emit(path)


func _show_class_select_dialog() -> void:
	"""Show the Class Selection dialog for P2-009"""
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


func _on_class_table_created(resource_path: String, class_info: Dictionary) -> void:
	"""Handle class table creation from class selection dialog"""
	print("Class table created: %s" % resource_path)
	print("  From class: %s" % class_info.get("class_name", ""))

	# Load and display the newly created table
	var table_resource = load(resource_path) as ClassTableResource
	if table_resource:
		set_sheet(table_resource)
		add_to_recent_sheets(resource_path)
		print("Table loaded and displayed in dock")

		# IMPORTANT: Make the plugin aware of this resource by editing it
		# This will trigger the plugin's _edit() method which sets current_sheet
		if editor_interface:
			editor_interface.edit_resource(table_resource)
			print("Resource registered with editor")
		else:
			push_warning("Editor interface not available - plugin may not be aware of new table")


## === NEW: Type-Safe Editing Methods (P2-019 to P2-028) ===

## Handle cell value changes with type validation (P2-019, P2-021, P2-022, P2-026, P2-027)
func _on_typed_cell_changed(new_value: Variant, row: int, col: int, editor: Control) -> void:
	"""Update cell data when typed value changes with validation"""
	if not current_sheet or not current_sheet is ClassTableResource:
		return

	var sheet := current_sheet as ClassTableResource
	var type_id = editor.get_meta("type_id", TYPE_NIL)

	# Get value from editor
	var value = TYPED_CELL_EDITOR_FACTORY.get_editor_value(editor)

	# Validate value (P2-019, P2-026)
	var validation = TYPED_CELL_EDITOR_FACTORY.validate_value(type_id, value)
	if not validation["valid"]:
		# Show validation error (P2-026)
		_show_validation_error(editor, validation["error"])
		return

	# Clear any previous validation error display
	_clear_validation_error(editor)

	# Convert value to string for storage
	var value_str = _value_to_string(value, type_id)
	sheet.set_cell(row, col, value_str)


## Handle cell submission (Enter key)
func _on_typed_cell_submitted(new_value: Variant, row: int, col: int, editor: Control) -> void:
	"""Move to next row when Enter is pressed"""
	_move_to_cell(row + 1, col)


## Show validation error in UI (P2-026)
func _show_validation_error(editor: Control, error_message: String) -> void:
	"""Display validation error for a cell editor"""
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


## Clear validation error display
func _clear_validation_error(editor: Control) -> void:
	"""Clear validation error styling from cell editor"""
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


## Convert typed value to string for storage
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


## Get header color based on type (P2-019)
func _get_type_header_color(type_id: int) -> Color:
	"""Return color-coded background for column headers based on type"""
	match type_id:
		TYPE_BOOL:
			return Color(0.25, 0.22, 0.28, 1)  # Purple tint
		TYPE_INT:
			return Color(0.22, 0.25, 0.28, 1)  # Blue tint
		TYPE_FLOAT:
			return Color(0.22, 0.28, 0.25, 1)  # Green tint
		TYPE_STRING:
			return Color(0.28, 0.25, 0.22, 1)  # Orange tint
		TYPE_VECTOR2, TYPE_VECTOR3:
			return Color(0.25, 0.28, 0.22, 1)  # Yellow-green tint
		TYPE_COLOR:
			return Color(0.28, 0.22, 0.25, 1)  # Pink tint
		_:
			return Color(0.22, 0.22, 0.22, 1)  # Default gray

