@tool
extends Node
class_name TestClassParser

## Test script for ClassInspector functionality (formerly ClassParser)


func test_parser() -> void:
	print("\n=== Testing ClassInspector ===\n")

	var inspector = ClassInspector.new()

	# Test 1: Parse the test class file
	print("Test 1: Inspecting TestItemData.gd...")
	var result = inspector.inspect_class("res://scripts/plugin2_class_table_tests/TestItemData.gd")

	print("  Class name: ", result.get("class_name"))
	print("  File path: ", result.get("file_path"))

	var properties = result.get("properties", [])
	print("  Properties found: ", properties.size())

	for prop in properties:
		print("    - ", prop["name"], ": ", PropertyInspector._type_to_string(prop["type"]),
			  " (exported: true, default: ", prop.get("default"), ")")

	# Verify results (only exported properties are included)
	assert(result.get("class_name") == "TestItemData", "Class name mismatch")
	assert(properties.size() == 5, "Expected 5 exported properties, got " + str(properties.size()))

	# Check specific properties
	var item_name_prop = properties[0]
	assert(item_name_prop["name"] == "item_name", "First property should be item_name")
	assert(item_name_prop["type"] == TYPE_STRING, "item_name should be String")
	assert(item_name_prop.get("default") == "Sword", "item_name default should be 'Sword'")

	var damage_prop = properties[1]
	assert(damage_prop["name"] == "damage", "Second property should be damage")
	assert(damage_prop["type"] == TYPE_INT, "damage should be int")
	assert(damage_prop.get("default") == 10, "damage default should be 10")

	var rarity_prop = properties[4]
	assert(rarity_prop["name"] == "rarity", "Fifth property should be rarity")
	assert(rarity_prop["type"] == TYPE_FLOAT, "rarity should be float")
	assert(rarity_prop.get("default") == 0.8 or rarity_prop.get("default") == 0, "rarity should have default")

	print("\n✅ ClassInspector test PASSED!\n")


func test_parser_code_strings() -> void:
	print("=== Testing Class Discovery ===\n")

	print("Test 2: Finding all GDScript classes in project...")
	var classes = ClassInspector.find_gdscript_classes("res://scripts/")

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


func test_find_classes() -> void:
	print("=== Testing Script File Discovery ===\n")

	print("Test 3: Finding all GDScript files in project...")
	var files = ClassInspector.find_gdscript_files("res://scripts/")

	print("  Files found: ", files.size())
	for file in files:
		if not file.begins_with("res://scripts/Test"):
			continue
		print("    - ", file.get_file())

	# Should find test scripts
	assert(files.size() > 0, "Should find at least one file")

	var found_test_data = false
	for file in files:
		if file.contains("TestItemData.gd"):
			found_test_data = true
			break

	assert(found_test_data, "Should find TestItemData.gd file")

	print("\n✅ File discovery test PASSED!\n")

