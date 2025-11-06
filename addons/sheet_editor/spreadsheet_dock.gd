@tool
extends VBoxContainer

## Spreadsheet Dock UI Controller - Implementation 1: Excel-Style Table Editor

const CREATE_TABLE_SCENE := preload("res://addons/sheet_editor/create_table_dialog.tscn")

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
@onready var grid_container: GridContainer = %GridContainer

var create_table_dialog: ConfirmationDialog = null
var csv_export_dialog: FileDialog = null
var csv_import_dialog: FileDialog = null

var current_sheet: Resource = null
var recent_sheets: Array[String] = []  # Store recent sheet paths
var editor_settings: EditorSettings = null
const MAX_RECENT_SHEETS = 10
const RECENT_SHEETS_SETTING = "sheet_editor/recent_sheets"


func _ready() -> void:
	editor_settings = EditorInterface.get_editor_settings()
	_load_recent_sheets_from_settings()
	_setup_menus()
	_setup_csv_dialogs()
	_connect_signals()
	_update_recent_sheets_list()


func _exit_tree() -> void:
	"""Clean up dialogs to prevent memory leaks"""
	if csv_export_dialog and is_instance_valid(csv_export_dialog):
		csv_export_dialog.queue_free()
		csv_export_dialog = null

	if csv_import_dialog and is_instance_valid(csv_import_dialog):
		csv_import_dialog.queue_free()
		csv_import_dialog = null

	if create_table_dialog and is_instance_valid(create_table_dialog):
		create_table_dialog.queue_free()
		create_table_dialog = null


func _setup_csv_dialogs() -> void:
	"""Setup CSV export/import dialogs"""
	# Create CSV export dialog
	var CSVExportDialog := load("res://addons/sheet_editor/csv_export_dialog.gd")
	csv_export_dialog = CSVExportDialog.new()
	csv_export_dialog.export_confirmed.connect(_on_csv_export_confirmed)
	add_child.call_deferred(csv_export_dialog)

	# Create CSV import dialog
	var CSVImportDialog := load("res://addons/sheet_editor/csv_import_dialog.gd")
	csv_import_dialog = CSVImportDialog.new()
	csv_import_dialog.import_confirmed.connect(_on_csv_import_confirmed)
	add_child.call_deferred(csv_import_dialog)


func _setup_menus() -> void:
	# Setup File menu
	var file_popup := file_menu.get_popup()
	file_popup.clear()
	file_popup.add_item("New", 0)
	file_popup.add_item("Load", 1)
	file_popup.add_item("Save", 2)
	file_popup.add_separator()
	file_popup.add_item("Export to CSV", 3)
	file_popup.add_item("Import from CSV", 4)
	file_popup.add_separator()
	file_popup.add_item("Close", 5)
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


func update_ui(force_rebuild: bool = false) -> void:
	"""Update the UI to reflect the current sheet data

	Args:
		force_rebuild: If true, forces a full grid rebuild. If false, only updates labels.
	"""
	if not current_sheet or not current_sheet is SpreadsheetResource:
		columns_label.text = "Columns: 0"
		rows_label.text = "Rows: 0"
		_rebuild_grid.call_deferred()
		_update_recent_sheets_list()
		return

	var sheet := current_sheet as SpreadsheetResource
	columns_label.text = "Columns: %d" % sheet.column_count
	rows_label.text = "Rows: %d" % sheet.row_count

	# Only rebuild if forced (structure changed) or grid doesn't match sheet dimensions
	if force_rebuild or _needs_grid_rebuild(sheet):
		_rebuild_grid.call_deferred()

	_update_recent_sheets_list()


func _rebuild_grid() -> void:
	"""Rebuild the entire grid based on current sheet data"""
	# Clear existing grid
	for child in grid_container.get_children():
		child.queue_free()

	if not current_sheet or not current_sheet is SpreadsheetResource:
		var label := Label.new()
		label.text = "No sheet loaded"
		grid_container.add_child(label)
		return

	var sheet := current_sheet as SpreadsheetResource

	# Set grid columns (add 1 for row headers)
	grid_container.columns = max(1, sheet.column_count + 1)


