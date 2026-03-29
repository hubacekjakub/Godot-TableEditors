@tool
class_name ClassTableResourceV2
extends Resource
## Type-safe table resource with native Variant cell storage.
## Cells store actual Variant values — no string conversion needed.

signal data_changed()

@export var table_name: String = ""
@export var row_count: int = 0
@export var column_count: int = 0

## Sparse cell storage: "row,col" → Variant (native types, not strings)
@export var cells: Dictionary = {}

@export var column_names: Array[String] = []
@export var row_names: Array[String] = []

## Per-column metadata from PropertyInspectorV2:
## { name, type, type_name, hint, hint_string, default }
@export var columns_metadata: Array[Dictionary] = []

## Source class information
@export var class_name_str: String = ""
@export var class_file_path: String = ""


# ── Creation ──────────────────────────────────────────────────────────

## Populates columns from a GDScript class file.
## Clears existing data.
func create_from_class(script_path: String) -> bool:
	var properties: Array[Dictionary] = PropertyInspectorV2.get_exported_properties(script_path)
	if properties.is_empty():
		push_warning("ClassTableResourceV2: no exported properties in %s" % script_path)
		return false

	class_file_path = script_path
	class_name_str = PropertyInspectorV2.get_class_name(script_path)
	table_name = class_name_str

	columns_metadata = properties
	column_names.clear()
	for prop: Dictionary in properties:
		column_names.append(prop["name"])
	column_count = column_names.size()

	# Reset rows
	row_count = 0
	row_names.clear()
	cells.clear()

	data_changed.emit()
	return true


# ── Row operations ────────────────────────────────────────────────────

func add_row(name: String = "") -> int:
	var row_idx: int = row_count
	row_count += 1

	if name.is_empty():
		name = str(row_idx)
	row_names.append(name)

	# Set default values for each column
	for col_idx: int in column_count:
		var meta: Dictionary = columns_metadata[col_idx]
		var default_val: Variant = meta.get("default")
		if default_val != null:
			cells[_key(row_idx, col_idx)] = default_val

	data_changed.emit()
	return row_idx


func remove_row(row_idx: int) -> void:
	if row_idx < 0 or row_idx >= row_count:
		return

	# Remove cells for this row
	for col_idx: int in column_count:
		cells.erase(_key(row_idx, col_idx))

	# Shift cells above this row down
	for r: int in range(row_idx + 1, row_count):
		for c: int in column_count:
			var old_key: String = _key(r, c)
			var new_key: String = _key(r - 1, c)
			if cells.has(old_key):
				cells[new_key] = cells[old_key]
				cells.erase(old_key)

	row_names.remove_at(row_idx)
	row_count -= 1
	data_changed.emit()


# ── Cell access ───────────────────────────────────────────────────────

func get_cell(row: int, col: int) -> Variant:
	var key: String = _key(row, col)
	if cells.has(key):
		return cells[key]
	# Return column default if no value stored
	if col >= 0 and col < column_count:
		return columns_metadata[col].get("default")
	return null


func set_cell(row: int, col: int, value: Variant) -> void:
	var key: String = _key(row, col)
	# Erase if value matches default (sparse storage)
	if col >= 0 and col < column_count:
		var default_val: Variant = columns_metadata[col].get("default")
		if typeof(value) == typeof(default_val) and value == default_val:
			cells.erase(key)
			data_changed.emit()
			return
	cells[key] = value
	data_changed.emit()


## Returns a full row as a dictionary { column_name: value }.
func get_row_data(row_idx: int) -> Dictionary:
	var data: Dictionary = {}
	for col_idx: int in column_count:
		data[column_names[col_idx]] = get_cell(row_idx, col_idx)
	return data


# ── Bulk operations ───────────────────────────────────────────────────

## Returns all rows as an Array of Dictionaries.
func get_all_rows() -> Array[Dictionary]:
	var result: Array[Dictionary] = []
	for row_idx: int in row_count:
		result.append(get_row_data(row_idx))
	return result


## Finds a row index by row name. Returns -1 if not found.
func find_row(name: String) -> int:
	return row_names.find(name)


# ── CSV Export ────────────────────────────────────────────────────────

