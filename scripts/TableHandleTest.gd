extends Node

## Test script demonstrating TableHandle usage
## Shows how to convert table row data to TestItemData instance

@export var item_handle: TableHandle

func _ready():
	print("=== TableHandle Test ===")

	if not item_handle or not item_handle.is_valid():
		print("ERROR: No valid TableHandle configured!")
		print("Please select a table and row in the inspector")
		return

	print("TableHandle is valid!")
	print("  Table: %s" % item_handle.table_resource.sheet_name)
	print("  Row: %s" % item_handle.row_name)
	print()

	# Test getting individual cell values
	print("--- Raw Cell Values ---")
	print("  item_name: %s" % item_handle.get_cell_value("item_name"))
	print("  damage: %s" % item_handle.get_cell_value("damage"))
	print("  armor: %s" % item_handle.get_cell_value("armor"))
	print("  is_stackable: %s" % item_handle.get_cell_value("is_stackable"))
	print("  rarity: %s" % item_handle.get_cell_value("rarity"))
	print()

	# Test getting typed values
	print("--- Typed Values ---")
	var damage_value = item_handle.get_typed_value("damage")
	var armor_value = item_handle.get_typed_value("armor")
	var is_stackable_value = item_handle.get_typed_value("is_stackable")
	print("  damage (int): %s (type: %s)" % [damage_value, type_string(typeof(damage_value))])
	print("  armor (float): %s (type: %s)" % [armor_value, type_string(typeof(armor_value))])
	print("  is_stackable (bool): %s (type: %s)" % [is_stackable_value, type_string(typeof(is_stackable_value))])
	print()

	# Test getting all row data as Dictionary
	print("--- Full Row Data Dictionary ---")
	var row_data = item_handle.get_row_data()
	for key in row_data:
		print("  %s: %s" % [key, row_data[key]])
	print()

	# REAL WORLD EXAMPLE: Convert to TestItemData instance
	print("--- Converting to TestItemData Instance ---")
	var item_data = create_test_item_data_from_handle(item_handle)

	if item_data:
		print("✅ Successfully created TestItemData instance!")
		print("  item_name: %s" % item_data.item_name)
		print("  damage: %d" % item_data.damage)
		print("  armor: %.2f" % item_data.armor)
		print("  is_stackable: %s" % item_data.is_stackable)
		print("  rarity: %.2f" % item_data.rarity)
		print()

		# Test the method on the instance
		print("--- Testing Instance Method ---")
		print("  get_damage() = %d" % item_data.get_damage())
		print()
	else:
		print("❌ Failed to create TestItemData instance")

	print("=== Test Complete ===")


## Convert TableHandle row data to TestItemData instance
## This shows a real-world pattern for loading game data from tables
func create_test_item_data_from_handle(handle: TableHandle) -> TestItemData:
	if not handle or not handle.is_valid():
		push_error("Invalid TableHandle")
		return null

	# Create new TestItemData instance
	var item = TestItemData.new()

	# Map table columns to TestItemData properties
	# Using get_typed_value() for automatic type conversion
	item.item_name = handle.get_typed_value("item_name")
	item.damage = handle.get_typed_value("damage")
	item.armor = handle.get_typed_value("armor")
	item.is_stackable = handle.get_typed_value("is_stackable")
	item.rarity = handle.get_typed_value("rarity")

	print("test test test")
	var item_data: Dictionary = handle.get_row_data();
	for key in item_data.keys():
		print("Mapping %s: %s" % [key, item_data[key]])

	# Note: 'description' is not exported in TestItemData,
	# so it won't be in the table, using default value

	return item


## Alternative: Generic function to create any Resource from TableHandle
## This is more flexible and works with any Resource class
func create_resource_from_handle(handle: TableHandle, resource_script: Script) -> Resource:
	if not handle or not handle.is_valid():
		push_error("Invalid TableHandle")
		return null

	if not resource_script:
		push_error("No resource script provided")
		return null

	# Create instance
	var resource = resource_script.new()

	# Get all row data
	var row_data = handle.get_row_data()

	# Automatically set properties that exist in both table and resource
	for prop_name in row_data.keys():
		if prop_name in resource:
			resource.set(prop_name, row_data[prop_name])

	return resource


## Example of loading multiple items at once
func load_all_items_from_table(table: ClassTableResource) -> Array[TestItemData]:
	var items: Array[TestItemData] = []

	if not table:
		return items

	# Iterate through all rows (skipping header if needed)
	for row in range(table.row_count):
		var row_name = table.get_cell(row, 0)  # First column is "name"

		# Create a temporary handle for this row
		var temp_handle = TableHandle.new()
		temp_handle.table_resource = table
		temp_handle.row_name = row_name

		# Convert to TestItemData
		var item = create_test_item_data_from_handle(temp_handle)
		if item:
			items.append(item)

	return items
