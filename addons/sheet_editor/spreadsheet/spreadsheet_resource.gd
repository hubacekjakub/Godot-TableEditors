@tool
extends Resource
class_name SpreadsheetResource

## Spreadsheet data structure for Implementation 1: Excel-Style Table Editor
## Stores table data with manual column/row creation and CSV export/import support

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


## CSV Export/Import Functions

func export_to_csv(file_path: String) -> bool:
	"""Export sheet data to CSV file (comma-separated with header row including row names)"""
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open file for writing: " + file_path)
		return false

	# Write header row (row name column + column names)
	var header_row: PackedStringArray = ["Row Name"]
	for col in range(column_count):
		header_row.append(_escape_csv_value(get_column_name(col)))
	file.store_line(",".join(header_row))

	# Write data rows with row names
	for row in range(row_count):
		var data_row: PackedStringArray = [_escape_csv_value(get_row_name(row))]
		for col in range(column_count):
			var value := get_cell(row, col)
			data_row.append(_escape_csv_value(value))
		file.store_line(",".join(data_row))

	file.close()
	print("Sheet exported to CSV: " + file_path)
	return true


func import_from_csv(file_path: String) -> bool:
	"""Import CSV file into sheet (supports row names in first column)"""
	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Failed to open file for reading: " + file_path)
		return false

	# Clear existing data
	clear_all_cells()
	column_names.clear()
	row_names.clear()

	var line_number := 0
	var is_first_line := true
	var has_row_names := false
	var header_values: PackedStringArray = []

	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line.is_empty():
			continue

		var values := _parse_csv_line(line)

		if is_first_line:
			# First line is header
			header_values = values
			is_first_line = false

			# Check if first column is "Row Name" (case insensitive)
			if values.size() > 0 and values[0].to_lower() == "row name":
				has_row_names = true
				# Skip the "Row Name" column for actual column names
				column_count = values.size() - 1
				for i in range(1, values.size()):
					set_column_name(i - 1, values[i])
			else:
				# No row names column, treat as regular data columns
				has_row_names = false
				column_count = values.size()
				for i in range(values.size()):
					set_column_name(i, values[i])
		else:
			# Data rows
			var row_index := line_number - 1
			row_count = row_index + 1

			if has_row_names and values.size() > 0:
				# First value is row name, rest are data
				set_row_name(row_index, values[0])
				for col in range(min(values.size() - 1, column_count)):
					set_cell(row_index, col, values[col + 1])
			else:
				# No row names, all values are data
				for col in range(min(values.size(), column_count)):
					set_cell(row_index, col, values[col])

		line_number += 1

	file.close()
	print("Sheet imported from CSV: " + file_path + " (" + str(row_count) + " rows, " + str(column_count) + " columns, row names: " + str(has_row_names) + ")")
	return true


func _escape_csv_value(value: String) -> String:
	"""Escape a value for CSV format (minimal implementation)"""
	if value.is_empty():
		return ""

	# If value contains comma, newline, or quotes, wrap in quotes and escape internal quotes
	if value.contains(",") or value.contains("\n") or value.contains("\""):
		return "\"" + value.replace("\"", "\"\"") + "\""

	return value


func _parse_csv_line(line: String) -> PackedStringArray:
	"""Parse a CSV line into values (basic comma-separated parsing)"""
	var values: PackedStringArray = []
	var current_value := ""
	var in_quotes := false
	var i := 0

	while i < line.length():
		var c := line[i]

		if c == "\"":
			if in_quotes and i + 1 < line.length() and line[i + 1] == "\"":
				# Escaped quote
				current_value += "\""
				i += 1
			else:
				# Toggle quote mode
				in_quotes = not in_quotes
		elif c == "," and not in_quotes:
			# End of value
			values.append(current_value)
			current_value = ""
		else:
			current_value += c

		i += 1

	# Add last value
	values.append(current_value)

	return values
