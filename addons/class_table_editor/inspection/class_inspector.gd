@tool
## ClassInspector - Utility for inspecting GDScript classes and their properties
##
## Uses Godot's native property introspection API (Script.get_script_property_list())
## instead of regex parsing. This is more accurate, faster, and easier to maintain.

class_name ClassInspector
extends RefCounted

## Inspect a GDScript class and extract its structure
func inspect_class(file_path: String) -> Dictionary:
	var script = load(file_path)
	if script == null:
		push_error("Failed to load script: " + file_path)
		return {}

	var class_name_str = script.resource_name
	if class_name_str.is_empty():
		class_name_str = file_path.get_file().trim_suffix(".gd")

	# Get exported properties using native API
	var properties = PropertyInspector.get_exported_properties_from_script(script)

	return {
		"class_name": class_name_str,
		"file_path": file_path,
		"properties": properties
	}


## Get class metadata with enhanced type information
func inspect_class_metadata(file_path: String) -> Dictionary:
	var script = load(file_path)
	if script == null:
		push_error("Failed to load script: " + file_path)
		return {}

	var class_name_str = script.resource_name
	if class_name_str.is_empty():
		class_name_str = file_path.get_file().trim_suffix(".gd")

	# Get enhanced metadata
	var properties = PropertyInspector.get_property_metadata(file_path)

	return {
		"class_name": class_name_str,
		"file_path": file_path,
		"properties": properties
	}


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
			if file_name != "addons":
				gdscript_files.append_array(find_gdscript_files(full_path))
		else:
			if file_name.ends_with(".gd"):
				gdscript_files.append(full_path)

		file_name = dir.get_next()

	return gdscript_files


## Get list of GDScript classes in project
static func find_gdscript_classes(search_path: String = "res://") -> Array[Dictionary]:
	var classes: Array[Dictionary] = []
	var files = find_gdscript_files(search_path)
	var inspector = ClassInspector.new()

	for file_path in files:
		var result = inspector.inspect_class(file_path)
		if result.get("class_name", "") != "":
			classes.append(result)

	return classes


## Print a detailed inspection report for a class
static func print_class_report(file_path: String) -> void:
	var inspector = ClassInspector.new()
	var metadata = inspector.inspect_class_metadata(file_path)

	if OS.is_debug_build():
		print("\n=== Class Inspection Report ===")
		print("Class: %s" % metadata.get("class_name", "Unknown"))
		print("File: %s" % metadata.get("file_path", "Unknown"))
		print("\nProperties:")

		for prop in metadata.get("properties", []):
			print("  - %s: %s" % [prop.get("name", "?"), prop.get("type_name", "?")])
			if prop.has("default"):
				print("    Default: %s" % prop.get("default"))
		print("=".repeat(30))

