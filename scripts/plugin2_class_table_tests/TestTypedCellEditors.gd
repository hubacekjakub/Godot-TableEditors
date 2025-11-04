@tool
extends RefCounted

## Unit Tests for Typed Cell Editors
## Tests type-safe editing, validation, and specialized controls

const TypedCellEditorFactory = preload("res://addons/class_table_editor/utils/typed_cell_editor_factory.gd")

var test_results: Array[Dictionary] = []
var passed_count: int = 0
var failed_count: int = 0


func run_all_tests() -> void:
	"""Run all typed cell editor tests"""
	print("\n" + "=".repeat(60))
	print("Running Typed Cell Editor Tests")
	print("=".repeat(60))

	test_results.clear()
	passed_count = 0
	failed_count = 0

	# Run tests
	test_bool_editor_creation()
	test_int_editor_creation()
	test_float_editor_creation()
	test_string_editor_creation()
	test_vector2_editor_creation()
	test_vector3_editor_creation()
	test_color_editor_creation()

	test_bool_value_handling()
	test_int_value_handling()
	test_float_value_handling()
	test_string_value_handling()
	test_vector2_value_handling()
	test_vector3_value_handling()
	test_color_value_handling()

	test_type_validation()
	test_type_conversion()
	test_type_hint_display()

	# Print summary
	print("\n" + "=".repeat(60))
	print("Test Results Summary:")
	print("  Total: %d" % (passed_count + failed_count))
	print("  Passed: %d ✅" % passed_count)
	print("  Failed: %d ❌" % failed_count)
	print("=".repeat(60))

	if failed_count > 0:
		print("\nFailed Tests:")
		for result in test_results:
			if not result["passed"]:
				print("  ❌ %s: %s" % [result["name"], result["message"]])


## === Test: Editor Creation ===

func test_bool_editor_creation() -> void:
	var editor = TypedCellEditorFactory.create_editor(TYPE_BOOL, "bool")
	_assert("Bool editor is CheckBox", editor is CheckBox)
	_assert("Bool editor has correct type_id", editor.get_meta("type_id") == TYPE_BOOL)
	_assert("Bool editor has correct type_name", editor.get_meta("type_name") == "bool")


func test_int_editor_creation() -> void:
	var editor = TypedCellEditorFactory.create_editor(TYPE_INT, "int")
	_assert("Int editor is SpinBox", editor is SpinBox)
	_assert("Int editor has step=1", editor.step == 1)
	_assert("Int editor has correct type_id", editor.get_meta("type_id") == TYPE_INT)


func test_float_editor_creation() -> void:
	var editor = TypedCellEditorFactory.create_editor(TYPE_FLOAT, "float")
	_assert("Float editor is SpinBox", editor is SpinBox)
	_assert("Float editor has step=0.01", editor.step == 0.01)
	_assert("Float editor has correct type_id", editor.get_meta("type_id") == TYPE_FLOAT)


func test_string_editor_creation() -> void:
	var editor = TypedCellEditorFactory.create_editor(TYPE_STRING, "String")
	_assert("String editor is LineEdit", editor is LineEdit)
	_assert("String editor has correct type_id", editor.get_meta("type_id") == TYPE_STRING)


func test_vector2_editor_creation() -> void:
	var editor = TypedCellEditorFactory.create_editor(TYPE_VECTOR2, "Vector2")
	_assert("Vector2 editor is HBoxContainer", editor is HBoxContainer)
	_assert("Vector2 editor has SpinBoxX", editor.has_node("SpinBoxX"))
	_assert("Vector2 editor has SpinBoxY", editor.has_node("SpinBoxY"))
	_assert("Vector2 editor has correct type_id", editor.get_meta("type_id") == TYPE_VECTOR2)


func test_vector3_editor_creation() -> void:
	var editor = TypedCellEditorFactory.create_editor(TYPE_VECTOR3, "Vector3")
	_assert("Vector3 editor is HBoxContainer", editor is HBoxContainer)
	_assert("Vector3 editor has SpinBoxX", editor.has_node("SpinBoxX"))
	_assert("Vector3 editor has SpinBoxY", editor.has_node("SpinBoxY"))
	_assert("Vector3 editor has SpinBoxZ", editor.has_node("SpinBoxZ"))
	_assert("Vector3 editor has correct type_id", editor.get_meta("type_id") == TYPE_VECTOR3)


