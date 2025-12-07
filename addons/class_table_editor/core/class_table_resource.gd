@tool
extends Resource
class_name ClassTableResource

# Class table resource used for GDScript class integration.
# Stores table data and minimal type metadata for columns.

@export var sheet_name: String = "Untitled"
@export var row_count: int = 0
@export var column_count: int = 0
@export var cells: Dictionary = {}  # Key format: "row,col" -> value (String)
@export var column_names: Array[String] = []  # Custom column names
@export var row_names: Array[String] = []  # Custom row names

# Type metadata for class-based tables (PropertyInspector native types)
@export var source_class_name: String = ""  # Class this table represents (fully-qualified name)
@export var class_file_path: String = ""  # Path to the source .gd file
@export var columns_metadata: Array[Dictionary] = []  # Minimal schema info: {name, type, hint}


# Get the value of a cell at the specified position.
func get_cell(row: int, col: int) -> String:
	var key := "%d,%d" % [row, col]
	return cells.get(key, "")


# Set the value of a cell at the specified position.
func set_cell(row: int, col: int, value: String) -> void:
	var key := "%d,%d" % [row, col]
	if value.is_empty():
		cells.erase(key)  # Remove empty cells to save memory
	else:
		cells[key] = value


# Clear all cell data.
func clear_all_cells() -> void:
	cells.clear()


# Get the display name of a column, or fallback if unnamed.
func get_column_name(col: int) -> String:
	if col >= 0 and col < column_names.size():
		var name := column_names[col]
		if not name.is_empty():
			return name
	# Fallback for edge cases (shouldn't happen in class tables)
	return "Column_%d" % col


# Set a custom display name for a column.
func set_column_name(col: int, name: String) -> void:
	# Resize array if needed
	while column_names.size() <= col:
		column_names.append("")
	column_names[col] = name


# Get the display name of a row, or fallback to numerical label.
func get_row_name(row: int) -> String:
	if row >= 0 and row < row_names.size():
		var name := row_names[row]
		if not name.is_empty():
			return name
	return str(row + 1)


# Set a custom display name for a row.
func set_row_name(row: int, name: String) -> void:
	# Resize array if needed
	while row_names.size() <= row:
		row_names.append("")
	row_names[row] = name


# Delete a column and shift remaining columns left.
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


# Delete a row and shift remaining rows up.
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


# Append a new row at the end of the table.
func add_row(row_name: String = "") -> void:
	row_names.append(row_name)
	row_count += 1


# Append a new column at the end of the table.
func add_column(col_name: String = "") -> void:
	column_names.append(col_name)
	column_count += 1


# CSV export/import functions

# Export the sheet to CSV. Header includes column type hints.
# Uses Godot's store_csv_line for escaping.
func export_to_csv(file_path: String) -> bool:
	var file := FileAccess.open(file_path, FileAccess.WRITE)
	if file == null:
		push_error("Failed to open file for writing: " + file_path)
		return false

	# Write header row with type hints (no row names for class tables)
	var header_row: PackedStringArray = []
	for col in range(column_count):
		var col_name = get_column_name(col)
		var type_name = get_column_type_name(col)
		var header_text = col_name
		if not type_name.is_empty():
			header_text += ":" + type_name
		header_row.append(header_text)
	file.store_csv_line(header_row)

	# Write data rows (no row names)
	for row in range(row_count):
		var data_row: PackedStringArray = []
		for col in range(column_count):
			var value := get_cell(row, col)
			data_row.append(value)
		file.store_csv_line(data_row)

	file.close()
	if OS.is_debug_build():
		print("Sheet exported to CSV: " + file_path)
	return true


# Import a CSV into the sheet, optionally parsing type hints from header.
# Uses Godot's get_csv_line for parsing.
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
	row_count = 0

	var current_row := 0
	var is_header_parsed := false

	# Use proper loop condition as recommended by Godot docs
	while file.get_position() < file.get_length():
		var values := file.get_csv_line()

		# Skip completely empty lines (all values empty)
		# But preserve rows that have at least one non-empty value
		var has_content := false
		for v in values:
			if not v.is_empty():
				has_content = true
				break

		if not has_content and values.size() <= 1:
			continue

		if not is_header_parsed:
			# First line is header with type hints
			_parse_typed_header_line(values)
			is_header_parsed = true
		else:
			# Data rows
			row_count = current_row + 1

			# Set data for each column
			for col in range(min(values.size(), column_count)):
				set_cell(current_row, col, values[col])

			current_row += 1

	file.close()
	if OS.is_debug_build():
		print("Sheet imported from CSV: " + file_path + " (" + str(row_count) + " rows, " + str(column_count) + " columns)")
	return true


