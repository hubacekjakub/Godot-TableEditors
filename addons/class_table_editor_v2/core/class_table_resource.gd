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


# ── Internal ──────────────────────────────────────────────────────────

func _key(row: int, col: int) -> String:
	return "%d,%d" % [row, col]
