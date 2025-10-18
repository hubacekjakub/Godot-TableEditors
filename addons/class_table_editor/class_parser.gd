@tool
class_name ClassParser
extends RefCounted

## GDScript class parser utility for extracting class properties and metadata

## Pattern to match variable declarations with type annotations
## Matches: var name: Type or var name: Type = default
const VAR_PATTERN = r"^\s*(?:@export\s+)?var\s+(\w+)\s*:\s*([^\s=]+)\s*(?:=\s*(.+?))?(?:\s*#.*)?$"

## Pattern to match @export decorator
const EXPORT_PATTERN = r"@export"

## Pattern to match class declaration
const CLASS_PATTERN = r"^class_name\s+(\w+)"


## Parse a GDScript file and extract class structure
## Returns: {
##   "class_name": String,
##   "properties": Array[Dictionary]  # Each: {name, type, default, is_exported}
## }
func parse_class(file_path: String) -> Dictionary:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		push_error("Failed to open file: ", file_path)
		return {}

	var code = file.get_as_text()
	return parse_code(code, file_path)


## Parse GDScript code directly (useful for testing)
func parse_code(code: String, file_path: String = "") -> Dictionary:
	var extracted_class_name = _extract_class_name(code)
	var properties = extract_properties(code)

	return {
		"class_name": extracted_class_name,
		"file_path": file_path,
		"properties": properties
	}


## Extract all class properties from code
func extract_properties(code: String) -> Array[Dictionary]:
	var properties: Array[Dictionary] = []
	var lines = code.split("\n")

	var regex = RegEx.new()
	regex.compile(VAR_PATTERN)

	for line in lines:
		# Try to match variable declaration (with or without @export)
		var match = regex.search(line)
		if match:
			var prop_name = match.get_string(1)
			var prop_type = match.get_string(2)
			var default_value = match.get_string(3)
			var is_exported = "@export" in line

			properties.append({
				"name": prop_name,
				"type": prop_type,
				"default": _parse_default_value(default_value) if default_value else null,
				"is_exported": is_exported
			})

	return properties


## Extract class name from code
func _extract_class_name(code: String) -> String:
	var regex = RegEx.new()
	regex.compile(CLASS_PATTERN)

	for line in code.split("\n"):
		var match = regex.search(line)
		if match:
			return match.get_string(1)

	return ""


## Parse default value from string representation
## Handles: literals, strings, booleans, etc.
func _parse_default_value(value_str: String) -> Variant:
	if value_str == null or value_str.is_empty():
		return null

	value_str = value_str.strip_edges()

	# String literals
	if value_str.begins_with('"') and value_str.ends_with('"'):
		return value_str.trim_prefix('"').trim_suffix('"')

	# Boolean
	if value_str == "true":
		return true
	if value_str == "false":
		return false

	# Null
	if value_str == "null":
		return null

	# Integer
	if value_str.is_valid_int():
		return int(value_str)

	# Float
	if value_str.is_valid_float():
		return float(value_str)

	# Otherwise, return as string (could be enum, constant reference, etc.)
	return value_str


## Get list of all GDScript files in project
static func find_gdscript_files(search_path: String = "res://") -> Array[String]:
	var gdscript_files: Array[String] = []
	var dir = DirAccess.open(search_path)

	if dir == null:
		return gdscript_files

	dir.list_dir_begin()
	var file_name = dir.get_next()

	while file_name != "":
		# Skip hidden files and addons
		if file_name.begins_with("."):
			file_name = dir.get_next()
			continue

		var full_path = search_path.path_join(file_name)

		if dir.current_is_dir():
			# Recurse into directories (except addons)
			if file_name != "addons":
				gdscript_files.append_array(find_gdscript_files(full_path))
		else:
			# Add .gd files
			if file_name.ends_with(".gd"):
				gdscript_files.append(full_path)

		file_name = dir.get_next()

	return gdscript_files


## Get list of GDScript classes in project
## Returns: Array of {class_name, file_path, properties}
static func find_gdscript_classes(search_path: String = "res://") -> Array[Dictionary]:
	var classes: Array[Dictionary] = []
	var files = find_gdscript_files(search_path)
	var parser = ClassParser.new()

	for file_path in files:
		var result = parser.parse_class(file_path)
		if result.get("class_name", "") != "":
			classes.append(result)

	return classes
