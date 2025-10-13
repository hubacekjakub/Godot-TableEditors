@tool
extends VBoxContainer

## Sheet Editor Dock UI Controller

signal column_added
signal row_added
signal column_deleted(col: int)
signal row_deleted(row: int)
signal column_renamed(col: int, new_name: String)
signal row_renamed(row: int, new_name: String)
signal data_cleared
signal save_requested
signal close_requested
signal new_sheet_requested

# UI References (automatically connected from scene)
@onready var file_menu: MenuButton = %FileMenu
@onready var edit_menu: MenuButton = %EditMenu
@onready var add_column_btn: Button = %AddColumnBtn
@onready var add_row_btn: Button = %AddRowBtn
@onready var columns_label: Label = %ColumnsLabel
@onready var rows_label: Label = %RowsLabel
@onready var scroll_container: ScrollContainer = %ScrollContainer
@onready var grid_container: GridContainer = %GridContainer

var current_sheet: Resource = null
var current_focused_row: int = -1
var current_focused_col: int = -1


func _ready() -> void:
	print("Sheet Editor Dock _ready() called")
	_setup_menus()
	_connect_signals()
	print("Dock initialization complete")


func _setup_menus() -> void:
	print("Setting up menus...")
	# Setup File menu
	var file_popup := file_menu.get_popup()
	file_popup.clear()
	file_popup.add_item("New Sheet", 0)
	file_popup.add_item("Save", 1)
	file_popup.add_separator()
	file_popup.add_item("Close", 2)
	file_popup.id_pressed.connect(_on_file_menu_pressed)

	# Setup Edit menu
	var edit_popup := edit_menu.get_popup()
	edit_popup.clear()
	edit_popup.add_item("Add Column", 0)
	edit_popup.add_item("Add Row", 1)
	edit_popup.add_separator()
	edit_popup.add_item("Delete Column", 2)
	edit_popup.add_item("Delete Row", 3)
	edit_popup.add_separator()
	edit_popup.add_item("Clear All", 4)
	edit_popup.id_pressed.connect(_on_edit_menu_pressed)
	print("Menus setup complete")


func _connect_signals() -> void:
	print("Connecting button signals...")
	add_column_btn.pressed.connect(_on_add_column_pressed)
	add_row_btn.pressed.connect(_on_add_row_pressed)
	print("Button signals connected")
func set_sheet(sheet: Resource) -> void:
	"""Set the current sheet and update the UI"""
	print("Dock: set_sheet() called with: ", sheet)
	current_sheet = sheet
	update_ui()


func update_ui() -> void:
	"""Update the UI to reflect the current sheet data"""
	print("Dock: update_ui() called")
	print("  current_sheet: ", current_sheet)

	if not current_sheet or not current_sheet is Sheet:
		print("  No valid sheet, showing defaults")
		columns_label.text = "Columns: 0"
		rows_label.text = "Rows: 0"
		_rebuild_grid()
		return

	var sheet := current_sheet as Sheet
	print("  Sheet column_count: ", sheet.column_count)
	print("  Sheet row_count: ", sheet.row_count)

	columns_label.text = "Columns: %d" % sheet.column_count
	rows_label.text = "Rows: %d" % sheet.row_count

	print("  Calling _rebuild_grid()...")
	_rebuild_grid()
	print("Dock: update_ui() complete")
