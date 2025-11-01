extends Node
## Test script to verify the example setup
## Run this from the Godot editor to check if everything is configured correctly

func _ready() -> void:
	print("=== Class Table Editor Example Test ===\n")

	# Test 1: Check if BaseUnit class exists
	print("Test 1: BaseUnit class...")
	var base_unit_path = "res://addons/class_table_editor/example/BaseUnit.gd"
	if ResourceLoader.exists(base_unit_path):
		print("  ✓ BaseUnit.gd exists")
		var script = load(base_unit_path)
		if script:
			print("  ✓ BaseUnit script loads successfully")
		else:
			print("  ✗ Failed to load BaseUnit script")
	else:
		print("  ✗ BaseUnit.gd not found")

	# Test 2: Check if table resource exists
	print("\nTest 2: ClassTable resource...")
	var table_path = "res://addons/class_table_editor/example/base_units_table.tres"
	if ResourceLoader.exists(table_path):
		print("  ✓ base_units_table.tres exists")
		var table = load(table_path)
		if table:
			print("  ✓ Table loads successfully")
			if "rows" in table:
				print("  ✓ Table has %d rows" % table.rows.size())
			if "columns_metadata" in table:
				print("  ✓ Table has %d columns" % table.columns_metadata.size())
		else:
			print("  ✗ Failed to load table")
	else:
		print("  ✗ base_units_table.tres not found")

	# Test 3: Check if scene exists
	print("\nTest 3: UnitSpawner scene...")
	var scene_path = "res://addons/class_table_editor/example/UnitSpawner.tscn"
	if ResourceLoader.exists(scene_path):
		print("  ✓ UnitSpawner.tscn exists")
		var packed_scene = load(scene_path)
		if packed_scene:
			print("  ✓ Scene loads successfully")
			var instance = packed_scene.instantiate()
			if instance:
				print("  ✓ Scene can be instantiated")
				instance.queue_free()
			else:
				print("  ✗ Failed to instantiate scene")
		else:
			print("  ✗ Failed to load scene")
	else:
		print("  ✗ UnitSpawner.tscn not found")

	# Test 4: Check if script exists
	print("\nTest 4: UnitSpawner script...")
	var script_path = "res://addons/class_table_editor/example/UnitSpawner.gd"
	if ResourceLoader.exists(script_path):
		print("  ✓ UnitSpawner.gd exists")
	else:
		print("  ✗ UnitSpawner.gd not found")

	# Test 5: Verify table data structure
	print("\nTest 5: Table data validation...")
	var table = load(table_path)
	if table and "rows" in table:
		var expected_units = ["Knight", "Archer", "Mage", "Scout", "Warrior"]
		var found_units = []

		for row in table.rows:
			if "cells" in row and row.cells.size() > 0:
				found_units.append(row.cells[0])  # First cell is unit_name

		print("  Expected units: %s" % str(expected_units))
		print("  Found units: %s" % str(found_units))

		var all_found = true
		for unit in expected_units:
			if unit not in found_units:
				print("  ✗ Missing unit: %s" % unit)
				all_found = false

		if all_found:
			print("  ✓ All 5 units found in table")
	else:
		print("  ✗ Could not validate table data")

	print("\n=== Test Complete ===")
	print("If all tests passed, you're ready to run UnitSpawner.tscn!")
	print("Open the scene and press F6 to see the units in action.")

	# Auto-quit after 1 second if running as main scene
	await get_tree().create_timer(1.0).timeout
	get_tree().quit()
