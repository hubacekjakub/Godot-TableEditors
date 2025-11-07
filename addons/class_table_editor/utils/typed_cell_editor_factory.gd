@tool
extends RefCounted
class_name TypedCellEditorFactory

## Factory for creating type-specific cell editors
## Creates LineEdit, SpinBox, CheckBox, ColorPicker, etc. based on column type

# UI Size Constants
const DEFAULT_CELL_WIDTH: int = 100  # Standard cell width
const DEFAULT_CELL_HEIGHT: int = 30  # Standard cell height
const VECTOR2_CELL_WIDTH: int = 150  # Width for Vector2 cells (2 components)
const VECTOR3_CELL_WIDTH: int = 220  # Width for Vector3 cells (3 components)
const VECTOR_COMPONENT_WIDTH: int = 60  # Width for individual X/Y/Z inputs in Vector2
const VECTOR3_COMPONENT_WIDTH: int = 50  # Width for individual X/Y/Z inputs in Vector3
const VECTOR_LABEL_WIDTH: int = 15  # Width for X:/Y:/Z: labels

## Create editor for a specific type
static func create_editor(type_id: int, type_name: String, metadata: Dictionary = {}) -> Control:
	match type_id:
		TYPE_BOOL:
			return _create_bool_editor(metadata)
		TYPE_INT:
			return _create_int_editor(metadata)
		TYPE_FLOAT:
			return _create_float_editor(metadata)
		TYPE_STRING:
			return _create_string_editor(metadata)
		TYPE_VECTOR2:
			return _create_vector2_editor(metadata)
		TYPE_VECTOR3:
			return _create_vector3_editor(metadata)
		TYPE_COLOR:
			return _create_color_editor(metadata)
		_:
			return _create_default_editor(metadata)


## Create CheckBox for boolean values
static func _create_bool_editor(metadata: Dictionary) -> CheckBox:
	var checkbox = CheckBox.new()
	checkbox.custom_minimum_size = Vector2(DEFAULT_CELL_WIDTH, DEFAULT_CELL_HEIGHT)
	checkbox.set_meta("type_id", TYPE_BOOL)
	checkbox.set_meta("type_name", "bool")
	checkbox.alignment = HORIZONTAL_ALIGNMENT_CENTER
	return checkbox


## Create SpinBox for integer values
static func _create_int_editor(metadata: Dictionary) -> SpinBox:
	var spinbox = SpinBox.new()
	spinbox.custom_minimum_size = Vector2(DEFAULT_CELL_WIDTH, DEFAULT_CELL_HEIGHT)
	spinbox.set_meta("type_id", TYPE_INT)
	spinbox.set_meta("type_name", "int")
	spinbox.step = 1
	spinbox.allow_greater = true
	spinbox.allow_lesser = true
	spinbox.min_value = metadata.get("min_value", -2147483648)
	spinbox.max_value = metadata.get("max_value", 2147483647)
	spinbox.alignment = HORIZONTAL_ALIGNMENT_CENTER
	return spinbox


## Create SpinBox for float values
static func _create_float_editor(metadata: Dictionary) -> SpinBox:
	var spinbox = SpinBox.new()
	spinbox.custom_minimum_size = Vector2(DEFAULT_CELL_WIDTH, DEFAULT_CELL_HEIGHT)
	spinbox.set_meta("type_id", TYPE_FLOAT)
	spinbox.set_meta("type_name", "float")
	spinbox.step = 0.01
	spinbox.allow_greater = true
	spinbox.allow_lesser = true
	spinbox.min_value = metadata.get("min_value", -999999.0)
	spinbox.max_value = metadata.get("max_value", 999999.0)
	spinbox.alignment = HORIZONTAL_ALIGNMENT_CENTER
	return spinbox


## Create LineEdit for string values
static func _create_string_editor(metadata: Dictionary) -> LineEdit:
	var line_edit = LineEdit.new()
	line_edit.custom_minimum_size = Vector2(DEFAULT_CELL_WIDTH, DEFAULT_CELL_HEIGHT)
	line_edit.set_meta("type_id", TYPE_STRING)
	line_edit.set_meta("type_name", "String")
	line_edit.placeholder_text = metadata.get("placeholder", "...")
	return line_edit


