@tool
extends Node
class_name TestClassTableResource

## Test script for ClassTableResource type management


func test_resource() -> void:
	print("\n=== Testing ClassTableResource ===\n")

	var resource = ClassTableResource.new()

	# Test 1: Create resource with class metadata
	print("Test 1: Creating resource with class metadata...")
	resource.source_class_name = "ItemData"
	resource.class_file_path = "res://scripts/TestItemData.gd"
	resource.sheet_name = "Items"

	print("  Class name: ", resource.source_class_name)
	print("  Sheet name: ", resource.sheet_name)
	print("  File path: ", resource.class_file_path)

	# Test 2: Add columns with type information
	print("\nTest 2: Adding typed columns...")
	resource.add_column_with_type("item_name", "String", "Sword", true)
	resource.add_column_with_type("damage", "int", 10, true)
	resource.add_column_with_type("armor", "float", 2.5, true)
	resource.add_column_with_type("is_stackable", "bool", true, true)

	print("  Columns added: ", resource.column_count)
	assert(resource.column_count == 4, "Should have 4 columns")

	# Test 3: Verify column type metadata
	print("\nTest 3: Verifying column type metadata...")
	var col0 = resource.get_column_type_info(0)
	print("  Column 0: ", col0["name"], " (type: ", col0["type"], ", default: ", col0["default"], ")")
	assert(col0["name"] == "item_name", "Column 0 name mismatch")
	assert(col0["type"] == "String", "Column 0 type mismatch")
	assert(col0["is_exported"] == true, "Column 0 should be exported")

	var col1 = resource.get_column_type_info(1)
	print("  Column 1: ", col1["name"], " (type: ", col1["type"], ", default: ", col1["default"], ")")
	assert(col1["type"] == "int", "Column 1 type should be int")
	assert(col1["default"] == 10, "Column 1 default should be 10")

	# Test 4: Add rows and set cells
	print("\nTest 4: Adding rows with data...")
	resource.add_row("Row 1")
	resource.add_row("Row 2")
	resource.add_row("Row 3")

	print("  Rows added: ", resource.row_count)
	assert(resource.row_count == 3, "Should have 3 rows")

	# Set some values
	resource.set_cell(0, 0, "Iron Sword")
	resource.set_cell(0, 1, "15")
	resource.set_cell(0, 2, "3.0")

	print("  Row 0, Col 0: ", resource.get_cell(0, 0))
	print("  Row 0, Col 1: ", resource.get_cell(0, 1))

	# Test 5: Type validation
	print("\nTest 5: Testing type validation...")

	# Validate String column
	var valid_string = resource.validate_cell(0, 0, "Some String")
	print("  String validation: ", valid_string)
	assert(valid_string, "Should validate string")

	# Validate int column
	var valid_int = resource.validate_cell(0, 1, 42)
	print("  Int validation: ", valid_int)
	assert(valid_int, "Should validate int")

	# Validate float column
	var valid_float = resource.validate_cell(0, 2, 1.5)
	print("  Float validation: ", valid_float)
	assert(valid_float, "Should validate float")

	# Test 6: Get metadata
	print("\nTest 6: Getting resource metadata...")
	var meta = resource.get_metadata()
	print("  Metadata: ", meta)
	assert(meta["class_name"] == "ItemData", "Metadata class_name mismatch")
	assert(meta["column_count"] == 4, "Metadata column_count mismatch")
	assert(meta["row_count"] == 3, "Metadata row_count mismatch")

	# Test 7: Add column from PropertyInfo (simulating parser output)
	print("\nTest 7: Adding column from PropertyInfo...")
	var prop_info = {
		"name": "rarity",
		"type": "float",
		"default": 0.8,
		"is_exported": true
	}
	resource.add_column_from_property(prop_info)

	print("  Column count after property add: ", resource.column_count)
	assert(resource.column_count == 5, "Should have 5 columns after property add")

	var new_col = resource.get_column_type_info(4)
	print("  New column: ", new_col["name"], " (", new_col["type"], ")")
	assert(new_col["name"] == "rarity", "New column name mismatch")

	print("\n✅ ClassTableResource test PASSED!\n")


func test_type_validation() -> void:
	print("=== Testing Type Validation ===\n")

	var resource = ClassTableResource.new()

	# Add various typed columns
	resource.add_column_with_type("test_string", "String", "default")
	resource.add_column_with_type("test_int", "int", 0)
	resource.add_column_with_type("test_float", "float", 0.0)
	resource.add_column_with_type("test_bool", "bool", false)
	resource.add_column_with_type("test_color", "Color", Color.WHITE)
	resource.add_column_with_type("test_vector2", "Vector2", Vector2.ZERO)

	resource.add_row()

	print("Test: Type validation for each type...")

	# String
	assert(resource.validate_cell(0, 0, "test"), "String validation failed")
	print("  ✓ String")

	# int
	assert(resource.validate_cell(0, 1, 42), "int validation failed")
	print("  ✓ int")

	# float
	assert(resource.validate_cell(0, 2, 3.14), "float validation failed")
	print("  ✓ float")

	# bool
	assert(resource.validate_cell(0, 3, true), "bool validation failed")
	print("  ✓ bool")

	# Color
	assert(resource.validate_cell(0, 4, Color.RED), "Color validation failed")
	print("  ✓ Color")

	# Vector2
	assert(resource.validate_cell(0, 5, Vector2(1, 2)), "Vector2 validation failed")
	print("  ✓ Vector2")

	print("\n✅ Type validation test PASSED!\n")
