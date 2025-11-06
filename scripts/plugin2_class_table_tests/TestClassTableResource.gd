@tool
extends Node
class_name TestClassTableResource

## Test script for ClassTableResource type management

func run_all_tests() -> void:
	test_resource()
	test_type_validation()
	test_csv_export_import()


func test_resource() -> void:
	print("\n=== Testing ClassTableResource ===\n")

	var resource = ClassTableResource.new()

	# Test 1: Create resource with class metadata
	print("Test 1: Creating resource with class metadata...")
	resource.source_class_name = "ItemData"
	resource.class_file_path = "res://scripts/plugin2_class_table_tests/TestItemData.gd"
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
	print("  Column 0: ", col0["name"], " (type: ", col0["type_name"], ", default: ", col0["default"], ")")
	assert(col0["name"] == "item_name", "Column 0 name mismatch")
	assert(col0["type_name"] == "String", "Column 0 type mismatch")
	assert(col0["exported"] == true, "Column 0 should be exported")

	var col1 = resource.get_column_type_info(1)
	print("  Column 1: ", col1["name"], " (type: ", col1["type_name"], ", default: ", col1["default"], ")")
	assert(col1["type_name"] == "int", "Column 1 type should be int")
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


func test_csv_export_import() -> void:
	print("=== Testing CSV Export/Import ===\n")

	var resource = ClassTableResource.new()

	# Setup test data
	resource.source_class_name = "TestItem"
	resource.class_file_path = "res://scripts/plugin2_class_table_tests/TestItemData.gd"
	resource.sheet_name = "Test Items"

	# Add columns with different types
	resource.add_column_with_type("name", "String", "Default Item", true)
	resource.add_column_with_type("damage", "int", 10, true)
	resource.add_column_with_type("speed", "float", 1.5, true)
	resource.add_column_with_type("is_magic", "bool", false, true)

	# Add rows with data
	resource.add_row("Sword")
	resource.add_row("Bow")
	resource.add_row("Staff")

	# Set cell values
	resource.set_cell(0, 0, "Iron Sword")
	resource.set_cell(0, 1, "15")
	resource.set_cell(0, 2, "2.5")
	resource.set_cell(0, 3, "false")

	resource.set_cell(1, 0, "Elven Bow")
	resource.set_cell(1, 1, "8")
	resource.set_cell(1, 2, "3.0")
	resource.set_cell(1, 3, "true")

	resource.set_cell(2, 0, "Wizard Staff")
	resource.set_cell(2, 1, "25")
	resource.set_cell(2, 2, "1.0")
	resource.set_cell(2, 3, "true")

	print("Test data setup complete:")
	print("  Columns: ", resource.column_count)
	print("  Rows: ", resource.row_count)

	# Test CSV export
	var export_path = "res://test_export.csv"
	var export_result = resource.export_to_csv(export_path)
	print("  Export result: ", export_result)
	assert(export_result == true, "CSV export should succeed")

	# Verify export file exists and has content
	var file = FileAccess.open(export_path, FileAccess.READ)
	assert(file != null, "Export file should exist")
	var csv_content = file.get_as_text()
	file.close()
	print("  Exported CSV content:")
	print(csv_content)

	# Verify CSV headers contain type information
	assert(csv_content.contains("name:String"), "CSV should contain typed headers")
	assert(csv_content.contains("damage:int"), "CSV should contain int type")
	assert(csv_content.contains("speed:float"), "CSV should contain float type")
	assert(csv_content.contains("is_magic:bool"), "CSV should contain bool type")

	# Verify no "Row Name" column (new format doesn't include row names)
	assert(not csv_content.contains("Row Name"), "CSV should not contain Row Name column")

	# Test CSV import into new resource
	var import_resource = ClassTableResource.new()
	var import_result = import_resource.import_from_csv(export_path)
	print("  Import result: ", import_result)
	assert(import_result == true, "CSV import should succeed")

	# Verify imported data
	print("  Imported resource:")
	print("    Columns: ", import_resource.column_count)
	print("    Rows: ", import_resource.row_count)

	assert(import_resource.column_count == 4, "Imported resource should have 4 columns")
	assert(import_resource.row_count == 3, "Imported resource should have 3 rows")

	# Verify column metadata was reconstructed
	var col0 = import_resource.get_column_type_info(0)
	assert(col0["name"] == "name", "Column 0 name should be 'name'")
	assert(col0["type_name"] == "String", "Column 0 type should be String")

	var col1 = import_resource.get_column_type_info(1)
	assert(col1["name"] == "damage", "Column 1 name should be 'damage'")
	assert(col1["type_name"] == "int", "Column 1 type should be int")

	# Verify cell data
	assert(import_resource.get_cell(0, 0) == "Iron Sword", "Cell (0,0) should match")
	assert(import_resource.get_cell(1, 1) == "8", "Cell (1,1) should match")
	assert(import_resource.get_cell(2, 3) == "true", "Cell (2,3) should match")

	# Clean up test file
	DirAccess.remove_absolute(export_path)

	print("\n✅ CSV Export/Import test PASSED!\n")