## Exports the table to CSV. First row is a type-hint header (##type:int, etc.),
## second row is column names, remaining rows are data.
func export_csv(path: String) -> bool:
	var file := FileAccess.open(path, FileAccess.WRITE)
	if file == null:
		push_error("ClassTableResourceV2: cannot open for writing: %s" % path)
		return false

	# Row 1: type hints  —  ##row_name, ##type:int, ##type:String, ...
	var type_row: PackedStringArray = ["##row_name"]
	for meta: Dictionary in columns_metadata:
		var hint_tag: String = "##type:%s" % meta["type_name"]
		# Append enum hint if present
		if meta.get("hint") == PROPERTY_HINT_ENUM:
			hint_tag += "|enum:%s" % meta["hint_string"]
		elif meta.get("hint") == PROPERTY_HINT_RESOURCE_TYPE and not meta.get("hint_string", "").is_empty():
			hint_tag += "|resource:%s" % meta["hint_string"]
		type_row.append(hint_tag)
	file.store_csv_line(type_row)

	# Row 2: column names
	var header: PackedStringArray = ["row_name"]
	for col_name: String in column_names:
		header.append(col_name)
	file.store_csv_line(header)

	# Data rows
	for row_idx: int in row_count:
		var line: PackedStringArray = [row_names[row_idx] if row_idx < row_names.size() else ""]
		for col_idx: int in column_count:
			line.append(_variant_to_csv(get_cell(row_idx, col_idx), columns_metadata[col_idx]["type"]))
		file.store_csv_line(line)

	file.close()
	return true


## Imports data from a CSV file. Expects the format produced by export_csv().
## If the CSV has a type-hint row (##row_name), it uses those types.
## Otherwise falls back to current column metadata.
func import_csv(path: String) -> bool:
	var file := FileAccess.open(path, FileAccess.READ)
	if file == null:
		push_error("ClassTableResourceV2: cannot open for reading: %s" % path)
		return false

	var lines: Array[PackedStringArray] = []
	while not file.eof_reached():
		var row: PackedStringArray = file.get_csv_line()
		if row.size() == 0 or (row.size() == 1 and row[0].is_empty()):
			continue
		lines.append(row)
	file.close()

	if lines.size() < 2:
		push_warning("ClassTableResourceV2: CSV too short")
		return false

	var data_start: int = 0
	var type_hints: PackedStringArray = []

	# Detect type-hint row
	if lines[0][0].begins_with("##"):
		type_hints = lines[0]
		data_start = 2  # skip type row + header row
	else:
		data_start = 1  # skip header row only

	# Parse type hints if present (otherwise use existing metadata)
	if not type_hints.is_empty() and columns_metadata.is_empty():
		# Build columns from CSV type hints
		column_names.clear()
		columns_metadata.clear()
		var header: PackedStringArray = lines[1] if lines.size() > 1 else []
		for i: int in range(1, type_hints.size()):
			var col_name: String = header[i] if i < header.size() else "col_%d" % (i - 1)
			column_names.append(col_name)
			columns_metadata.append(_parse_type_hint(type_hints[i], col_name))
		column_count = column_names.size()

	# Import data rows
	cells.clear()
	row_names.clear()
	row_count = 0

	for line_idx: int in range(data_start, lines.size()):
		var line: PackedStringArray = lines[line_idx]
		var row_name: String = line[0] if line.size() > 0 else str(row_count)
		row_names.append(row_name)
		for col_idx: int in column_count:
			var csv_val: String = line[col_idx + 1] if (col_idx + 1) < line.size() else ""
			if csv_val.is_empty():
				continue
			var col_type: int = columns_metadata[col_idx]["type"] if col_idx < columns_metadata.size() else TYPE_STRING
			var parsed: Variant = _csv_to_variant(csv_val, col_type)
			cells[_key(row_count, col_idx)] = parsed
		row_count += 1

	data_changed.emit()
	return true


# ── CSV helpers ───────────────────────────────────────────────────────

func _variant_to_csv(value: Variant, type: int) -> String:
	if value == null:
		return ""
	match type:
		TYPE_BOOL:
			return "true" if value else "false"
		TYPE_VECTOR2, TYPE_VECTOR2I:
			return "(%s, %s)" % [value.x, value.y]
		TYPE_VECTOR3, TYPE_VECTOR3I:
			return "(%s, %s, %s)" % [value.x, value.y, value.z]
		TYPE_VECTOR4, TYPE_VECTOR4I:
			return "(%s, %s, %s, %s)" % [value.x, value.y, value.z, value.w]
		TYPE_COLOR:
			return "(%s, %s, %s, %s)" % [value.r, value.g, value.b, value.a]
		TYPE_RECT2, TYPE_RECT2I:
			return "(%s, %s, %s, %s)" % [value.position.x, value.position.y, value.size.x, value.size.y]
		TYPE_OBJECT:
			if value is Resource and value.resource_path:
				return value.resource_path
			return ""
	return str(value)


