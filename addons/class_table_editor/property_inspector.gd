@tool
## PropertyInspector - Utility for inspecting GDScript properties using native Godot API
##
## This utility provides type-safe property introspection for GDScript classes
## without needing to instantiate them. It uses Godot's built-in get_script_property_list()
## API rather than regex parsing.
##
## Example usage:
##   var props = PropertyInspector.get_exported_properties("res://scripts/my_class.gd")

class_name PropertyInspector
extends RefCounted

## Generate a detailed property report from a script path (for debugging)
static func inspect_script(script_path: String) -> String:
	var script = load(script_path)
	if script == null:
		return "Error: Could not load script at path: " + script_path

	return inspect_script_resource(script)

## Generate a detailed property report from a script resource (for debugging)
static func inspect_script_resource(script: Script) -> String:
	var props = script.get_script_property_list()
	var output = "Properties from script:\n"

	for prop in props:
		if _is_exported(prop):
			output += "Name: %s\n" % prop.name
			output += "  Type: %s\n" % _type_to_string(prop.type)
			output += "  Usage Flags: %d\n" % prop.usage
			if prop.has("hint"):
				output += "  Hint: %d\n" % prop.hint
			if prop.has("hint_string") and prop.hint_string != "":
				output += "  Hint String: %s\n" % prop.hint_string
			output += "\n"

	return output

## Get only exported properties as an array of dictionaries
## Returns array of property dictionaries with enhanced metadata
static func get_exported_properties(script_path: String) -> Array:
	var script = load(script_path)
	if script == null:
		return []

	return get_exported_properties_from_script(script)

## Get only exported properties from a Script resource
static func get_exported_properties_from_script(script: Script) -> Array:
	var props = script.get_script_property_list()
	var exported: Array = []

	for prop in props:
		if _is_exported(prop):
			exported.append(prop)

	return exported

## Get exported properties with enhanced metadata (type names, defaults, etc)
static func get_property_metadata(script_path: String) -> Array[Dictionary]:
	var script = load(script_path)
	if script == null:
		return []

	var props = script.get_script_property_list()
	var metadata: Array[Dictionary] = []

	for prop in props:
		if _is_exported(prop):
			var meta: Dictionary = {
				"name": prop.name,
				"type": prop.type,
				"type_name": _type_to_string(prop.type),
				"usage": prop.usage,
				"exported": true,
			}

			# Add optional fields if present
			if prop.has("hint"):
				meta["hint"] = prop.hint
			if prop.has("hint_string"):
				meta["hint_string"] = prop.hint_string
			if prop.has("default"):
				meta["default"] = prop.default

			metadata.append(meta)

	return metadata

## Print property report directly to console (for debugging)
static func print_properties(script_path: String) -> void:
	print(inspect_script(script_path))

## Check if a property is exported and should be included
## Checks for both PROPERTY_USAGE_SCRIPT_VARIABLE and PROPERTY_USAGE_EDITOR flags
static func _is_exported(prop: Dictionary) -> bool:
	if not prop.has("usage"):
		return false

	# Property must be a script variable AND visible in editor
	var has_script_var = (prop.usage & PROPERTY_USAGE_SCRIPT_VARIABLE) != 0
	var has_editor = (prop.usage & PROPERTY_USAGE_EDITOR) != 0

	return has_script_var and has_editor

## Convert Godot type ID to human-readable string
## Supports all basic Godot types
static func _type_to_string(type_id: int) -> String:
	match type_id:
		TYPE_NIL: return "nil"
		TYPE_BOOL: return "bool"
		TYPE_INT: return "int"
		TYPE_FLOAT: return "float"
		TYPE_STRING: return "String"
		TYPE_VECTOR2: return "Vector2"
		TYPE_VECTOR2I: return "Vector2i"
		TYPE_RECT2: return "Rect2"
		TYPE_RECT2I: return "Rect2i"
		TYPE_VECTOR3: return "Vector3"
		TYPE_VECTOR3I: return "Vector3i"
		TYPE_TRANSFORM2D: return "Transform2D"
		TYPE_PLANE: return "Plane"
		TYPE_QUATERNION: return "Quaternion"
		TYPE_AABB: return "AABB"
		TYPE_BASIS: return "Basis"
		TYPE_TRANSFORM3D: return "Transform3D"
		TYPE_COLOR: return "Color"
		TYPE_NODE_PATH: return "NodePath"
		TYPE_RID: return "RID"
		TYPE_OBJECT: return "Object"
		TYPE_DICTIONARY: return "Dictionary"
		TYPE_ARRAY: return "Array"
		TYPE_PACKED_BYTE_ARRAY: return "PackedByteArray"
		TYPE_PACKED_INT32_ARRAY: return "PackedInt32Array"
		TYPE_PACKED_INT64_ARRAY: return "PackedInt64Array"
		TYPE_PACKED_FLOAT32_ARRAY: return "PackedFloat32Array"
		TYPE_PACKED_FLOAT64_ARRAY: return "PackedFloat64Array"
		TYPE_PACKED_STRING_ARRAY: return "PackedStringArray"
		TYPE_PACKED_VECTOR2_ARRAY: return "PackedVector2Array"
		TYPE_PACKED_VECTOR3_ARRAY: return "PackedVector3Array"
		TYPE_PACKED_COLOR_ARRAY: return "PackedColorArray"
		_: return "Unknown (%d)" % type_id

## Validate if a property type is supported for table storage
static func is_supported_type(type_id: int) -> bool:
	match type_id:
		TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING, TYPE_VECTOR2, \
		TYPE_VECTOR3, TYPE_COLOR, TYPE_OBJECT, TYPE_ARRAY, TYPE_DICTIONARY:
			return true
		_:
			return false

## Get all properties (exported and non-exported) from a script
## Useful for advanced introspection
static func get_all_properties(script_path: String) -> Array:
	var script = load(script_path)
	if script == null:
		return []

	return script.get_script_property_list()