func _rebuild_grid() -> void:
	"""Rebuild the entire grid based on current sheet data"""
	# Clear existing grid
	for child in grid_container.get_children():
		child.queue_free()

	if not current_sheet or not current_sheet is Sheet:
		var label := Label.new()
		label.text = "No sheet loaded"
		grid_container.add_child(label)
		return

	var sheet := current_sheet as Sheet

	# Set grid columns (add 1 for row headers)
	grid_container.columns = max(1, sheet.column_count + 1)

	# If empty sheet, show a placeholder
	if sheet.column_count == 0 or sheet.row_count == 0:
		var label := Label.new()
		label.text = "Add columns and rows to start editing"
		grid_container.add_child(label)
		return

	# Create header row
	# First cell is empty (top-left corner)
	var corner_label := Label.new()
	corner_label.text = ""
	corner_label.custom_minimum_size = Vector2(40, 30)
	grid_container.add_child(corner_label)

	# Column headers (A, B, C, ...) - now editable (P1-008)
	for col in range(sheet.column_count):
		var header_edit := LineEdit.new()
		header_edit.text = sheet.get_column_name(col)
		header_edit.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		header_edit.custom_minimum_size = Vector2(80, 30)
		header_edit.placeholder_text = _get_column_letter(col)
		header_edit.set_meta("column_index", col)

		# Connect rename signal (P1-008)
		header_edit.text_submitted.connect(_on_column_renamed.bind(col))
		header_edit.focus_exited.connect(_on_column_header_focus_exited.bind(col, header_edit))

		# Add right-click context menu for deletion (P1-009)
		header_edit.gui_input.connect(_on_column_header_gui_input.bind(col))

		grid_container.add_child(header_edit)

	# Create data rows
	for row in range(sheet.row_count):
		# Row header (1, 2, 3, ...) - now editable (P1-013)
		var row_edit := LineEdit.new()
		row_edit.text = sheet.get_row_name(row)
		row_edit.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		row_edit.custom_minimum_size = Vector2(40, 30)
		row_edit.placeholder_text = str(row + 1)
		row_edit.set_meta("row_index", row)

		# Connect rename signal (P1-013)
		row_edit.text_submitted.connect(_on_row_renamed.bind(row))
		row_edit.focus_exited.connect(_on_row_header_focus_exited.bind(row, row_edit))

		# Add right-click context menu for deletion (P1-014)
		row_edit.gui_input.connect(_on_row_header_gui_input.bind(row))

		grid_container.add_child(row_edit)

		# Data cells
		for col in range(sheet.column_count):
			var line_edit := LineEdit.new()
			line_edit.text = sheet.get_cell(row, col)
			line_edit.custom_minimum_size = Vector2(80, 30)
			line_edit.placeholder_text = "..."

			# Store cell position as metadata for signal handling
			line_edit.set_meta("row", row)
			line_edit.set_meta("col", col)

			# Connect editing signals (P1-005: Cell editing functionality)
			line_edit.text_changed.connect(_on_cell_text_changed.bind(row, col))
			line_edit.text_submitted.connect(_on_cell_text_submitted.bind(row, col, line_edit))
			line_edit.focus_entered.connect(_on_cell_focus_entered.bind(row, col, line_edit))

			# Connect keyboard input for navigation (P1-006)
			line_edit.gui_input.connect(_on_cell_gui_input.bind(row, col))

			grid_container.add_child(line_edit)


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


# Cell editing callbacks (P1-005: Cell editing functionality)
func _on_cell_text_changed(new_text: String, row: int, col: int) -> void:
	"""Called when cell text is being edited"""
	if not current_sheet or not current_sheet is Sheet:
		return

	var sheet := current_sheet as Sheet
	sheet.set_cell(row, col, new_text)
	print("Cell [%d,%d] updated: '%s'" % [row, col, new_text])


func _on_cell_text_submitted(new_text: String, row: int, col: int, current_cell: LineEdit) -> void:
	"""Called when user presses Enter in a cell (P1-006: Navigation)"""
	print("Cell [%d,%d] submitted, moving to next row" % [row, col])
	_move_to_cell(row + 1, col)


func _on_cell_focus_entered(row: int, col: int, cell: LineEdit) -> void:
	"""Called when a cell gains focus"""
	print("Cell [%d,%d] focused" % [row, col])
	current_focused_row = row
	current_focused_col = col
	# Select all text for easy editing
	cell.select_all()


func _on_cell_gui_input(event: InputEvent, row: int, col: int) -> void:
	"""Handle keyboard input for cell navigation (P1-006)"""
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


# Cell navigation (P1-006: Cell selection and navigation)
func _move_to_cell(target_row: int, target_col: int) -> void:
	"""Move focus to a specific cell"""
	if not current_sheet or not current_sheet is Sheet:
		return

	var sheet := current_sheet as Sheet

	# Clamp to valid ranges
	if target_row < 0 or target_row >= sheet.row_count:
		return
	if target_col < 0 or target_col >= sheet.column_count:
		return

	# Find the target cell in the grid
	# Grid layout: [corner] [col headers...] [row1 header] [row1 cells...] [row2 header] [row2 cells...] etc.
	# Cell index = 1 + column_count + (row * (column_count + 1)) + 1 + col
	var cell_index := (1 + sheet.column_count) + (target_row * (sheet.column_count + 1)) + 1 + target_col

	var children := grid_container.get_children()
	if cell_index >= 0 and cell_index < children.size():
		var target_cell := children[cell_index]
		if target_cell is LineEdit:
			target_cell.grab_focus()
			print("Moved focus to cell [%d,%d]" % [target_row, target_col])


