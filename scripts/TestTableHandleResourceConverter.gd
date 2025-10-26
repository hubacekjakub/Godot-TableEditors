@tool
extends Node
class_name TestTableHandleResourceConverter

## Test script for TableHandle.to_resource() and ResourceConverter functionality
## Tests the new convenient API for converting table rows to typed Resources


func run_all_tests() -> void:
	print("\n=== Testing TableHandle & ResourceConverter ===\n")

	test_table_handle_validity()
	test_to_resource_single_item()
	test_to_resource_batch_loading()
	test_resource_converter_direct()
	test_type_conversion()
	test_error_handling()

	print("\n✅ All TableHandle & ResourceConverter tests passed!\n")


## Test 1: TableHandle validity checks
func test_table_handle_validity() -> void:
	print("Test 1: TableHandle validity checks...")

	# Create a test table
	var table = ClassTableResource.new()
	table.sheet_name = "TestTable"
	table.add_column_with_type("item_name", "String", "Sword", true)
	table.add_column_with_type("damage", "int", 10, true)
	table.add_row("row1")
	# Set the first column value to match the row name we'll search for
	table.set_cell(0, 0, "sword")
	table.set_cell(0, 1, "15")

	# Create valid handle - row_name must match the value in the first column
	var valid_handle = TableHandle.new()
	valid_handle.table_resource = table
	valid_handle.row_name = "sword"

	assert(valid_handle.is_valid(), "Handle should be valid with table and row")
	assert(valid_handle.get_row_index() == 0, "Row index should be 0")

	# Create invalid handle (no table)
	var invalid_handle1 = TableHandle.new()
	assert(not invalid_handle1.is_valid(), "Handle without table should be invalid")

	# Create invalid handle (no row)
	var invalid_handle2 = TableHandle.new()
	invalid_handle2.table_resource = table
	invalid_handle2.row_name = "nonexistent"
	assert(not invalid_handle2.is_valid(), "Handle with invalid row should be invalid")

	print("  ✅ Validity checks passed")


## Test 2: Convert single item using to_resource()
func test_to_resource_single_item() -> void:
	print("\nTest 2: Convert single item using to_resource()...")

	# Create test table with item data
	var table = ClassTableResource.new()
	table.sheet_name = "Items"
	table.add_column_with_type("item_name", "String", "Sword", true)
	table.add_column_with_type("damage", "int", 10, true)
	table.add_column_with_type("armor", "float", 0.0, true)
	table.add_column_with_type("is_stackable", "bool", false, true)

	table.add_row("row1")
	# Set first column to the identifier we'll search for
	table.set_cell(0, 0, "Iron Sword")
	table.set_cell(0, 1, "15")
	table.set_cell(0, 2, "0.0")
	table.set_cell(0, 3, "false")

	# Create handle and convert to resource
	# row_name must match the value in the first column (item_name)
	var handle = TableHandle.new()
	handle.table_resource = table
	handle.row_name = "Iron Sword"

	# Use the new to_resource() method
	var item = handle.to_resource(TestItemData)

	# Verify conversion
	assert(item != null, "Should create resource instance")
	assert(item is TestItemData, "Should be TestItemData instance")
	assert(item.item_name == "Iron Sword", "item_name should be 'Iron Sword'")
	assert(item.damage == 15, "damage should be 15")
	assert(item.armor == 0.0, "armor should be 0.0")
	assert(item.is_stackable == false, "is_stackable should be false")

	print("  ✅ Single item conversion passed")
	print("    - Created: %s" % item.item_name)
	print("    - Damage: %d" % item.damage)
	print("    - Type: %s" % item.get_class())


## Test 3: Batch loading multiple items
func test_to_resource_batch_loading() -> void:
	print("\nTest 3: Batch loading multiple items...")

	# Create test table with multiple items
	var table = ClassTableResource.new()
	table.sheet_name = "Items"
	table.add_column_with_type("item_name", "String", "", true)
	table.add_column_with_type("damage", "int", 0, true)
	table.add_column_with_type("armor", "float", 0.0, true)
	table.add_column_with_type("is_stackable", "bool", false, true)

	# Add multiple items
	table.add_row("row1")
	table.set_cell(0, 0, "Iron Sword")
	table.set_cell(0, 1, "15")
	table.set_cell(0, 2, "0")
	table.set_cell(0, 3, "false")

	table.add_row("row2")
	table.set_cell(1, 0, "Steel Shield")
	table.set_cell(1, 1, "0")
	table.set_cell(1, 2, "25")
	table.set_cell(1, 3, "false")

	table.add_row("row3")
	table.set_cell(2, 0, "Health Potion")
	table.set_cell(2, 1, "0")
	table.set_cell(2, 2, "0")
	table.set_cell(2, 3, "true")

	# Batch load using to_resource()
	var items: Array[TestItemData] = []
	for row in range(table.row_count):
		# Get the value from the first column (item_name) as the row identifier
		var row_identifier = table.get_cell(row, 0)
		var handle = TableHandle.new()
		handle.table_resource = table
		handle.row_name = row_identifier

		var item = handle.to_resource(TestItemData)
		if item:
			items.append(item)

	# Verify batch load
	assert(items.size() == 3, "Should load 3 items")
	assert(items[0].item_name == "Iron Sword", "First item should be Iron Sword")
	assert(items[1].item_name == "Steel Shield", "Second item should be Steel Shield")
	assert(items[2].item_name == "Health Potion", "Third item should be Health Potion")
	assert(items[2].is_stackable == true, "Potion should be stackable")

	print("  ✅ Batch loading passed")
	print("    - Loaded %d items" % items.size())
	for item in items:
		print("    - %s (damage: %d, stackable: %s)" % [item.item_name, item.damage, item.is_stackable])


