@tool
extends Resource
class_name Sheet

## Table data structure for SheetEditor

@export var sheet_name: String = "Untitled"
@export var row_count: int = 0
@export var column_count: int = 0
@export var cells: Dictionary = {}  # Key format: "row,col" -> value (String)
@export var column_names: Array[String] = []  # Custom column names
@export var row_names: Array[String] = []  # Custom row names


func get_cell(row: int, col: int) -> String:
	"""Get the value of a cell at the specified position"""
	var key := "%d,%d" % [row, col]
	return cells.get(key, "")


func set_cell(row: int, col: int, value: String) -> void:
	"""Set the value of a cell at the specified position"""
	var key := "%d,%d" % [row, col]
	if value.is_empty():
		cells.erase(key)  # Remove empty cells to save memory
	else:
		cells[key] = value


func clear_all_cells() -> void:
	"""Clear all cell data"""
	cells.clear()


func get_column_name(col: int) -> String:
	"""Get the display name of a column, or generate Excel-style letter if unnamed"""
	if col >= 0 and col < column_names.size():
		var name := column_names[col]
		if not name.is_empty():
			return name
	return _get_column_letter(col)


func set_column_name(col: int, name: String) -> void:
	"""Set a custom display name for a column"""
	# Resize array if needed
	while column_names.size() <= col:
		column_names.append("")
	column_names[col] = name


func get_row_name(row: int) -> String:
	"""Get the display name of a row, or generate number if unnamed"""
	if row >= 0 and row < row_names.size():
		var name := row_names[row]
		if not name.is_empty():
			return name
	return str(row + 1)


func set_row_name(row: int, name: String) -> void:
	"""Set a custom display name for a row"""
	# Resize array if needed
	while row_names.size() <= row:
		row_names.append("")
	row_names[row] = name


func delete_column(col: int) -> void:
	"""Delete a column and shift remaining columns left"""
	if col < 0 or col >= column_count:
		return

	# Remove column name
	if col < column_names.size():
		column_names.remove_at(col)

	# Shift all cells in columns after the deleted one
	var new_cells := {}
	for key in cells.keys():
		var parts: PackedStringArray = key.split(",")
		var cell_row := int(parts[0])
		var cell_col := int(parts[1])

		if cell_col == col:
			# Skip this column's cells (delete them)
			continue
		elif cell_col > col:
			# Shift left
			new_cells["%d,%d" % [cell_row, cell_col - 1]] = cells[key]
		else:
			# Keep as is
			new_cells[key] = cells[key]

	cells = new_cells
	column_count -= 1


func delete_row(row: int) -> void:
	"""Delete a row and shift remaining rows up"""
	if row < 0 or row >= row_count:
		return

	# Remove row name
	if row < row_names.size():
		row_names.remove_at(row)

	# Shift all cells in rows after the deleted one
	var new_cells := {}
	for key in cells.keys():
		var parts: PackedStringArray = key.split(",")
		var cell_row := int(parts[0])
		var cell_col := int(parts[1])

		if cell_row == row:
			# Skip this row's cells (delete them)
			continue
		elif cell_row > row:
			# Shift up
			new_cells["%d,%d" % [cell_row - 1, cell_col]] = cells[key]
		else:
			# Keep as is
			new_cells[key] = cells[key]

	cells = new_cells
	row_count -= 1


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