func test_color_editor_creation() -> void:
	var editor = TypedCellEditorFactory.create_editor(TYPE_COLOR, "Color")
	_assert("Color editor is ColorPickerButton", editor is ColorPickerButton)
	_assert("Color editor has correct type_id", editor.get_meta("type_id") == TYPE_COLOR)


## === Test: Value Handling ===

func test_bool_value_handling() -> void:
	var editor = TypedCellEditorFactory.create_editor(TYPE_BOOL, "bool")

	# Test set/get true
	TypedCellEditorFactory.set_editor_value(editor, true)
	var value = TypedCellEditorFactory.get_editor_value(editor)
	_assert("Bool editor stores true", value == true)

	# Test set/get false
	TypedCellEditorFactory.set_editor_value(editor, false)
	value = TypedCellEditorFactory.get_editor_value(editor)
	_assert("Bool editor stores false", value == false)


func test_int_value_handling() -> void:
	var editor = TypedCellEditorFactory.create_editor(TYPE_INT, "int")

	# Test positive int
	TypedCellEditorFactory.set_editor_value(editor, 42)
	var value = TypedCellEditorFactory.get_editor_value(editor)
	_assert("Int editor stores positive value", value == 42)

	# Test negative int
	TypedCellEditorFactory.set_editor_value(editor, -99)
	value = TypedCellEditorFactory.get_editor_value(editor)
	_assert("Int editor stores negative value", value == -99)

	# Test zero
	TypedCellEditorFactory.set_editor_value(editor, 0)
	value = TypedCellEditorFactory.get_editor_value(editor)
	_assert("Int editor stores zero", value == 0)


func test_float_value_handling() -> void:
	var editor = TypedCellEditorFactory.create_editor(TYPE_FLOAT, "float")

	# Test decimal value
	TypedCellEditorFactory.set_editor_value(editor, 3.14159)
	var value = TypedCellEditorFactory.get_editor_value(editor)
	_assert("Float editor stores decimal", abs(value - 3.14159) < 0.001)

	# Test negative float
	TypedCellEditorFactory.set_editor_value(editor, -2.5)
	value = TypedCellEditorFactory.get_editor_value(editor)
	_assert("Float editor stores negative", abs(value - (-2.5)) < 0.001)


func test_string_value_handling() -> void:
	var editor = TypedCellEditorFactory.create_editor(TYPE_STRING, "String")

	# Test regular string
	TypedCellEditorFactory.set_editor_value(editor, "Hello World")
	var value = TypedCellEditorFactory.get_editor_value(editor)
	_assert("String editor stores text", value == "Hello World")

	# Test empty string
	TypedCellEditorFactory.set_editor_value(editor, "")
	value = TypedCellEditorFactory.get_editor_value(editor)
	_assert("String editor stores empty string", value == "")


func test_vector2_value_handling() -> void:
	var editor = TypedCellEditorFactory.create_editor(TYPE_VECTOR2, "Vector2")

	# Test Vector2 value
	var test_vec = Vector2(10.5, -20.3)
	TypedCellEditorFactory.set_editor_value(editor, test_vec)
	var value = TypedCellEditorFactory.get_editor_value(editor)
	_assert("Vector2 editor stores Vector2", value.is_equal_approx(test_vec))

	# Test zero vector
	TypedCellEditorFactory.set_editor_value(editor, Vector2.ZERO)
	value = TypedCellEditorFactory.get_editor_value(editor)
	_assert("Vector2 editor stores ZERO", value.is_equal_approx(Vector2.ZERO))


func test_vector3_value_handling() -> void:
	var editor = TypedCellEditorFactory.create_editor(TYPE_VECTOR3, "Vector3")

	# Test Vector3 value
	var test_vec = Vector3(1.5, 2.5, 3.5)
	TypedCellEditorFactory.set_editor_value(editor, test_vec)
	var value = TypedCellEditorFactory.get_editor_value(editor)
	_assert("Vector3 editor stores Vector3", value.is_equal_approx(test_vec))

	# Test zero vector
	TypedCellEditorFactory.set_editor_value(editor, Vector3.ZERO)
	value = TypedCellEditorFactory.get_editor_value(editor)
	_assert("Vector3 editor stores ZERO", value.is_equal_approx(Vector3.ZERO))