func _on_file_menu_pressed(id: int) -> void:
	match id:
		0:  # New Sheet
			print("Dock: New Sheet requested")
			new_sheet_requested.emit()
		1:  # Save
			save_requested.emit()
		2:  # Close
			close_requested.emit()


func _on_edit_menu_pressed(id: int) -> void:
	match id:
		0:  # Add Column
			_on_add_column_pressed()
		1:  # Add Row
			_on_add_row_pressed()
		2:  # Delete Column
			_prompt_delete_column()
		3:  # Delete Row
			_prompt_delete_row()
		4:  # Clear All
			data_cleared.emit()


func _on_add_column_pressed() -> void:
	print("Dock: Add Column button pressed")
	column_added.emit()


func _on_add_row_pressed() -> void:
	print("Dock: Add Row button pressed")
	row_added.emit()


# Column naming (P1-008)
func _on_column_renamed(new_name: String, col: int) -> void:
	"""Called when user renames a column header"""
	print("Column %d renamed to: '%s'" % [col, new_name])
	column_renamed.emit(col, new_name)


func _on_column_header_focus_exited(col: int, header_edit: LineEdit) -> void:
	"""Save column name when focus is lost"""
	var new_name := header_edit.text
	if not current_sheet or not current_sheet is Sheet:
		return

	var sheet := current_sheet as Sheet
	if new_name != sheet.get_column_name(col):
		column_renamed.emit(col, new_name)


func _on_column_header_gui_input(event: InputEvent, col: int) -> void:
	"""Handle right-click on column header for deletion"""
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_show_column_context_menu(col, event.global_position)
			get_viewport().set_input_as_handled()


# Row naming (P1-013)
func _on_row_renamed(new_name: String, row: int) -> void:
	"""Called when user renames a row header"""
	print("Row %d renamed to: '%s'" % [row, new_name])
	row_renamed.emit(row, new_name)


func _on_row_header_focus_exited(row: int, header_edit: LineEdit) -> void:
	"""Save row name when focus is lost"""
	var new_name := header_edit.text
	if not current_sheet or not current_sheet is Sheet:
		return

	var sheet := current_sheet as Sheet
	if new_name != sheet.get_row_name(row):
		row_renamed.emit(row, new_name)


func _on_row_header_gui_input(event: InputEvent, row: int) -> void:
	"""Handle right-click on row header for deletion"""
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_RIGHT:
			_show_row_context_menu(row, event.global_position)
			get_viewport().set_input_as_handled()


# Column deletion (P1-009)
func _prompt_delete_column() -> void:
	"""Prompt user to select which column to delete"""
	if not current_sheet or not current_sheet is Sheet:
		return

	var sheet := current_sheet as Sheet
	if sheet.column_count == 0:
		print("No columns to delete")
		return

	# Delete the last column for now (simple implementation)
	# TODO: Add proper column selection UI
	column_deleted.emit(sheet.column_count - 1)


func _show_column_context_menu(col: int, position: Vector2) -> void:
	"""Show context menu for column operations (P1-009)"""
	var popup := PopupMenu.new()
	popup.add_item("Delete Column", 0)
	popup.id_pressed.connect(func(id):
		if id == 0:
			column_deleted.emit(col)
		popup.queue_free()
	)
	add_child(popup)
	popup.popup(Rect2i(position, Vector2i(150, 50)))


# Row deletion (P1-014)
func _prompt_delete_row() -> void:
	"""Prompt user to select which row to delete"""
	if not current_sheet or not current_sheet is Sheet:
		return

	var sheet := current_sheet as Sheet
	if sheet.row_count == 0:
		print("No rows to delete")
		return

	# Delete the last row for now (simple implementation)
	# TODO: Add proper row selection UI
	row_deleted.emit(sheet.row_count - 1)


func _show_row_context_menu(row: int, position: Vector2) -> void:
	"""Show context menu for row operations (P1-014)"""
	var popup := PopupMenu.new()
	popup.add_item("Delete Row", 0)
	popup.id_pressed.connect(func(id):
		if id == 0:
			row_deleted.emit(row)
		popup.queue_free()
	)
	add_child(popup)
	popup.popup(Rect2i(position, Vector2i(150, 50)))