func _csv_to_variant(text: String, type: int) -> Variant:
	match type:
		TYPE_STRING, TYPE_STRING_NAME, TYPE_NODE_PATH:
			return text
		TYPE_INT:
			return text.to_int()
		TYPE_FLOAT:
			return text.to_float()
		TYPE_BOOL:
			return text.to_lower() == "true"
		TYPE_VECTOR2:
			var c: PackedStringArray = _strip_parens(text).split(",")
			return Vector2(c[0].strip_edges().to_float(), c[1].strip_edges().to_float()) if c.size() >= 2 else Vector2.ZERO
		TYPE_VECTOR2I:
			var c: PackedStringArray = _strip_parens(text).split(",")
			return Vector2i(c[0].strip_edges().to_int(), c[1].strip_edges().to_int()) if c.size() >= 2 else Vector2i.ZERO
		TYPE_VECTOR3:
			var c: PackedStringArray = _strip_parens(text).split(",")
			return Vector3(c[0].strip_edges().to_float(), c[1].strip_edges().to_float(), c[2].strip_edges().to_float()) if c.size() >= 3 else Vector3.ZERO
		TYPE_VECTOR3I:
			var c: PackedStringArray = _strip_parens(text).split(",")
			return Vector3i(c[0].strip_edges().to_int(), c[1].strip_edges().to_int(), c[2].strip_edges().to_int()) if c.size() >= 3 else Vector3i.ZERO
		TYPE_VECTOR4:
			var c: PackedStringArray = _strip_parens(text).split(",")
			return Vector4(c[0].strip_edges().to_float(), c[1].strip_edges().to_float(), c[2].strip_edges().to_float(), c[3].strip_edges().to_float()) if c.size() >= 4 else Vector4.ZERO
		TYPE_VECTOR4I:
			var c: PackedStringArray = _strip_parens(text).split(",")
			return Vector4i(c[0].strip_edges().to_int(), c[1].strip_edges().to_int(), c[2].strip_edges().to_int(), c[3].strip_edges().to_int()) if c.size() >= 4 else Vector4i.ZERO
		TYPE_COLOR:
			var c: PackedStringArray = _strip_parens(text).split(",")
			return Color(c[0].strip_edges().to_float(), c[1].strip_edges().to_float(), c[2].strip_edges().to_float(), c[3].strip_edges().to_float()) if c.size() >= 4 else Color.WHITE
		TYPE_RECT2:
			var c: PackedStringArray = _strip_parens(text).split(",")
			return Rect2(c[0].strip_edges().to_float(), c[1].strip_edges().to_float(), c[2].strip_edges().to_float(), c[3].strip_edges().to_float()) if c.size() >= 4 else Rect2()
		TYPE_RECT2I:
			var c: PackedStringArray = _strip_parens(text).split(",")
			return Rect2i(c[0].strip_edges().to_int(), c[1].strip_edges().to_int(), c[2].strip_edges().to_int(), c[3].strip_edges().to_int()) if c.size() >= 4 else Rect2i()
		TYPE_OBJECT:
			if ResourceLoader.exists(text):
				return load(text)
			return null
	return text


func _strip_parens(text: String) -> String:
	return text.trim_prefix("(").trim_suffix(")")


func _parse_type_hint(hint: String, col_name: String) -> Dictionary:
	# Format: "##type:int", "##type:int|enum:Melee:0,Ranged:1", "##type:Object|resource:Texture2D"
	var meta: Dictionary = { "name": col_name, "type": TYPE_STRING, "type_name": "String", "hint": PROPERTY_HINT_NONE, "hint_string": "", "default": null }
	var tag: String = hint.trim_prefix("##type:")
	var parts: PackedStringArray = tag.split("|")
	var type_name: String = parts[0].strip_edges()

	meta["type"] = _name_to_type(type_name)
	meta["type_name"] = type_name

	# Parse extra hints
	for i: int in range(1, parts.size()):
		var extra: String = parts[i]
		if extra.begins_with("enum:"):
			meta["hint"] = PROPERTY_HINT_ENUM
			meta["hint_string"] = extra.trim_prefix("enum:")
		elif extra.begins_with("resource:"):
			meta["hint"] = PROPERTY_HINT_RESOURCE_TYPE
			meta["hint_string"] = extra.trim_prefix("resource:")

	return meta


func _name_to_type(name: String) -> int:
	match name:
		"bool": return TYPE_BOOL
		"int": return TYPE_INT
		"float": return TYPE_FLOAT
		"String": return TYPE_STRING
		"Vector2": return TYPE_VECTOR2
		"Vector2i": return TYPE_VECTOR2I
		"Vector3": return TYPE_VECTOR3
		"Vector3i": return TYPE_VECTOR3I
		"Vector4": return TYPE_VECTOR4
		"Vector4i": return TYPE_VECTOR4I
		"Color": return TYPE_COLOR
		"Rect2": return TYPE_RECT2
		"Rect2i": return TYPE_RECT2I
		"StringName": return TYPE_STRING_NAME
		"NodePath": return TYPE_NODE_PATH
		"Object": return TYPE_OBJECT
	return TYPE_STRING


# ── Internal ──────────────────────────────────────────────────────────

func _key(row: int, col: int) -> String:
	return "%d,%d" % [row, col]
