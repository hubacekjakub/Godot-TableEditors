extends Node

## Advanced example: Inventory system using TableHandle
## Demonstrates real-world usage patterns for game development

class_name InventoryExample

## Player's inventory using TableHandles
@export var starting_items: Array[TableHandle] = []

## Runtime inventory (TestItemData instances)
var inventory: Array[TestItemData] = []


func _ready():
	print("=== Inventory System Example ===")
	print()

	# Load starting items from table handles
	print("--- Loading Starting Items ---")
	load_starting_inventory()
	print()

	# Display inventory
	print("--- Current Inventory ---")
	display_inventory()
	print()

	# Calculate total stats
	print("--- Total Stats ---")
	calculate_total_stats()
	print()

	print("=== Example Complete ===")


## Load all starting items from TableHandles to runtime inventory
func load_starting_inventory():
	inventory.clear()

	for handle in starting_items:
		if not handle or not handle.is_valid():
			push_warning("Skipping invalid TableHandle")
			continue

		var item = table_handle_to_item(handle)
		if item:
			inventory.append(item)
			print("  ✅ Loaded: %s (Damage: %d, Armor: %.1f)" % [item.item_name, item.damage, item.armor])


## Convert TableHandle to TestItemData instance
func table_handle_to_item(handle: TableHandle) -> TestItemData:
	if not handle.is_valid():
		return null

	var item = TestItemData.new()
	item.item_name = handle.get_typed_value("item_name")
	item.damage = handle.get_typed_value("damage")
	item.armor = handle.get_typed_value("armor")
	item.is_stackable = handle.get_typed_value("is_stackable")
	item.rarity = handle.get_typed_value("rarity")

	return item


## Display all items in inventory
func display_inventory():
	if inventory.is_empty():
		print("  (empty)")
		return

	for i in range(inventory.size()):
		var item = inventory[i]
		print("  [%d] %s" % [i, item.item_name])
		print("      Damage: %d | Armor: %.1f | Stackable: %s | Rarity: %.1f%%" %
			[item.damage, item.armor, item.is_stackable, item.rarity * 100])


## Calculate combined stats from all equipped items
func calculate_total_stats():
	var total_damage = 0
	var total_armor = 0.0

	for item in inventory:
		total_damage += item.get_damage()  # Using the method from TestItemData
		total_armor += item.armor

	print("  Total Damage: %d" % total_damage)
	print("  Total Armor: %.1f" % total_armor)
	print("  Items Count: %d" % inventory.size())


## Example: Find item by name in inventory
func find_item_by_name(item_name: String) -> TestItemData:
	for item in inventory:
		if item.item_name == item_name:
			return item
	return null


## Example: Get all rare items (rarity > 0.5)
func get_rare_items() -> Array[TestItemData]:
	var rare_items: Array[TestItemData] = []

	for item in inventory:
		if item.rarity > 0.5:
			rare_items.append(item)

	return rare_items


## Example: Load entire item database from a table
static func load_item_database(table_path: String) -> Dictionary:
	var database = {}

	var table = load(table_path) as ClassTableResource
	if not table:
		push_error("Failed to load item table: " + table_path)
		return database

	# Load all items from table
	for row in range(table.row_count):
		var item_name = table.get_cell(row, 0)  # Assuming first column is "item_name"

		# Create temporary handle
		var handle = TableHandle.new()
		handle.table_resource = table
		handle.row_name = item_name

		# Convert to TestItemData
		var item = TestItemData.new()
		item.item_name = handle.get_typed_value("item_name")
		item.damage = handle.get_typed_value("damage")
		item.armor = handle.get_typed_value("armor")
		item.is_stackable = handle.get_typed_value("is_stackable")
		item.rarity = handle.get_typed_value("rarity")

		# Add to database
		database[item_name] = item

	return database


## Example: Spawn item by name from database
func spawn_item(item_name: String, database: Dictionary) -> TestItemData:
	if item_name not in database:
		push_warning("Item not found in database: " + item_name)
		return null

	# Create a new instance (duplicate the template)
	var template = database[item_name] as TestItemData
	var new_item = TestItemData.new()
	new_item.item_name = template.item_name
	new_item.damage = template.damage
	new_item.armor = template.armor
	new_item.is_stackable = template.is_stackable
	new_item.rarity = template.rarity

	return new_item
