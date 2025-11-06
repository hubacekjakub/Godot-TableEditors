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


## Get the value of a cell at the specified position.
func get_cell(row: int, col: int) -> String:
	var key := "%d,%d" % [row, col]
	return cells.get(key, "")


## Set the value of a cell at the specified position.
func set_cell(row: int, col: int, value: String) -> void:
	var key := "%d,%d" % [row, col]
	if value.is_empty():
		cells.erase(key)  # Remove empty cells to save memory
	else:
		cells[key] = value


## Clear all cell data.
func clear_all_cells() -> void:
	cells.clear()


## Get the display name of a column or generate Excel-style letter if unnamed.
func get_column_name(col: int) -> String:
	if col >= 0 and col < column_names.size():
		var name := column_names[col]
		if not name.is_empty():
			return name
	# Fallback for edge cases (shouldn't happen in class tables)
	return "Column_%d" % col


## Set a custom display name for a column.
func set_column_name(col: int, name: String) -> void:
	# Resize array if needed
	while column_names.size() <= col:
		column_names.append("")
	column_names[col] = name


## Get the display name of a row or generate a number if unnamed.
func get_row_name(row: int) -> String:
	if row >= 0 and row < row_names.size():
		var name := row_names[row]
		if not name.is_empty():
			return name
	return str(row + 1)


## Set a custom display name for a row.
func set_row_name(row: int, name: String) -> void:
	# Resize array if needed
	while row_names.size() <= row:
		row_names.append("")
	row_names[row] = name


## Delete a column and shift remaining columns left.
func delete_column(col: int) -> void:
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


## Delete a row and shift remaining rows up.
func delete_row(row: int) -> void:
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


## Add a new row at the end of the table.
func add_row(row_name: String = "") -> void:
	row_names.append(row_name)
	row_count += 1


## Add a new column at the end of the table.
func add_column(col_name: String = "") -> void:
	column_names.append(col_name)
	column_count += 1


## CSV Export/Import Functions

## Export sheet data to CSV file (comma-separated with header row including type hints).
func export_to_csv(file_path: String) -> bool:
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open file for writing: " + file_path)
		return false

	# Write header row with type hints (no row names for class tables)
	var header_row: PackedStringArray = []
	for col in range(column_count):
		var col_name = get_column_name(col)
		var type_info = get_column_type_info(col)
		var type_name = type_info.get("type_name", "")
		var header_text = col_name
		if not type_name.is_empty():
			header_text += ":" + type_name
		header_row.append(_escape_csv_value(header_text))
	file.store_line(",".join(header_row))

	# Write data rows (no row names)
	for row in range(row_count):
		var data_row: PackedStringArray = []
		for col in range(column_count):
			var value := get_cell(row, col)
			data_row.append(_escape_csv_value(value))
		file.store_line(",".join(data_row))

	file.close()
	if OS.is_debug_build():
		print("Sheet exported to CSV: " + file_path)
	return true


## Import CSV file into sheet (supports type hints in headers).
func import_from_csv(file_path: String) -> bool:
	var file := FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Failed to open file for reading: " + file_path)
		return false

	# Clear existing data
	clear_all_cells()
	column_names.clear()
	row_names.clear()
	columns_metadata.clear()

	var line_number := 0
	var is_first_line := true

	while not file.eof_reached():
		var line := file.get_line().strip_edges()
		if line.is_empty():
			continue

		var values := _parse_csv_line(line)

		if is_first_line:
			# First line is header with type hints
			_parse_typed_header_line(values)
			is_first_line = false
		else:
			# Data rows
			var row_index := line_number - 1
			row_count = max(row_count, row_index + 1)

			# Set data for each column
			for col in range(min(values.size(), column_count)):
				set_cell(row_index, col, values[col])

		line_number += 1

	file.close()
	if OS.is_debug_build():
		print("Sheet imported from CSV: " + file_path + " (" + str(row_count) + " rows, " + str(column_count) + " columns)")
	return true


## Escape a value for CSV format (minimal implementation).
func _escape_csv_value(value: String) -> String:
	if value.is_empty():
		return ""

	# If value contains comma, newline, or quotes, wrap in quotes and escape internal quotes
	if value.contains(",") or value.contains("\n") or value.contains("\""):
		return "\"" + value.replace("\"", "\"\"") + "\""

	return value


## Parse a CSV line into values (basic comma-separated parsing).
func _parse_csv_line(line: String) -> PackedStringArray:
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


## Parse header line with type hints like "name:String,damage:int"
func _parse_typed_header_line(header_values: PackedStringArray) -> void:
	column_count = header_values.size()

	for i in range(header_values.size()):
		var header_text = header_values[i]
		var parsed = _parse_typed_column_header(header_text)
		_add_column_metadata_from_header(parsed, i)


## Parse a column header like "name:String" into name and type
func _parse_typed_column_header(header_text: String) -> Dictionary:
	var colon_pos = header_text.find(":")
	if colon_pos == -1:
		# No type hint, just column name
		return {
			"name": header_text,
			"type_name": "String",  # Default to String
			"has_type_hint": false
		}

	var name_part = header_text.substr(0, colon_pos)
	var type_part = header_text.substr(colon_pos + 1)

	return {
		"name": name_part,
		"type_name": type_part,
		"has_type_hint": true
	}


## Add column metadata from parsed header
func _add_column_metadata_from_header(parsed_header: Dictionary, col_index: int) -> void:
	var col_name = parsed_header["name"]
	var type_name = parsed_header["type_name"]

	# Set column name
	set_column_name(col_index, col_name)

	# Create metadata entry
	var type_id = _type_name_to_id(type_name)
	var column_meta = {
		"name": col_name,
		"type": type_id,
		"type_name": type_name,
		"default": null,
		"exported": true,
		"usage": PROPERTY_USAGE_SCRIPT_VARIABLE,
		"hint": 0,
		"hint_string": "",
		"is_required": false,
	}

	# Ensure columns_metadata array is large enough
	while columns_metadata.size() <= col_index:
		columns_metadata.append({})

	columns_metadata[col_index] = column_meta


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

