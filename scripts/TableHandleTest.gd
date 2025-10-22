extends Node

## Test script demonstrating TableHandle usage with ResourceConverter
## Shows the simple one-liner approach to convert table data to Resource instances

@export var item_handle: TableHandle

func _ready():
	print("=== TableHandle ResourceConverter Test ===")

	if not item_handle or not item_handle.is_valid():
		print("ERROR: No valid TableHandle configured!")
		print("Please select a table and row in the inspector")
		return

	print("TableHandle is valid!")
	print("  Table: %s" % item_handle.table_resource.sheet_name)
	print("  Row: %s" % item_handle.row_name)
	print()

	# Test getting individual cell values (raw strings)
	print("--- Raw Cell Values ---")
	print("  item_name: %s" % item_handle.get_cell_value("item_name"))
	print("  damage: %s" % item_handle.get_cell_value("damage"))
	print("  armor: %s" % item_handle.get_cell_value("armor"))
	print("  is_stackable: %s" % item_handle.get_cell_value("is_stackable"))
	print("  rarity: %s" % item_handle.get_cell_value("rarity"))
	print()

	# Test getting typed values (parsed by TableHandle)
	print("--- Typed Values ---")
	var damage_value = item_handle.get_typed_value("damage")
	var armor_value = item_handle.get_typed_value("armor")
	var is_stackable_value = item_handle.get_typed_value("is_stackable")
	print("  damage (int): %s (type: %s)" % [damage_value, type_string(typeof(damage_value))])
	print("  armor (float): %s (type: %s)" % [armor_value, type_string(typeof(armor_value))])
	print("  is_stackable (bool): %s (type: %s)" % [is_stackable_value, type_string(typeof(is_stackable_value))])
	print()

	# RECOMMENDED: Use ResourceConverter (one-liner!)
	print("--- Using ResourceConverter ---")
	var item = ResourceConverter.create_from_handle(item_handle, TestItemData)

	if item:
		print("✅ Successfully created TestItemData instance!")
		print("  item_name: %s" % item.item_name)
		print("  damage: %d" % item.damage)
		print("  armor: %.2f" % item.armor)
		print("  is_stackable: %s" % item.is_stackable)
		print("  rarity: %.2f" % item.rarity)
		print()

		# Test instance method
		print("--- Testing Instance Method ---")
		print("  get_damage() = %d" % item.get_damage())
		print()
	else:
		print("❌ Failed to create TestItemData instance")

	# Example: Load all items from table
	print("--- Loading All Items From Table ---")
	var all_items = load_all_items_from_table(item_handle.table_resource)
	print("  Loaded %d items total" % all_items.size())
	for loaded_item in all_items:
		print("    - %s (damage: %d)" % [loaded_item.item_name, loaded_item.damage])

	print()
	print("=== Test Complete ===")


## Example: Load all items from a table at once
## Useful for loading item databases, quest lists, enemy stats, etc.
func load_all_items_from_table(table: ClassTableResource) -> Array[TestItemData]:
	var items: Array[TestItemData] = []

	if not table:
		return items

	# Iterate through all rows
	for row in range(table.row_count):
		var row_name = table.get_cell(row, 0)  # First column is "name"

		# Create a temporary handle for this row
		var temp_handle = TableHandle.new()
		temp_handle.table_resource = table
		temp_handle.row_name = row_name

		# Convert to TestItemData using ResourceConverter (one-liner!)
		var item = ResourceConverter.create_from_handle(temp_handle, TestItemData)
		if item:
			items.append(item)

	return items
