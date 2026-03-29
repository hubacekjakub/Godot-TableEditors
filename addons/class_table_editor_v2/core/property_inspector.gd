@tool
class_name PropertyInspectorV2
extends RefCounted
## Extracts @export property metadata from GDScript classes.
## Uses Script.get_script_property_list() — no regex.
## Instantiates the class once to capture default values.

# Cached results: script_path → { mtime: int, properties: Array[Dictionary] }
static var _cache: Dictionary = {}


## Returns metadata for all @export properties of a script.
## Each entry: { name, type, type_name, hint, hint_string, default }
static func get_exported_properties(script_path: String) -> Array[Dictionary]:
	if not ResourceLoader.exists(script_path):
		push_warning("PropertyInspectorV2: script not found: %s" % script_path)
		return []

	# Check cache with mtime invalidation
	var mtime: int = FileAccess.get_modified_time(script_path)
	if _cache.has(script_path):
		var cached: Dictionary = _cache[script_path]
		if cached.get("mtime", -1) == mtime:
			return cached["properties"]

	var script: Script = load(script_path)
	if script == null:
		push_warning("PropertyInspectorV2: failed to load script: %s" % script_path)
		return []

	# Get all properties from the script
	var raw_props: Array[Dictionary] = script.get_script_property_list()

	# Get defaults by instantiation
	var defaults: Dictionary = _extract_defaults(script)

	# Filter to @export only and build metadata
	var result: Array[Dictionary] = []
	for prop: Dictionary in raw_props:
		if not _is_exported(prop):
			continue
		if not is_supported_type(prop["type"]):
			continue

		var meta: Dictionary = {
			"name": prop["name"],
			"type": prop["type"],
			"type_name": type_to_name(prop["type"]),
			"hint": prop.get("hint", PROPERTY_HINT_NONE),
			"hint_string": prop.get("hint_string", ""),
			"default": defaults.get(prop["name"]),
		}
		result.append(meta)

	# Cache the result
	_cache[script_path] = { "mtime": mtime, "properties": result }
	return result


## Clears the cache (e.g. when scripts are modified externally).
static func invalidate_cache(script_path: String = "") -> void:
	if script_path.is_empty():
		_cache.clear()
	else:
		_cache.erase(script_path)


## Returns the class name from a script file.
static func get_class_name(script_path: String) -> String:
	var script: Script = load(script_path)
	if script == null:
		return ""
	var name: String = script.get_global_name()
	if name.is_empty():
		name = script_path.get_file().get_basename()
	return name


## Whether a Godot type is supported for table columns.
static func is_supported_type(type: int) -> bool:
	return type in [
		TYPE_BOOL, TYPE_INT, TYPE_FLOAT, TYPE_STRING,
		TYPE_VECTOR2, TYPE_VECTOR2I, TYPE_VECTOR3, TYPE_VECTOR3I,
		TYPE_VECTOR4, TYPE_VECTOR4I,
		TYPE_COLOR, TYPE_RECT2, TYPE_RECT2I,
		TYPE_STRING_NAME, TYPE_NODE_PATH,
		TYPE_OBJECT,
	]


## Converts a Godot TYPE_* constant to a human-readable string.
static func type_to_name(type: int) -> String:
	match type:
		TYPE_BOOL: return "bool"
		TYPE_INT: return "int"
		TYPE_FLOAT: return "float"
		TYPE_STRING: return "String"
		TYPE_VECTOR2: return "Vector2"
		TYPE_VECTOR2I: return "Vector2i"
		TYPE_VECTOR3: return "Vector3"
		TYPE_VECTOR3I: return "Vector3i"
		TYPE_VECTOR4: return "Vector4"
		TYPE_VECTOR4I: return "Vector4i"
		TYPE_COLOR: return "Color"
		TYPE_RECT2: return "Rect2"
		TYPE_RECT2I: return "Rect2i"
		TYPE_STRING_NAME: return "StringName"
		TYPE_NODE_PATH: return "NodePath"
		TYPE_OBJECT: return "Object"
	return "Variant"


# ── Internal ──────────────────────────────────────────────────────────

static func _is_exported(prop: Dictionary) -> bool:
	var usage: int = prop.get("usage", 0)
	var has_script_var: bool = (usage & PROPERTY_USAGE_SCRIPT_VARIABLE) != 0
	var has_editor: bool = (usage & PROPERTY_USAGE_EDITOR) != 0
	return has_script_var and has_editor


static func _extract_defaults(script: Script) -> Dictionary:
	var defaults: Dictionary = {}
	# Try to instantiate the class to read default values
	var instance: Variant = script.new()
	if instance == null:
		return defaults

	for prop: Dictionary in script.get_script_property_list():
		if _is_exported(prop):
			defaults[prop["name"]] = instance.get(prop["name"])

	# Clean up if it's a RefCounted (otherwise it self-frees)
	if instance is Object and not (instance is RefCounted):
		instance.free()

	return defaults