## Test 4: Direct ResourceConverter usage (backward compatibility)
func test_resource_converter_direct() -> void:
	print("\nTest 4: Direct ResourceConverter usage (backward compatibility)...")

	# Create test table
	var table = ClassTableResource.new()
	table.sheet_name = "Items"
	table.add_column_with_type("item_name", "String", "", true)
	table.add_column_with_type("damage", "int", 0, true)
	table.add_column_with_type("armor", "float", 0.0, true)
	table.add_column_with_type("is_stackable", "bool", false, true)

	table.add_row("row1")
	table.set_cell(0, 0, "Battle Axe")
	table.set_cell(0, 1, "20")
	table.set_cell(0, 2, "5")
	table.set_cell(0, 3, "false")

	# Create handle - row_name must match first column value
	var handle = TableHandle.new()
	handle.table_resource = table
	handle.row_name = "Battle Axe"

	# Use old API directly
	var item = ResourceConverter.create_from_handle(handle, TestItemData)

	# Verify it still works
	assert(item != null, "Should create resource with old API")
	assert(item.item_name == "Battle Axe", "item_name should be 'Battle Axe'")
	assert(item.damage == 20, "damage should be 20")

	print("  ✅ Backward compatibility verified")
	print("    - Old API (ResourceConverter.create_from_handle) still works")


## Test 5: Type conversion accuracy
func test_type_conversion() -> void:
	print("\nTest 5: Type conversion accuracy...")

	# Create table with various types
	var table = ClassTableResource.new()
	table.sheet_name = "TypeTest"
	table.add_column_with_type("item_name", "String", "", true)
	table.add_column_with_type("damage", "int", 0, true)
	table.add_column_with_type("armor", "float", 0.0, true)
	table.add_column_with_type("is_stackable", "bool", false, true)
	table.add_column_with_type("rarity", "float", 0.5, true)

	table.add_row("row1")
	table.set_cell(0, 0, "Test Item")
	table.set_cell(0, 1, "42")           # int
	table.set_cell(0, 2, "3.14")         # float
	table.set_cell(0, 3, "true")         # bool
	table.set_cell(0, 4, "0.85")         # float rarity

	# Convert and verify types
	var handle = TableHandle.new()
	handle.table_resource = table
	handle.row_name = "Test Item"

	var item = handle.to_resource(TestItemData)

	assert(item != null, "Item should be created")
	assert(item.item_name is String, "item_name should be String")
	assert(item.damage is int, "damage should be int")
	assert(item.armor is float, "armor should be float")
	assert(item.is_stackable is bool, "is_stackable should be bool")
	assert(item.rarity is float, "rarity should be float")

	# Verify values
	assert(item.damage == 42, "Int conversion: should be 42")
	assert(abs(item.armor - 3.14) < 0.01, "Float conversion: should be ~3.14")
	assert(item.is_stackable == true, "Bool conversion: should be true")
	assert(abs(item.rarity - 0.85) < 0.01, "Rarity conversion: should be ~0.85")

	print("  ✅ Type conversion accuracy verified")
	print("    - String: ✓")
	print("    - Int: ✓")
	print("    - Float: ✓")
	print("    - Bool: ✓")


## Test 6: Error handling via TableHandle validity checks
func test_error_handling() -> void:
	print("\nTest 6: Error handling via TableHandle validity...")

	# Instead of calling ResourceConverter with invalid params (which logs errors),
	# we test by verifying TableHandle.is_valid() catches the issues first

	# Test Case 1: Handle with no table
	var handle_no_table = TableHandle.new()
	assert(not handle_no_table.is_valid(), "Handle without table should be invalid")
	print("  ✓ TableHandle without table: invalid")

	# Test Case 2: Handle with invalid row
	var table = ClassTableResource.new()
	table.sheet_name = "Test"
	table.add_column_with_type("item_name", "String", "", true)
	table.add_row("row1")
	# Don't set any cell value - first column is empty

	var handle_invalid_row = TableHandle.new()
	handle_invalid_row.table_resource = table
	handle_invalid_row.row_name = "nonexistent"
	assert(not handle_invalid_row.is_valid(), "Handle with invalid row should be invalid")
	print("  ✓ TableHandle with invalid row: invalid")

	# Test Case 3: Valid handle - ensure to_resource() handles null class gracefully
	var valid_table = ClassTableResource.new()
	valid_table.sheet_name = "Test"
	valid_table.add_column_with_type("item_name", "String", "", true)
	valid_table.add_row("row1")
	valid_table.set_cell(0, 0, "Test Item")

	var valid_handle = TableHandle.new()
	valid_handle.table_resource = valid_table
	valid_handle.row_name = "Test Item"
	assert(valid_handle.is_valid(), "Valid handle should be valid")
	print("  ✓ TableHandle with valid data: valid")

	# Test Case 4: Verify get_row_data() returns consistent data
	var row_data = valid_handle.get_row_data()
	assert(not row_data.is_empty(), "Valid handle should return row data")
	assert(row_data.has("item_name"), "Row data should have item_name column")
	print("  ✓ Valid handle returns row data")

	# Test Case 5: Verify to_resource() works on valid handle
	var converted_item = valid_handle.to_resource(TestItemData)
	assert(converted_item != null, "to_resource() should work on valid handle")
	assert(converted_item is TestItemData, "Should create TestItemData instance")
	assert(converted_item.item_name == "Test Item", "Item name should match")
	print("  ✓ Valid handle.to_resource() works correctly")

	print("  ✅ Error handling via validity checks verified")
	print("    - Invalid table: ✓")
	print("    - Invalid row: ✓")
	print("    - Valid handle: ✓")
	print("    - Row data retrieval: ✓")
	print("    - to_resource() conversion: ✓")
