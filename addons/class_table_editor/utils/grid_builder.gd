@tool
extends RefCounted
class_name GridBuilder

## GridBuilder - Handles construction and rebuilding of the table grid
##
## Extracts grid building logic from ClassTableDock to improve maintainability
## and separate concerns between UI coordination and grid construction.

const TYPED_CELL_EDITOR_FACTORY := preload("res://addons/class_table_editor/utils/typed_cell_editor_factory.gd")

var grid_container: GridContainer
var current_sheet: ClassTableResource
var cell_manager: CellManager


func _init(p_grid_container: GridContainer, p_cell_manager: CellManager) -> void:
	grid_container = p_grid_container
	cell_manager = p_cell_manager


func set_sheet(sheet: ClassTableResource = null) -> void:
	## Set the current sheet for grid building.
	current_sheet = sheet


func rebuild_grid() -> void:
	## Rebuild the entire grid based on current sheet data.
	for child in grid_container.get_children():
		child.queue_free()

	if not current_sheet:
		var label := Label.new()
		label.text = "No sheet loaded"
		grid_container.add_child(label)
		return

	var sheet := current_sheet

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

	_build_column_headers(sheet)
	_build_data_rows(sheet)


## Create editable column headers with type styling.
func _build_column_headers(sheet: ClassTableResource) -> void:
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

		# Connect header events (these will be handled by the dock)
		header_edit.text_submitted.connect(_on_column_renamed.bind(col))
		header_edit.focus_exited.connect(_on_column_header_focus_exited.bind(col, header_edit))
		header_edit.gui_input.connect(_on_column_header_gui_input.bind(col))

		grid_container.add_child(header_edit)


## Create data rows with type-specific cell editors.
func _build_data_rows(sheet: ClassTableResource) -> void:
	for row in range(sheet.row_count):
		# Create data cells for this row
		for col in range(sheet.column_count):
			var cell_editor = cell_manager.create_cell_editor(row, col, sheet)
			grid_container.add_child(cell_editor)


## Convert column index to Excel-style letter (0=A, 1=B, ..., 26=AA, etc.).
func _get_column_letter(col_index: int) -> String:
	var result := ""
	var index := col_index

	while true:
		result = char(65 + (index % 26)) + result
		index = index / 26
		if index == 0:
			break
		index -= 1

	return result


## Return color-coded background for column headers based on type.
func _get_type_header_color(type_id: int) -> Color:
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


# Signal forwarding methods - these will be connected to the dock's handlers
signal column_renamed(new_name: String, col: int)
signal column_header_focus_exited(col: int, header_edit: LineEdit)
signal column_header_gui_input(event: InputEvent, col: int)


func _on_column_renamed(new_name: String, col: int) -> void:
	column_renamed.emit(new_name, col)


func _on_column_header_focus_exited(col: int, header_edit: LineEdit) -> void:
	column_header_focus_exited.emit(col, header_edit)


func _on_column_header_gui_input(event: InputEvent, col: int) -> void:
	column_header_gui_input.emit(event, col)

