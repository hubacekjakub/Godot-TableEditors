@tool
extends Node
class_name TestClassParser

## Test script for ClassParser functionality


func test_parser() -> void:
	print("\n=== Testing ClassParser ===\n")

	var parser = ClassParser.new()

	# Test 1: Parse the test class file
	print("Test 1: Parsing TestItemData.gd...")
	var result = parser.parse_class("res://scripts/TestItemData.gd")

	print("  Class name: ", result.get("class_name"))
	print("  File path: ", result.get("file_path"))

	var properties = result.get("properties", [])
	print("  Properties found: ", properties.size())

	for prop in properties:
		print("    - ", prop["name"], ": ", prop["type"],
			  " (exported: ", prop["is_exported"], ", default: ", prop["default"], ")")

	# Verify results
	assert(result.get("class_name") == "TestItemData", "Class name mismatch")
	assert(properties.size() == 6, "Expected 6 properties, got " + str(properties.size()))

	# Check specific properties
	var item_name_prop = properties[0]
	assert(item_name_prop["name"] == "item_name", "First property should be item_name")
	assert(item_name_prop["type"] == "String", "item_name should be String")
	assert(item_name_prop["is_exported"] == true, "item_name should be exported")
	assert(item_name_prop["default"] == "Sword", "item_name default should be 'Sword'")

	var damage_prop = properties[1]
	assert(damage_prop["name"] == "damage", "Second property should be damage")
	assert(damage_prop["type"] == "int", "damage should be int")
	assert(damage_prop["is_exported"] == true, "damage should be exported")
	assert(damage_prop["default"] == 10, "damage default should be 10")

	var description_prop = properties[4]
	assert(description_prop["name"] == "description", "Fifth property should be description")
	assert(description_prop["is_exported"] == false, "description should not be exported")
	assert(description_prop["default"] == "A sharp blade", "description default should be correct")

	print("\n✅ ClassParser test PASSED!\n")


func test_parser_code_strings() -> void:
	print("=== Testing ClassParser with Code Strings ===\n")

	var parser = ClassParser.new()

	# Test 2: Parse code directly
	print("Test 2: Parsing GDScript code string...")
	var code = """
extends Resource
class_name ItemData

@export var name: String = "Item"
@export var value: int = 100
var internal: bool = false
"""

	var result = parser.parse_code(code)
	print("  Class name: ", result.get("class_name"))

	var properties = result.get("properties", [])
	print("  Properties: ", properties.size())

	assert(result.get("class_name") == "ItemData", "Code parse class name mismatch")
	assert(properties.size() == 3, "Code parse property count mismatch")

	print("\n✅ Code string parsing test PASSED!\n")


func test_find_classes() -> void:
	print("=== Testing Class Discovery ===\n")

	print("Test 3: Finding all GDScript classes in project...")
	var classes = ClassParser.find_gdscript_classes("res://scripts/")

	print("  Classes found: ", classes.size())
	for cls in classes:
		print("    - ", cls["class_name"], " (", cls["file_path"], ")")
		if cls.has("properties"):
			print("      Properties: ", cls["properties"].size())

	# Should find at least TestItemData
	assert(classes.size() > 0, "Should find at least one class")

	var found_test_class = false
	for cls in classes:
		if cls["class_name"] == "TestItemData":
			found_test_class = true
			break

	assert(found_test_class, "Should find TestItemData class")

	print("\n✅ Class discovery test PASSED!\n")