# Note: custom CSV parsing removed; we rely on Godot's implementations.


# Parse header line with type hints such as "name:String".
func _parse_typed_header_line(header_values: PackedStringArray) -> void:
	column_count = header_values.size()

	for i in range(header_values.size()):
		var header_text = header_values[i]
		var parsed = _parse_typed_column_header(header_text)
		_add_column_metadata_from_header(parsed, i)


# Parse a column header "name:type" into name and type string.
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


# Add column metadata from parsed header data.
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
		"hint": "",
	}

	# Ensure columns_metadata array is large enough
	while columns_metadata.size() <= col_index:
		columns_metadata.append({})

	columns_metadata[col_index] = column_meta


# Type-based methods (PropertyInspector integration)

# Create columns based on exported properties in a GDScript class.
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
	if not script:
		push_error("Failed to load script: %s" % script_path)
		return false

	if not (script is Script):
		push_error("Loaded resource is not a Script: %s" % script_path)
		return false

	source_class_name = script.resource_name if script.resource_name else script_path.get_file().trim_suffix(".gd")
	class_file_path = script_path

	return true


# Add a column from PropertyInspector property metadata dictionary.
func add_column_from_property_metadata(prop_meta: Dictionary) -> void:
	var col_name = prop_meta.get("name", "unknown")
	var col_type_id = prop_meta.get("type", TYPE_NIL)
	var hint_text = _extract_hint_text(prop_meta)

	# Store minimal metadata footprint
	var column_meta = {
		"name": col_name,
		"type": col_type_id,  # Godot type ID (TYPE_INT, TYPE_STRING, etc.)
		"hint": hint_text,
	}

	columns_metadata.append(column_meta)
	set_column_name(column_count, col_name)
	column_count += 1


# Add a column with a specified type. Kept for tests and backwards compatibility.
func add_column_with_type(col_name: String, col_type: String, _default_value: Variant = null, _is_exported: bool = false, column_hint: String = "") -> void:
	# Convert type name to Godot type ID
	var type_id = _type_name_to_id(col_type)

	var column_meta = {
		"name": col_name,
		"type": type_id,
		"hint": column_hint,
	}
	columns_metadata.append(column_meta)
	set_column_name(column_count, col_name)
	column_count += 1


# Convenience compatibility wrapper: add a column from a PropertyInfo dict.
func add_column_from_property(prop: Dictionary) -> void:
	var col_name = prop.get("name", "")
	var col_type = prop.get("type", "Variant")
	var default_value = prop.get("default")
	var is_exported = prop.get("is_exported", false)

	add_column_with_type(col_name, col_type, default_value, is_exported)


# Get column type metadata.
func get_column_type_info(col: int) -> Dictionary:
	if col >= 0 and col < columns_metadata.size():
		return columns_metadata[col]
	return {}


# Get human-readable type name for a column.
func get_column_type_name(col: int) -> String:
	var type_id = get_column_type_id(col)
	return _type_id_to_name(type_id)


# Get Godot type ID for a column.
func get_column_type_id(col: int) -> int:
	var type_info = get_column_type_info(col)
	return type_info.get("type", TYPE_NIL)


# Validate a value against a column's type.
func validate_cell(row_index: int, col_index: int, value: Variant) -> bool:
	var type_info = get_column_type_info(col_index)
	if type_info.is_empty():
		return false

	var type_id = type_info.get("type", TYPE_NIL)
	return _is_valid_type_id(value, type_id)


# Type validation using Godot type IDs.
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


# Convert a type-name string to a Godot type ID.
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


func _type_id_to_name(type_id: int) -> String:
	var name = type_string(type_id)
	return name if not name.is_empty() else "Variant"


func _extract_hint_text(prop_meta: Dictionary) -> String:
	var hint_string = prop_meta.get("hint_string", "")
	if hint_string is String and not hint_string.is_empty():
		return hint_string
	if prop_meta.has("hint"):
		return str(prop_meta.get("hint"))
	return ""


# Check whether a Godot type is supported (proxy to PropertyInspector).
func is_supported_type(type_id: int) -> bool:
	return PropertyInspector.is_supported_type(type_id)


# Return a lightweight metadata dictionary for the resource.
func get_metadata() -> Dictionary:
	return {
		"class_name": source_class_name,
		"class_file_path": class_file_path,
		"sheet_name": sheet_name,
		"column_count": column_count,
		"row_count": row_count,
		"columns": columns_metadata.size()
	}

