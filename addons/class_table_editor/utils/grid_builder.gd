@tool
extends RefCounted
class_name GridBuilder

## GridBuilder - Handles construction and rebuilding of the table grid
##
## Extracts grid building logic from ClassTableDock to improve maintainability
## and separate concerns between UI coordination and grid construction.

const TYPED_CELL_EDITOR_FACTORY := preload("res://addons/class_table_editor/utils/typed_cell_editor_factory.gd")

# UI Size Constants
const MIN_COLUMN_WIDTH: int = 120  # Minimum column width
const COLUMN_HEADER_HEIGHT: int = 30  # Height for column headers
const CHAR_WIDTH_ESTIMATE: int = 8  # Approximate pixels per character for column sizing

var grid_container: GridContainer
var current_sheet: ClassTableResource
var cell_manager: CellManager


func _init(p_grid_container: GridContainer, p_cell_manager: CellManager) -> void:
	grid_container = p_grid_container
	cell_manager = p_cell_manager


func set_sheet(sheet: ClassTableResource = null) -> void:
	## Set the current sheet for grid building.
	current_sheet = sheet


func rebuild_grid(force: bool = false) -> void:
	## Rebuild the entire grid based on current sheet data.
	## If force is false, checks if rebuild is necessary first.

	# Check if rebuild is actually needed (optimization)
	if not force and not _needs_rebuild():
		return

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


func _needs_rebuild() -> bool:
	## Check if grid structure needs to be rebuilt.
	## Returns true if grid dimensions don't match sheet dimensions.
	if not current_sheet:
		return grid_container.get_child_count() > 0

	var child_count = grid_container.get_child_count()
	if child_count == 0:
		return true

	# Expected children: col_headers + (rows * cells)
	var expected = current_sheet.column_count + (current_sheet.row_count * current_sheet.column_count)
	return child_count != expected


func update_single_cell(row: int, col: int) -> void:
	## Update a single cell's display without rebuilding entire grid.
	## This is an optimization for cell edits that don't change structure.
	if not current_sheet:
		return

	# Calculate cell index: headers + (row * columns) + col
	var cell_index := current_sheet.column_count + (row * current_sheet.column_count) + col

	var children := grid_container.get_children()
	if cell_index >= 0 and cell_index < children.size():
		var cell := children[cell_index]
		# Update the cell editor's value from sheet
		var value = current_sheet.get_cell(row, col)
		if cell.has_method("set_text"):
			cell.set_text(str(value))
		elif cell.has_method("set_value"):
			cell.set_value(value)


## Create editable column headers with type styling.
func _build_column_headers(sheet: ClassTableResource) -> void:
	for col in range(sheet.column_count):
		var header_edit := LineEdit.new()

		# Get type info for this column
		var type_info = sheet.get_column_type_info(col)
		var col_type_name = sheet.get_column_type_name(col)
		var col_name = sheet.get_column_name(col)

		# Display column name with type hint
		header_edit.text = col_name
		header_edit.tooltip_text = "Type: %s" % col_type_name
		header_edit.alignment = HORIZONTAL_ALIGNMENT_CENTER

		# Make columns wider to accommodate longer property names
		var column_width = max(MIN_COLUMN_WIDTH, col_name.length() * CHAR_WIDTH_ESTIMATE)
		header_edit.custom_minimum_size = Vector2(column_width, COLUMN_HEADER_HEIGHT)
		header_edit.placeholder_text = "%s (%s)" % [sheet.get_column_name(col), col_type_name]
		header_edit.set_meta("column_index", col)

		# Style column headers like Excel with type-based color coding
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

