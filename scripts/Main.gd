extends Node

## Main game scene - Entry point for the Godot Sheet Editor project

func _ready():
	print("=== Godot Sheet Editor ===")
	print()
	print("Plugins loaded:")
	print("  ✅ Plugin 1: Sheet Editor (addons/sheet_editor/)")
	print("  ✅ Plugin 2: Class Table Editor (addons/class_table_editor/)")
	print("  ✅ Plugin 3: Resource Collection (addons/resource_collection_editor/)")
	print()
	print("To test:")
	print("  • Open scenes/TestRunner.tscn")
	print("  • P1 tests: scripts/plugin1_sheet_editor_tests/")
	print("  • P2 tests: scripts/plugin2_class_table_tests/")
	print()
	print("=== Ready ===")