func _needs_grid_rebuild(sheet: SpreadsheetResource) -> bool:
	"""Check if grid structure needs to be rebuilt

	Returns true if:
	- Grid is empty
	- Number of grid children doesn't match expected (row/col structure changed)
	"""
	var child_count = grid_container.get_child_count()
	if child_count == 0:
		return true

	# Expected children: corner + col_headers + (rows * (row_header + cells))
	# = 1 + column_count + (row_count * (1 + column_count))
	var expected = 1 + sheet.column_count + (sheet.row_count * (1 + sheet.column_count))
	return child_count != expected


func _update_single_cell(row: int, col: int, new_value: String) -> void:
	"""Update a single cell's display without rebuilding the entire grid

	This is an optimization for cell edits that don't change grid structure.
	"""
	if not current_sheet or not current_sheet is SpreadsheetResource:
		return

	var sheet := current_sheet as SpreadsheetResource

	# Calculate cell index in grid layout
	# Grid: [corner] [col headers...] [row1 header] [row1 cells...] [row2 header] [row2 cells...]
	var cell_index := (1 + sheet.column_count) + (row * (sheet.column_count + 1)) + 1 + col

	var children := grid_container.get_children()
	if cell_index >= 0 and cell_index < children.size():
		var cell := children[cell_index]
		if cell is LineEdit and cell.text != new_value:
			# Update without triggering text_changed signal
			cell.text = new_value


func _rebuild_grid() -> void:
	"""Rebuild the entire grid based on current sheet data"""
	# Clear existing grid
	for child in grid_container.get_children():
		child.queue_free()

	if not current_sheet or not current_sheet is SpreadsheetResource:
		var label := Label.new()
		label.text = "No sheet loaded"
		grid_container.add_child(label)
		return

	var sheet := current_sheet as SpreadsheetResource

	# Set grid columns (add 1 for row headers)
	grid_container.columns = max(1, sheet.column_count + 1)

	# Add spacing between cells for a cleaner look
	grid_container.add_theme_constant_override("h_separation", 0)
	grid_container.add_theme_constant_override("v_separation", 0)

	# If empty sheet, show a placeholder
	if sheet.column_count == 0 or sheet.row_count == 0:
		var label := Label.new()
		label.text = "Add columns and rows to start editing"
		grid_container.add_child(label)
		return

	# Create header row - first cell is empty (top-left corner)
	var corner_label := Label.new()
	corner_label.text = ""
	corner_label.custom_minimum_size = Vector2(40, 30)
	corner_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	corner_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER

	# Add subtle border styling
	var corner_style := StyleBoxFlat.new()
	corner_style.bg_color = Color(0.25, 0.25, 0.25, 1)
	corner_style.border_width_right = 1
	corner_style.border_width_bottom = 2
	corner_style.border_color = Color(0.4, 0.4, 0.4, 1)
	corner_label.add_theme_stylebox_override("normal", corner_style)

	grid_container.add_child(corner_label)

	# Create editable column headers with Excel-style letters (A, B, C...)
	for col in range(sheet.column_count):
		var header_edit := LineEdit.new()
		header_edit.text = sheet.get_column_name(col)
		header_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
		header_edit.custom_minimum_size = Vector2(100, 30)
		header_edit.placeholder_text = _get_column_letter(col)
		header_edit.set_meta("column_index", col)

		# Style column headers like Excel
		var header_style := StyleBoxFlat.new()
		header_style.bg_color = Color(0.22, 0.22, 0.22, 1)
		header_style.border_width_right = 1
		header_style.border_width_bottom = 2
		header_style.border_color = Color(0.4, 0.4, 0.4, 1)
		header_edit.add_theme_stylebox_override("normal", header_style)
		header_edit.add_theme_stylebox_override("focus", header_style)

		header_edit.text_submitted.connect(_on_column_renamed.bind(col))
		header_edit.focus_exited.connect(_on_column_header_focus_exited.bind(col, header_edit))
		header_edit.gui_input.connect(_on_column_header_gui_input.bind(col))

		grid_container.add_child(header_edit)

	# Create data rows with editable row headers
	for row in range(sheet.row_count):
		# Row header with numbering (1, 2, 3...)
		var row_edit := LineEdit.new()
		row_edit.text = sheet.get_row_name(row)
		row_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER
		row_edit.custom_minimum_size = Vector2(40, 30)
		row_edit.placeholder_text = str(row + 1)
		row_edit.set_meta("row_index", row)

		# Style row headers like Excel
		var row_style := StyleBoxFlat.new()
		row_style.bg_color = Color(0.22, 0.22, 0.22, 1)
		row_style.border_width_right = 1
		row_style.border_width_bottom = 1
		row_style.border_color = Color(0.4, 0.4, 0.4, 1)
		row_edit.add_theme_stylebox_override("normal", row_style)
		row_edit.add_theme_stylebox_override("focus", row_style)

		row_edit.text_submitted.connect(_on_row_renamed.bind(row))
		row_edit.focus_exited.connect(_on_row_header_focus_exited.bind(row, row_edit))
		row_edit.gui_input.connect(_on_row_header_gui_input.bind(row))

		grid_container.add_child(row_edit)

		# Create data cells for this row
		for col in range(sheet.column_count):
			var line_edit := LineEdit.new()
			line_edit.text = sheet.get_cell(row, col)
			line_edit.custom_minimum_size = Vector2(100, 30)
			line_edit.placeholder_text = "..."

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
			line_edit.add_theme_stylebox_override("normal", cell_style)

			# Focus style with highlight
			var focus_style := StyleBoxFlat.new()
			focus_style.bg_color = Color(0.25, 0.35, 0.45, 1)
			focus_style.border_width_left = 2
			focus_style.border_width_right = 2
			focus_style.border_width_top = 2
			focus_style.border_width_bottom = 2
			focus_style.border_color = Color(0.4, 0.6, 0.8, 1)
			line_edit.add_theme_stylebox_override("focus", focus_style)

			line_edit.set_meta("row", row)
			line_edit.set_meta("col", col)

			line_edit.text_changed.connect(_on_cell_text_changed.bind(row, col))
			line_edit.text_submitted.connect(_on_cell_text_submitted.bind(row, col, line_edit))
			line_edit.focus_entered.connect(_on_cell_focus_entered.bind(row, col, line_edit))
			line_edit.gui_input.connect(_on_cell_gui_input.bind(row, col))

			grid_container.add_child(line_edit)


