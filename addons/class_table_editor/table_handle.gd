@tool
extends Resource
class_name TableHandle

## A handle to a specific row in a ClassTableResource
## Provides convenient access to row data and cell values

@export var table_resource: ClassTableResource = null
@export var row_name: String = ""

var _cached_row_index: int = -1


## Get the row index for the currently selected row name
func get_row_index() -> int:
	if not table_resource:
		return -1

	# Check if cached index is still valid
	if _cached_row_index >= 0 and _cached_row_index < table_resource.row_count:
		if table_resource.get_cell(_cached_row_index, 0) == row_name:
			return _cached_row_index

	# Search for row by name (assuming first column is "name")
	for row in range(table_resource.row_count):
		var cell_value = table_resource.get_cell(row, 0)
		if cell_value == row_name:
			_cached_row_index = row
			return row

	return -1


## Get a cell value by column name
func get_cell_value(column_name: String) -> String:
	if not table_resource:
		return ""

	var row_index = get_row_index()
	if row_index < 0:
		return ""

	# Find column index by name
	for col in range(table_resource.column_count):
		if table_resource.get_column_name(col) == column_name:
			return table_resource.get_cell(row_index, col)

	return ""


## Get typed cell value (attempts to parse based on column type)
func get_typed_value(column_name: String) -> Variant:
	if not table_resource:
		return null

	var row_index = get_row_index()
	if row_index < 0:
		return null

	# Find column index by name
	for col in range(table_resource.column_count):
		if table_resource.get_column_name(col) == column_name:
			var cell_value = table_resource.get_cell(row_index, col)
			var type_info = table_resource.get_column_type_info(col)
			var type_id = type_info.get("type", TYPE_NIL)

			# Parse value based on type
			return _parse_value(cell_value, type_id)

	return null


## Get all data for the current row as a Dictionary
func get_row_data() -> Dictionary:
	var data := {}

	if not table_resource:
		return data

	var row_index = get_row_index()
	if row_index < 0:
		return data

	# Collect all column values
	for col in range(table_resource.column_count):
		var col_name = table_resource.get_column_name(col)
		var cell_value = table_resource.get_cell(row_index, col)
		var type_info = table_resource.get_column_type_info(col)
		var type_id = type_info.get("type", TYPE_NIL)

		data[col_name] = _parse_value(cell_value, type_id)

	return data


## Check if the handle is valid (has table and valid row)
func is_valid() -> bool:
	return table_resource != null and get_row_index() >= 0


## Parse string value to typed variant based on type ID
func _parse_value(value: String, type_id: int) -> Variant:
	# Handle empty values with appropriate defaults for each type
	if value.is_empty():
		match type_id:
			TYPE_BOOL:
				return false
			TYPE_INT:
				return 0
			TYPE_FLOAT:
				return 0.0
			TYPE_STRING:
				return ""
			TYPE_VECTOR2:
				return Vector2.ZERO
			TYPE_VECTOR3:
				return Vector3.ZERO
			TYPE_COLOR:
				return Color.WHITE
			_:
				return null

	match type_id:
		TYPE_BOOL:
			return value.to_lower() == "true"
		TYPE_INT:
			return value.to_int()
		TYPE_FLOAT:
			return value.to_float()
		TYPE_STRING:
			return value
		TYPE_VECTOR2:
			return _parse_vector2(value)
		TYPE_VECTOR3:
			return _parse_vector3(value)
		TYPE_COLOR:
			return Color(value)
		_:
			return value


## Parse Vector2 from string format "(x, y)"
func _parse_vector2(value: String) -> Vector2:
	var clean = value.strip_edges().trim_prefix("(").trim_suffix(")")
	var parts = clean.split(",")
	if parts.size() >= 2:
		return Vector2(parts[0].to_float(), parts[1].to_float())
	return Vector2.ZERO


## Parse Vector3 from string format "(x, y, z)"
func _parse_vector3(value: String) -> Vector3:
	var clean = value.strip_edges().trim_prefix("(").trim_suffix(")")
	var parts = clean.split(",")
	if parts.size() >= 3:
		return Vector3(parts[0].to_float(), parts[1].to_float(), parts[2].to_float())
	return Vector3.ZERO


## Get a string representation for debugging
func _to_string() -> String:
	if not is_valid():
		return "TableHandle(invalid)"
	return "TableHandle(table=%s, row=%s)" % [table_resource.sheet_name, row_name]