func test_color_value_handling() -> void:
	var editor = TypedCellEditorFactory.create_editor(TYPE_COLOR, "Color")

	# Test Color value
	var test_color = Color(1.0, 0.5, 0.25, 0.8)
	TypedCellEditorFactory.set_editor_value(editor, test_color)
	var value = TypedCellEditorFactory.get_editor_value(editor)
	_assert("Color editor stores Color", value.is_equal_approx(test_color))

	# Test string conversion
	TypedCellEditorFactory.set_editor_value(editor, "#ff0000")
	value = TypedCellEditorFactory.get_editor_value(editor)
	_assert("Color editor converts from hex string", value.is_equal_approx(Color.RED))


## === Test: Type Validation ===

func test_type_validation() -> void:
	# Test bool validation
	var result = TypedCellEditorFactory.validate_value(TYPE_BOOL, true)
	_assert("Bool validation accepts bool", result["valid"])

	result = TypedCellEditorFactory.validate_value(TYPE_BOOL, "invalid")
	_assert("Bool validation rejects non-bool", not result["valid"])

	# Test int validation
	result = TypedCellEditorFactory.validate_value(TYPE_INT, 42)
	_assert("Int validation accepts int", result["valid"])

	result = TypedCellEditorFactory.validate_value(TYPE_INT, "invalid")
	_assert("Int validation rejects non-int", not result["valid"])

	# Test float validation
	result = TypedCellEditorFactory.validate_value(TYPE_FLOAT, 3.14)
	_assert("Float validation accepts float", result["valid"])

	result = TypedCellEditorFactory.validate_value(TYPE_FLOAT, "invalid")
	_assert("Float validation rejects non-float", not result["valid"])

	# Test string validation
	result = TypedCellEditorFactory.validate_value(TYPE_STRING, "text")
	_assert("String validation accepts string", result["valid"])

	# Test Vector2 validation
	result = TypedCellEditorFactory.validate_value(TYPE_VECTOR2, Vector2(1, 2))
	_assert("Vector2 validation accepts Vector2", result["valid"])

	result = TypedCellEditorFactory.validate_value(TYPE_VECTOR2, "invalid")
	_assert("Vector2 validation rejects non-Vector2", not result["valid"])

	# Test Color validation
	result = TypedCellEditorFactory.validate_value(TYPE_COLOR, Color.RED)
	_assert("Color validation accepts Color", result["valid"])


## === Test: Type Conversion ===

func test_type_conversion() -> void:
	# Test Vector2 from string
	var vec2 = TypedCellEditorFactory._parse_vector2_from_string("(10, 20)")
	_assert("Parse Vector2 from string", vec2.is_equal_approx(Vector2(10, 20)))

	vec2 = TypedCellEditorFactory._parse_vector2_from_string("")
	_assert("Parse empty Vector2 returns ZERO", vec2.is_equal_approx(Vector2.ZERO))

	# Test Vector3 from string
	var vec3 = TypedCellEditorFactory._parse_vector3_from_string("(1, 2, 3)")
	_assert("Parse Vector3 from string", vec3.is_equal_approx(Vector3(1, 2, 3)))

	vec3 = TypedCellEditorFactory._parse_vector3_from_string("")
	_assert("Parse empty Vector3 returns ZERO", vec3.is_equal_approx(Vector3.ZERO))


## === Test: Type Hint Display ===

func test_type_hint_display() -> void:
	# Test type hint text generation
	var hint = TypedCellEditorFactory.get_type_hint_text(TYPE_BOOL, "bool")
	_assert("Bool type hint", hint == "bool")

	hint = TypedCellEditorFactory.get_type_hint_text(TYPE_INT, "int")
	_assert("Int type hint", hint == "int")

	hint = TypedCellEditorFactory.get_type_hint_text(TYPE_FLOAT, "float")
	_assert("Float type hint", hint == "float")

	hint = TypedCellEditorFactory.get_type_hint_text(TYPE_STRING, "String")
	_assert("String type hint", hint == "String")

	hint = TypedCellEditorFactory.get_type_hint_text(TYPE_VECTOR2, "Vector2")
	_assert("Vector2 type hint", hint == "Vector2")

	hint = TypedCellEditorFactory.get_type_hint_text(TYPE_COLOR, "Color")
	_assert("Color type hint", hint == "Color")


## === Helper: Assertion Method ===

func _assert(test_name: String, condition: bool) -> void:
	"""Assert that a condition is true"""
	var result = {
		"name": test_name,
		"passed": condition,
		"message": "Passed" if condition else "Failed"
	}
	test_results.append(result)

	if condition:
		passed_count += 1
		print("  ✅ %s" % test_name)
	else:
		failed_count += 1
		print("  ❌ %s" % test_name)