func _get_column_letter(col_index: int) -> String:
	"""Convert column index to Excel-style letter (0=A, 1=B, ..., 26=AA, etc.)"""
	var result := ""
	var index := col_index

	while index >= 0:
		result = char(65 + (index % 26)) + result
		index = int(index / 26) - 1

	return result


func _on_cell_text_changed(new_text: String, row: int, col: int) -> void:
	"""Update cell data when text changes"""
	if not current_sheet or not current_sheet is SpreadsheetResource:
		return

	var sheet := current_sheet as SpreadsheetResource
	sheet.set_cell(row, col, new_text)


func _on_cell_text_submitted(new_text: String, row: int, col: int, current_cell: LineEdit) -> void:
	"""Move to next row when Enter is pressed"""
	_move_to_cell(row + 1, col)


func _on_cell_focus_entered(row: int, col: int, cell: LineEdit) -> void:
	"""Track focused cell and select all text for easy editing"""
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
	if not current_sheet or not current_sheet is SpreadsheetResource:
		return

	var sheet := current_sheet as SpreadsheetResource

	# Validate target position
	if target_row < 0 or target_row >= sheet.row_count:
		return
	if target_col < 0 or target_col >= sheet.column_count:
		return

	# Calculate cell index in grid layout
	# Grid: [corner] [col headers...] [row1 header] [row1 cells...] [row2 header] [row2 cells...]
	var cell_index := (1 + sheet.column_count) + (target_row * (sheet.column_count + 1)) + 1 + target_col

	var children := grid_container.get_children()
	if cell_index >= 0 and cell_index < children.size():
		var target_cell := children[cell_index]
		if target_cell is LineEdit:
			target_cell.grab_focus()


