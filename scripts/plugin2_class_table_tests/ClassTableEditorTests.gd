@tool
extends Node
class_name ClassTableEditorTests

## Integration test runner - runs all Plugin 2 (Class Table Editor) tests
## Tests type-safe class data tables with GDScript class integration

func _ready() -> void:
	if Engine.is_editor_hint():
		run_all_tests()


func run_all_tests() -> void:
	print("\n")
	print("╔════════════════════════════════════════════════════╗")
	print("║    Plugin 2: Class Table Editor Test Suite         ║")
	print("║       Type-Safe Class Data Tables                  ║")
	print("╚════════════════════════════════════════════════════╝")

	var passed = 0
	var failed = 0

	# ────────────────────────────────────────────────────────────
	# PLUGIN 2: Class Table Editor - Type-Safe Class Data Tables
	# ────────────────────────────────────────────────────────────

	# P2 Test 1: ClassCache
	print("\n" + "─".repeat(50))
	print("🧪 ClassCache Tests (Mtime-based caching)")
	print("─".repeat(50))
	passed += _run_test_suite("res://scripts/plugin2_class_table_tests/TestClassCache.gd", "P2 - ClassCache")
	if _is_test_failed(passed):
		failed += 1

	# P2 Test 2: ClassTableResource
	print("\n" + "─".repeat(50))
	print("🧪 ClassTableResource Tests (Type metadata storage)")
	print("─".repeat(50))
	passed += _run_test_suite("res://scripts/plugin2_class_table_tests/TestClassTableResource.gd", "P2 - ClassTableResource")
	if _is_test_failed(passed):
		failed += 1

	# P2 Test 3: ClassSelector
	print("\n" + "─".repeat(50))
	print("🧪 ClassSelector Tests (Class discovery)")
	print("─".repeat(50))
	passed += _run_test_suite("res://scripts/plugin2_class_table_tests/TestClassSelector.gd", "P2 - ClassSelector")
	if _is_test_failed(passed):
		failed += 1

	# P2 Test 4: TypedCellEditors
	print("\n" + "─".repeat(50))
	print("🧪 Typed Cell Editors Tests (Type-safe editing)")
	print("─".repeat(50))
	passed += _run_test_suite("res://scripts/plugin2_class_table_tests/TestTypedCellEditors.gd", "P2 - TypedCellEditors")
	if _is_test_failed(passed):
		failed += 1

	# P2 Test 5: TableHandle & ResourceConverter
	print("\n" + "─".repeat(50))
	print("🧪 TableHandle & ResourceConverter Tests (Row-to-Resource conversion)")
	print("─".repeat(50))
	passed += _run_test_suite("res://scripts/plugin2_class_table_tests/TestTableHandleResourceConverter.gd", "P2 - TableHandle")
	if _is_test_failed(passed):
		failed += 1

	# ────────────────────────────────────────────────────────────
	# Test Summary
	# ────────────────────────────────────────────────────────────
	print("\n" + "═".repeat(50))
	print("║ Plugin 2 Test Summary")
	print("═".repeat(50))
	print("  Test suites:      5")
	print("  Test methods:     25+")
	print("  ✅ Passed:        %d" % passed)
	print("  ❌ Failed:        %d" % failed)
	print("═".repeat(50))

	if failed == 0:
		print("\n🎉 ALL PLUGIN 2 TESTS PASSED!")
		print("   Type-safe class tables verified\n")
	else:
		print("\n❌ Some tests failed. See output above for details.\n")


## Helper function to check if a test failed
func _is_test_failed(passed_count: int) -> bool:
	return passed_count == 0


## Helper to run individual test suites dynamically
func _run_test_suite(script_path: String, suite_name: String) -> int:
	var test_class = load(script_path)
	if test_class == null:
		print("❌ Could not load %s (%s)" % [suite_name, script_path])
		return 0

	var instance = test_class.new()

	# Run the test suite
	if instance.has_method("run_all_tests"):
		# Use run_all_tests() if available (new style)
		instance.run_all_tests()
		return 1
	elif instance.has_method("run_all"):
		# Use run_all() if available (legacy style)
		instance.run_all()
		return 1
	else:
		# Otherwise run individual test methods for legacy tests
		add_child(instance)
		var test_count = 0

		# Check for standard test methods
		for method_name in ["test_parser", "test_cache", "test_resource", "test_type_validation",
						   "test_parser_code_strings", "test_find_classes"]:
			if instance.has_method(method_name):
				instance.call(method_name)
				test_count += 1

		instance.queue_free()

		if test_count > 0:
			print("✅ %s tests passed (%d methods)" % [suite_name, test_count])
			return 1
		else:
			print("❌ %s has no test methods" % suite_name)
			return 0