## Create specialized editor for Vector2
static func _create_vector2_editor(metadata: Dictionary) -> HBoxContainer:
	var container = HBoxContainer.new()
	container.custom_minimum_size = Vector2(VECTOR2_CELL_WIDTH, DEFAULT_CELL_HEIGHT)
	container.set_meta("type_id", TYPE_VECTOR2)
	container.set_meta("type_name", "Vector2")

	var label_x = Label.new()
	label_x.text = "X:"
	label_x.custom_minimum_size = Vector2(VECTOR_LABEL_WIDTH, 0)
	container.add_child(label_x)

	var spinbox_x = SpinBox.new()
	spinbox_x.name = "SpinBoxX"
	spinbox_x.step = 0.1
	spinbox_x.allow_greater = true
	spinbox_x.allow_lesser = true
	spinbox_x.custom_minimum_size = Vector2(VECTOR_COMPONENT_WIDTH, DEFAULT_CELL_HEIGHT)
	container.add_child(spinbox_x)

	var label_y = Label.new()
	label_y.text = "Y:"
	label_y.custom_minimum_size = Vector2(VECTOR_LABEL_WIDTH, 0)
	container.add_child(label_y)

	var spinbox_y = SpinBox.new()
	spinbox_y.name = "SpinBoxY"
	spinbox_y.step = 0.1
	spinbox_y.allow_greater = true
	spinbox_y.allow_lesser = true
	spinbox_y.custom_minimum_size = Vector2(VECTOR_COMPONENT_WIDTH, DEFAULT_CELL_HEIGHT)
	container.add_child(spinbox_y)

	return container


## Create specialized editor for Vector3
static func _create_vector3_editor(metadata: Dictionary) -> HBoxContainer:
	var container = HBoxContainer.new()
	container.custom_minimum_size = Vector2(VECTOR3_CELL_WIDTH, DEFAULT_CELL_HEIGHT)
	container.set_meta("type_id", TYPE_VECTOR3)
	container.set_meta("type_name", "Vector3")

	var label_x = Label.new()
	label_x.text = "X:"
	label_x.custom_minimum_size = Vector2(VECTOR_LABEL_WIDTH, 0)
	container.add_child(label_x)

	var spinbox_x = SpinBox.new()
	spinbox_x.name = "SpinBoxX"
	spinbox_x.step = 0.1
	spinbox_x.allow_greater = true
	spinbox_x.allow_lesser = true
	spinbox_x.custom_minimum_size = Vector2(VECTOR3_COMPONENT_WIDTH, DEFAULT_CELL_HEIGHT)
	container.add_child(spinbox_x)

	var label_y = Label.new()
	label_y.text = "Y:"
	label_y.custom_minimum_size = Vector2(VECTOR_LABEL_WIDTH, 0)
	container.add_child(label_y)

	var spinbox_y = SpinBox.new()
	spinbox_y.name = "SpinBoxY"
	spinbox_y.step = 0.1
	spinbox_y.allow_greater = true
	spinbox_y.allow_lesser = true
	spinbox_y.custom_minimum_size = Vector2(VECTOR3_COMPONENT_WIDTH, DEFAULT_CELL_HEIGHT)
	container.add_child(spinbox_y)

	var label_z = Label.new()
	label_z.text = "Z:"
	label_z.custom_minimum_size = Vector2(VECTOR_LABEL_WIDTH, 0)
	container.add_child(label_z)

	var spinbox_z = SpinBox.new()
	spinbox_z.name = "SpinBoxZ"
	spinbox_z.step = 0.1
	spinbox_z.allow_greater = true
	spinbox_z.allow_lesser = true
	spinbox_z.custom_minimum_size = Vector2(VECTOR3_COMPONENT_WIDTH, DEFAULT_CELL_HEIGHT)
	container.add_child(spinbox_z)

	return container


## Create ColorPickerButton for Color values
static func _create_color_editor(metadata: Dictionary) -> ColorPickerButton:
	var color_picker = ColorPickerButton.new()
	color_picker.custom_minimum_size = Vector2(DEFAULT_CELL_WIDTH, DEFAULT_CELL_HEIGHT)
	color_picker.set_meta("type_id", TYPE_COLOR)
	color_picker.set_meta("type_name", "Color")
	color_picker.edit_alpha = true
	return color_picker


## Create default LineEdit editor for unsupported types
static func _create_default_editor(metadata: Dictionary) -> LineEdit:
	var line_edit = LineEdit.new()
	line_edit.custom_minimum_size = Vector2(DEFAULT_CELL_WIDTH, DEFAULT_CELL_HEIGHT)
	line_edit.set_meta("type_id", TYPE_NIL)
	line_edit.set_meta("type_name", "Variant")
	line_edit.placeholder_text = "..."
	return line_edit


