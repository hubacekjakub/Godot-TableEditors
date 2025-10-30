@tool
extends RefCounted
class_name TypedCellEditor

## Base class for type-specific cell editors
## Provides validation and specialized input controls for different data types

signal value_changed(new_value: Variant)
signal validation_error(error_message: String)

var control: Control = null
var type_id: int = TYPE_NIL
var type_name: String = ""
var metadata: Dictionary = {}


func _init(p_type_id: int, p_type_name: String, p_metadata: Dictionary = {}) -> void:
	type_id = p_type_id
	type_name = p_type_name
	metadata = p_metadata


## Create the editor control for this type
func create_control() -> Control:
	push_error("TypedCellEditor.create_control() must be overridden")
	return null


## Set the current value in the editor
func set_value(value: Variant) -> void:
	push_error("TypedCellEditor.set_value() must be overridden")


## Get the current value from the editor
func get_value() -> Variant:
	push_error("TypedCellEditor.get_value() must be overridden")
	return null


## Validate the current value
func validate(value: Variant) -> Dictionary:
	## Returns `{valid, error}` dictionary.
	return {"valid": true, "error": ""}


## Check if value matches expected type
func is_valid_type(value: Variant) -> bool:
	if value == null:
		return true

	match type_id:
		TYPE_BOOL:
			return value is bool
		TYPE_INT:
			return value is int or value is float  # Allow conversion
		TYPE_FLOAT:
			return value is float or value is int  # Allow conversion
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
		_:
			return true


## Convert string to typed value
func parse_from_string(text: String) -> Variant:
	match type_id:
		TYPE_BOOL:
			return text.to_lower() in ["true", "1", "yes"]
		TYPE_INT:
			return text.to_int()
		TYPE_FLOAT:
			return text.to_float()
		TYPE_STRING:
			return text
		TYPE_VECTOR2:
			return _parse_vector2(text)
		TYPE_VECTOR3:
			return _parse_vector3(text)
		TYPE_COLOR:
			return _parse_color(text)
		_:
			return text


## Convert typed value to string
func format_to_string(value: Variant) -> String:
	if value == null:
		return ""

	match type_id:
		TYPE_BOOL:
			return "true" if value else "false"
		TYPE_INT, TYPE_FLOAT:
			return str(value)
		TYPE_STRING:
			return value
		TYPE_VECTOR2:
			return "(%s, %s)" % [value.x, value.y]
		TYPE_VECTOR3:
			return "(%s, %s, %s)" % [value.x, value.y, value.z]
		TYPE_COLOR:
			return value.to_html()
		_:
			return str(value)


## Helper: Parse Vector2 from string
func _parse_vector2(text: String) -> Vector2:
	var clean = text.strip_edges().replace("(", "").replace(")", "")
	var parts = clean.split(",")
	if parts.size() >= 2:
		return Vector2(parts[0].to_float(), parts[1].to_float())
	return Vector2.ZERO


## Helper: Parse Vector3 from string
func _parse_vector3(text: String) -> Vector3:
	var clean = text.strip_edges().replace("(", "").replace(")", "")
	var parts = clean.split(",")
	if parts.size() >= 3:
		return Vector3(parts[0].to_float(), parts[1].to_float(), parts[2].to_float())
	return Vector3.ZERO


## Helper: Parse Color from string
func _parse_color(text: String) -> Color:
	if text.begins_with("#"):
		return Color.from_string(text, Color.WHITE)
	# Try parsing as (r, g, b, a)
	var clean = text.strip_edges().replace("(", "").replace(")", "")
	var parts = clean.split(",")
	if parts.size() >= 3:
		var r = parts[0].to_float()
		var g = parts[1].to_float()
		var b = parts[2].to_float()
		var a = parts[3].to_float() if parts.size() >= 4 else 1.0
		return Color(r, g, b, a)
	return Color.WHITE

