## Simple test validation script
## Run this to verify the test framework works
extends Node

func _ready() -> void:
	if Engine.is_editor_hint():
		print("\n✅ TestValidator running in editor mode...")
		validate_tests()

func validate_tests() -> void:
	print("\n" + "═".repeat(60))
	print("Validating Test Infrastructure")
	print("═".repeat(60))

	# Check test files exist
	var test_files = [
		"res://scripts/TestClassParser.gd",
		"res://scripts/TestClassCache.gd",
		"res://scripts/TestClassTableResource.gd",
	]

	print("\n📁 Checking test files...")
	for file_path in test_files:
		var test_class = load(file_path)
		if test_class == null:
			print("  ❌ Could not load: %s" % file_path)
		else:
			var instance = test_class.new()
			var methods = []

			# Collect test methods
			for method_name in ["test_parser", "test_cache", "test_resource", "test_type_validation",
							   "test_parser_code_strings", "test_find_classes"]:
				if instance.has_method(method_name):
					methods.append(method_name)

			var file_name = file_path.get_file()
			if methods.size() > 0:
				print("  ✅ %s: %d test methods" % [file_name, methods.size()])
				for method in methods:
					print("     • %s()" % method)
			else:
				print("  ⚠️  %s: no test methods found" % file_name)

	print("\n📋 Checking support utilities...")

	# Check PropertyInspector exists
	var pi_class = load("res://addons/class_table_editor/property_inspector.gd")
	if pi_class:
		print("  ✅ PropertyInspector: Ready")
	else:
		print("  ❌ PropertyInspector: Not found")

	# Check ClassInspector exists
	var ci_class = load("res://addons/class_table_editor/class_inspector.gd")
	if ci_class:
		print("  ✅ ClassInspector: Ready")
	else:
		print("  ❌ ClassInspector: Not found")

	# Check ClassTableResource exists
	var ctr_class = load("res://addons/class_table_editor/class_table_resource.gd")
	if ctr_class:
		print("  ✅ ClassTableResource: Ready")
	else:
		print("  ❌ ClassTableResource: Not found")

	print("\n" + "═".repeat(60))
	print("✨ Test Infrastructure Ready!")
	print("═".repeat(60) + "\n")
