@tool
extends Resource
class_name ClassTableResource

## Class Table data structure for Plugin 2: GDScript Class Integration
## Stores table data generated from GDScript class definitions with type enforcement

@export var sheet_name: String = "Untitled"
@export var row_count: int = 0
@export var column_count: int = 0
@export var cells: Dictionary = {}  # Key format: "row,col" -> value (String)
@export var column_names: Array[String] = []  # Custom column names
@export var row_names: Array[String] = []  # Custom row names
@export var source_class_path: String = ""  # Path to the source GDScript class file

## NEW: Type metadata for class-based tables (uses PropertyInspector native types)
@export var source_class_name: String = ""  # Class this table represents (fully-qualified name)
@export var class_file_path: String = ""  # Path to the source .gd file
@export var columns_metadata: Array[Dictionary] = []  # Enhanced type info from PropertyInspector: {name, type, type_name, usage, exported, default, hint, hint_string}


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


func add_row(row_name: String = "") -> void:
	"""Add a new row at the end of the table"""
	row_names.append(row_name)
	row_count += 1


func add_column(col_name: String = "") -> void:
	"""Add a new column at the end of the table"""
	column_names.append(col_name)
	column_count += 1


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


## === NEW: Type-Based Methods using PropertyInspector native API ===

## Create table columns from a GDScript class using PropertyInspector
func create_columns_from_class(script_path: String) -> bool:
	var metadata = PropertyInspector.get_property_metadata(script_path)
	if metadata.is_empty():
		push_error("Failed to load class metadata from: " + script_path)
		return false

	# Clear existing columns
	columns_metadata.clear()
	column_names.clear()
	column_count = 0

	# Add column for each exported property
	for prop_meta in metadata:
		add_column_from_property_metadata(prop_meta)

	# Store class information
	var script = load(script_path)
	source_class_name = script.resource_name if script else script_path.get_file().trim_suffix(".gd")
	class_file_path = script_path

	return true


## Add a column from PropertyInspector metadata dictionary
## Metadata format: {name, type (int), type_name (String), usage, exported, default, hint, hint_string}
func add_column_from_property_metadata(prop_meta: Dictionary) -> void:
	var col_name = prop_meta.get("name", "unknown")
	var col_type_id = prop_meta.get("type", TYPE_NIL)
	var col_type_name = prop_meta.get("type_name", "Variant")
	var default_value = prop_meta.get("default", null)
	var usage_flags = prop_meta.get("usage", 0)
	var is_exported = prop_meta.get("exported", false)

	# Create enhanced metadata entry
	var column_meta = {
		"name": col_name,
		"type": col_type_id,  # Godot type ID (TYPE_INT, TYPE_STRING, etc.)
		"type_name": col_type_name,  # Human-readable type name
		"default": default_value,
		"exported": is_exported,
		"usage": usage_flags,
		"hint": prop_meta.get("hint", 0),
		"hint_string": prop_meta.get("hint_string", ""),
		"is_required": false,
	}

	columns_metadata.append(column_meta)
	set_column_name(column_count, col_name)
	column_count += 1


## Add a column with type information (legacy method, uses PropertyInspector internally)
func add_column_with_type(col_name: String, col_type: String, default_value: Variant = null, is_exported: bool = false) -> void:
	# Convert type name to Godot type ID
	var type_id = _type_name_to_id(col_type)

	var column_meta = {
		"name": col_name,
		"type": type_id,
		"type_name": col_type,
		"default": default_value,
		"exported": is_exported,
		"usage": PROPERTY_USAGE_SCRIPT_VARIABLE if is_exported else 0,
		"hint": 0,
		"hint_string": "",
		"is_required": false,
	}
	columns_metadata.append(column_meta)
	set_column_name(column_count, col_name)
	column_count += 1


## Add a column from a PropertyInfo dictionary (legacy method from old ClassParser)
func add_column_from_property(prop: Dictionary) -> void:
	var col_name = prop.get("name", "")
	var col_type = prop.get("type", "Variant")
	var default_value = prop.get("default")
	var is_exported = prop.get("is_exported", false)

	add_column_with_type(col_name, col_type, default_value, is_exported)


## Get type info for a column
func get_column_type_info(col: int) -> Dictionary:
	if col >= 0 and col < columns_metadata.size():
		return columns_metadata[col]
	return {}


## Get type name for a column (human-readable)
func get_column_type_name(col: int) -> String:
	var type_info = get_column_type_info(col)
	return type_info.get("type_name", "Unknown")


## Get Godot type ID for a column
func get_column_type_id(col: int) -> int:
	var type_info = get_column_type_info(col)
	return type_info.get("type", TYPE_NIL)


## Validate a cell value against column type using native Godot types
func validate_cell(row_index: int, col_index: int, value: Variant) -> bool:
	var type_info = get_column_type_info(col_index)
	if type_info.is_empty():
		return false

	var type_id = type_info.get("type", TYPE_NIL)
	return _is_valid_type_id(value, type_id)


## Type validation using Godot type IDs
func _is_valid_type_id(value: Variant, type_id: int) -> bool:
	if value == null:
		return true  # Allow null for now

	# Use Godot's type checking
	match type_id:
		TYPE_NIL:
			return value == null
		TYPE_BOOL:
			return value is bool
		TYPE_INT:
			return value is int
		TYPE_FLOAT:
			return value is float
		TYPE_STRING:
			return value is String
		TYPE_VECTOR2:
			return value is Vector2
		TYPE_VECTOR3:
			return value is Vector3
		TYPE_COLOR:
			return value is Color
		TYPE_OBJECT:
			return value is Object
		TYPE_ARRAY:
			return value is Array
		TYPE_DICTIONARY:
			return value is Dictionary
		_:
			# For unsupported types, allow
			return true


## Type validation helper (legacy, uses _is_valid_type_id internally)
func _is_valid_type(value: Variant, type_name: String) -> bool:
	var type_id = _type_name_to_id(type_name)
	return _is_valid_type_id(value, type_id)


## Convert type name to Godot type ID
func _type_name_to_id(type_name: String) -> int:
	match type_name:
		"bool": return TYPE_BOOL
		"int": return TYPE_INT
		"float": return TYPE_FLOAT
		"String": return TYPE_STRING
		"Vector2": return TYPE_VECTOR2
		"Vector3": return TYPE_VECTOR3
		"Color": return TYPE_COLOR
		"Array": return TYPE_ARRAY
		"Dictionary": return TYPE_DICTIONARY
		"Object": return TYPE_OBJECT
		_: return TYPE_NIL


## Check if a property type is supported for table storage
func is_supported_type(type_id: int) -> bool:
	return PropertyInspector.is_supported_type(type_id)


## Get resource metadata
func get_metadata() -> Dictionary:
	return {
		"class_name": source_class_name,
		"class_file_path": class_file_path,
		"sheet_name": sheet_name,
		"column_count": column_count,
		"row_count": row_count,
		"columns": columns_metadata.size()
	}
