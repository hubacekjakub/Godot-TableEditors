@tool
## ClassSelector - Utility for discovering and selecting GDScript classes (Strict Typing v3)
##
## This utility provides class discovery and selection functionality for
## auto-generating tables from GDScript class definitions.

class_name ClassSelector
extends RefCounted

## Cache for discovered classes
var _discovered_classes: Array[Dictionary] = []
var _last_scan_time: int = 0
const CACHE_DURATION_MS: int = 5000  # Refresh cache every 5 seconds


## Get all discovered classes in the project
## Optionally filter by class name or file path
func get_all_classes(force_rescan: bool = false) -> Array[Dictionary]:
	var current_time: int = Time.get_ticks_msec()

	# Use cache if recent enough
	if not force_rescan and _discovered_classes.size() > 0:
		if (current_time - _last_scan_time) < CACHE_DURATION_MS:
			return _discovered_classes

	# Rescan project for classes
	_discovered_classes = _scan_project_for_classes()
	_last_scan_time = current_time

	return _discovered_classes


## Get classes by filter predicate
func get_classes_filtered(predicate: Callable) -> Array[Dictionary]:
	var classes: Array[Dictionary] = get_all_classes()
	var filtered: Array[Dictionary] = []

	for cls in classes:
		if predicate.call(cls):
			filtered.append(cls)

	return filtered


## Get a specific class by file path
func get_class_by_path(file_path: String) -> Dictionary:
	var classes: Array[Dictionary] = get_all_classes()

	for cls in classes:
		if cls.get("file_path") == file_path:
			return cls

	return {}


## Get a specific class by name
func get_class_by_name(name: String) -> Dictionary:
	var classes: Array[Dictionary] = get_all_classes()

	for cls in classes:
		if cls.get("class_name") == name:
			return cls

	return {}


## Get classes that inherit from a specific parent class
func get_classes_inheriting_from(parent_class_name: String) -> Array[Dictionary]:
	return get_classes_filtered(func(cls: Dictionary) -> bool:
		var parent: String = cls.get("parent_class", "")
		return parent == parent_class_name
	)


## Get classes that are Resources or subclasses of Resource
func get_resource_classes() -> Array[Dictionary]:
	return get_classes_filtered(func(cls: Dictionary) -> bool:
		var parent = cls.get("parent_class", "")
		return parent == "Resource" or parent.begins_with("Resource")
	)


## Get classes that are NOT Resources
func get_non_resource_classes() -> Array[Dictionary]:
	return get_classes_filtered(func(cls: Dictionary) -> bool:
		var parent: String = cls.get("parent_class", "")
		return not (parent == "Resource" or parent.begins_with("Resource"))
	)


## Get classes with a minimum number of properties
func get_classes_with_min_properties(min_props: int) -> Array[Dictionary]:
	return get_classes_filtered(func(cls: Dictionary) -> bool:
		var props: Array = cls.get("properties", [])
		return props.size() >= min_props
	)


## Clear the cache and force a rescan on next access
func clear_cache() -> void:
	_discovered_classes.clear()
	_last_scan_time = 0


## === Internal Methods ===

## Scan the entire project for GDScript classes
func _scan_project_for_classes() -> Array[Dictionary]:
	var classes: Array[Dictionary] = []

	# Find all .gd files
	var gdscript_files: Array = ClassInspector.find_gdscript_files("res://")

	# Parse each file for class definitions
	for file_path in gdscript_files:
		var class_info: Dictionary = _parse_class_from_file(file_path)
		if class_info.size() > 0:
			classes.append(class_info)

	return classes


## Parse a single GDScript file to extract class definition
## Returns a dictionary with class info, or empty dict if not a class file
func _parse_class_from_file(file_path: String) -> Dictionary:
	var script: GDScript = load(file_path)
	if script == null:
		return {}

	# Get class name
	var cls_name: String = script.resource_name
	if cls_name.is_empty():
		cls_name = file_path.get_file().trim_suffix(".gd")

	# Get parent class (base class)
	var parent_class: String = _extract_parent_class(file_path)

	# Get properties using PropertyInspector
	var properties: Array = PropertyInspector.get_property_metadata(file_path)

	return {
		"class_name": cls_name,
		"file_path": file_path,
		"parent_class": parent_class,
		"properties": properties,
		"property_count": properties.size(),
	}


## Extract parent class name from GDScript file
## Looks for patterns like "extends ClassName" or "extends SomeModule.ClassName"
func _extract_parent_class(file_path: String) -> String:
	var file: FileAccess = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return ""

	var content: String = file.get_as_text()
	file.close()

	# Look for "extends" keyword
	var lines: PackedStringArray = content.split("\n")
	for line in lines:
		var trimmed: String = line.strip_edges()

		# Skip comments
		if trimmed.begins_with("#"):
			continue

		# Look for extends keyword
		if trimmed.begins_with("extends "):
			var parent: String = trimmed.trim_prefix("extends ").strip_edges()
			# Remove any trailing characters (like colons, comments, etc.)
			parent = parent.split(":")[0].strip_edges()
			parent = parent.split("#")[0].strip_edges()
			return parent

	return ""


## Format a class for display in a list
static func format_class_for_display(class_info: Dictionary) -> String:
	var cls_name: String = class_info.get("class_name", "Unknown")
	var prop_count: int = class_info.get("property_count", 0)
	var parent: String = class_info.get("parent_class", "")

	var display: String = "%s (%d properties)" % [cls_name, prop_count]
	if not parent.is_empty():
		display += " → %s" % parent

	return display