func _on_file_menu_pressed(id: int) -> void:
	match id:
		0:  # New
			_show_create_table_dialog()
		1:  # Load
			load_requested.emit()
		2:  # Save
			save_requested.emit()
		3:  # Export to CSV
			_on_export_csv_pressed()
		4:  # Import from CSV
			_on_import_csv_pressed()
		5:  # Close
			close_requested.emit()


func _on_export_csv_pressed() -> void:
	"""Show CSV export dialog"""
	if not current_sheet or not current_sheet is SpreadsheetResource:
		push_warning("No sheet loaded to export")
		return

	if csv_export_dialog:
		csv_export_dialog.show_dialog()


func _on_import_csv_pressed() -> void:
	"""Show CSV import dialog"""
	if not current_sheet or not current_sheet is SpreadsheetResource:
		push_warning("No sheet loaded to import into")
		return

	if csv_import_dialog:
		csv_import_dialog.show_dialog()


func _on_csv_export_confirmed(file_path: String) -> void:
	"""Handle CSV export confirmation"""
	if not current_sheet or not current_sheet is SpreadsheetResource:
		return

	var sheet := current_sheet as SpreadsheetResource
	if sheet.export_to_csv(file_path):
		print("Successfully exported to: " + file_path)
	else:
		push_error("Failed to export CSV to: " + file_path)


func _on_csv_import_confirmed(file_path: String) -> void:
	"""Handle CSV import confirmation"""
	if not current_sheet or not current_sheet is SpreadsheetResource:
		return

	var sheet := current_sheet as SpreadsheetResource
	if sheet.import_from_csv(file_path):
		print("Successfully imported from: " + file_path)
		update_ui.call_deferred(true)  # Force rebuild since structure may have changed
	else:
		push_error("Failed to import CSV from: " + file_path)


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
	if not current_sheet or not current_sheet is SpreadsheetResource:
		return

	var sheet := current_sheet as SpreadsheetResource
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
	if not current_sheet or not current_sheet is SpreadsheetResource:
		return

	var sheet := current_sheet as SpreadsheetResource
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
	add_child.call_deferred(popup)
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
	add_child.call_deferred(popup)
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

	_save_recent_sheets_to_settings()
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


func _show_create_table_dialog() -> void:
	"""Show the Create Table dialog"""
	# Instantiate dialog if it doesn't exist
	if not create_table_dialog:
		create_table_dialog = CREATE_TABLE_SCENE.instantiate()

		# Connect to the dialog's custom signal
		create_table_dialog.table_creation_confirmed.connect(_on_create_table_confirmed)

		# Add as child of the dock to ensure proper modal behavior
		add_child(create_table_dialog)

	# Reset dialog to default values after it's in the tree
	create_table_dialog.reset_to_defaults()

	# Show the dialog as modal and ensure it gets focus
	create_table_dialog.popup_centered()
	create_table_dialog.grab_focus()


func _on_create_table_confirmed(table_name: String, file_name: String, num_rows: int, num_columns: int, save_path: String) -> void:
	"""Handle Create Table dialog confirmation"""
	# Emit signal with parameters for the plugin to handle
	create_table_requested.emit(table_name, file_name, num_rows, num_columns, save_path)


func _load_recent_sheets_from_settings() -> void:
	"""Load recent sheets list from EditorSettings"""
	if not editor_settings:
		return

	if not editor_settings.has_setting(RECENT_SHEETS_SETTING):
		editor_settings.set_setting(RECENT_SHEETS_SETTING, [])

	var saved_sheets = editor_settings.get_setting(RECENT_SHEETS_SETTING)
	if saved_sheets is Array:
		recent_sheets.clear()
		for path in saved_sheets:
			if path is String:
				recent_sheets.append(path)


func _save_recent_sheets_to_settings() -> void:
	"""Save recent sheets list to EditorSettings"""
	if editor_settings:
		editor_settings.set_setting(RECENT_SHEETS_SETTING, recent_sheets)