## Get value from editor control
static func get_editor_value(editor: Control) -> Variant:
	if editor is CheckBox:
		return editor.button_pressed
	elif editor is SpinBox:
		return editor.value
	elif editor is LineEdit:
		return editor.text
	elif editor is ColorPickerButton:
		return editor.color
	elif editor is HBoxContainer:
		# Vector2 or Vector3
		var type_id = editor.get_meta("type_id", TYPE_NIL)
		if type_id == TYPE_VECTOR2:
			var x = editor.get_node("SpinBoxX").value
			var y = editor.get_node("SpinBoxY").value
			return Vector2(x, y)
		elif type_id == TYPE_VECTOR3:
			var x = editor.get_node("SpinBoxX").value
			var y = editor.get_node("SpinBoxY").value
			var z = editor.get_node("SpinBoxZ").value
			return Vector3(x, y, z)
	return null


## Set value in editor control
static func set_editor_value(editor: Control, value: Variant) -> void:
	if editor is CheckBox:
		# Convert to bool properly - check for truthy values
		if value == null:
			editor.button_pressed = false
		elif value is bool:
			editor.button_pressed = value
		elif value is String:
			editor.button_pressed = value.to_lower() in ["true", "1", "yes"]
		else:
			editor.button_pressed = true if value else false
	elif editor is SpinBox:
		if value is String:
			editor.value = float(value) if value != "" else 0.0
		else:
			editor.value = float(value) if value != null else 0.0
	elif editor is LineEdit:
		editor.text = str(value) if value != null else ""
	elif editor is ColorPickerButton:
		if value is Color:
			editor.color = value
		elif value is String and value != "":
			editor.color = Color.from_string(value, Color.WHITE)
		else:
			editor.color = Color.WHITE
	elif editor is HBoxContainer:
		# Vector2 or Vector3
		var type_id = editor.get_meta("type_id", TYPE_NIL)
		if type_id == TYPE_VECTOR2:
			var vec = value if value is Vector2 else _parse_vector2_from_string(str(value))
			editor.get_node("SpinBoxX").value = vec.x
			editor.get_node("SpinBoxY").value = vec.y
		elif type_id == TYPE_VECTOR3:
			var vec = value if value is Vector3 else _parse_vector3_from_string(str(value))
			editor.get_node("SpinBoxX").value = vec.x
			editor.get_node("SpinBoxY").value = vec.y
			editor.get_node("SpinBoxZ").value = vec.z


## Validate value against type and return `{valid, error}` dictionary.
static func validate_value(type_id: int, value: Variant) -> Dictionary:
	if value == null:
		return {"valid": true, "error": ""}

	match type_id:
		TYPE_BOOL:
			if not (value is bool):
				return {"valid": false, "error": "Expected boolean value"}
		TYPE_INT:
			if not (value is int or value is float):
				return {"valid": false, "error": "Expected integer value"}
		TYPE_FLOAT:
			if not (value is float or value is int):
				return {"valid": false, "error": "Expected float value"}
		TYPE_STRING:
			if not (value is String):
				return {"valid": false, "error": "Expected string value"}
		TYPE_VECTOR2:
			if not (value is Vector2):
				return {"valid": false, "error": "Expected Vector2 value"}
		TYPE_VECTOR3:
			if not (value is Vector3):
				return {"valid": false, "error": "Expected Vector3 value"}
		TYPE_COLOR:
			if not (value is Color):
				return {"valid": false, "error": "Expected Color value"}

	return {"valid": true, "error": ""}


## Helper: Parse Vector2 from string
static func _parse_vector2_from_string(text: String) -> Vector2:
	if text == "":
		return Vector2.ZERO
	var clean = text.strip_edges().replace("(", "").replace(")", "")
	var parts = clean.split(",")
	if parts.size() >= 2:
		return Vector2(parts[0].to_float(), parts[1].to_float())
	return Vector2.ZERO


## Helper: Parse Vector3 from string
static func _parse_vector3_from_string(text: String) -> Vector3:
	if text == "":
		return Vector3.ZERO
	var clean = text.strip_edges().replace("(", "").replace(")", "")
	var parts = clean.split(",")
	if parts.size() >= 3:
		return Vector3(parts[0].to_float(), parts[1].to_float(), parts[2].to_float())
	return Vector3.ZERO


## Get type hint for column header display
static func get_type_hint_text(type_id: int, type_name: String) -> String:
	return "%s" % type_name


## Get type icon name (if available)
static func get_type_icon_name(type_id: int) -> String:
	match type_id:
		TYPE_BOOL:
			return "bool"
		TYPE_INT:
			return "int"
		TYPE_FLOAT:
			return "float"
		TYPE_STRING:
			return "String"
		TYPE_VECTOR2:
			return "Vector2"
		TYPE_VECTOR3:
			return "Vector3"
		TYPE_COLOR:
			return "Color"
		_:
			return "Variant"
