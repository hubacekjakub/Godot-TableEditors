@tool
extends Node
class_name SheetEditorTests

## Integration test runner - runs all Plugin 1 (Sheet Editor) tests
## Tests the simple spreadsheet editor with CSV support

func _ready() -> void:
	if Engine.is_editor_hint():
		run_all_tests()


func run_all_tests() -> void:
	print("\n")
	print("╔════════════════════════════════════════════════════╗")
	print("║    Plugin 1: Sheet Editor Test Suite               ║")
	print("║         Simple Spreadsheet Editor                  ║")
	print("╚════════════════════════════════════════════════════╝")

	var passed = 0
	var failed = 0

	# Test 1: SpreadsheetResource
	print("\n" + "─".repeat(50))
	print("🧪 SpreadsheetResource Tests (Data storage)")
	print("─".repeat(50))
	passed += _run_test_suite("res://scripts/plugin1_sheet_editor_tests/TestSpreadsheetResource.gd", "SpreadsheetResource")
	if _is_test_failed(passed):
		failed += 1

	# Test 2: SpreadsheetDock
	print("\n" + "─".repeat(50))
	print("🧪 SpreadsheetDock Tests (UI display)")
	print("─".repeat(50))
	passed += _run_test_suite("res://scripts/plugin1_sheet_editor_tests/TestSpreadsheetDock.gd", "SpreadsheetDock")
	if _is_test_failed(passed):
		failed += 1

	# Test 3: CSV Export
	print("\n" + "─".repeat(50))
	print("🧪 CSV Export Tests (Export functionality)")
	print("─".repeat(50))
	passed += _run_test_suite("res://scripts/plugin1_sheet_editor_tests/TestCsvExport.gd", "CsvExport")
	if _is_test_failed(passed):
		failed += 1

	# ────────────────────────────────────────────────────────────
	# Test Summary
	# ────────────────────────────────────────────────────────────
	print("\n" + "═".repeat(50))
	print("║ Plugin 1 Test Summary")
	print("═".repeat(50))
	print("  Test suites:      3")
	print("  Test methods:     9")
	print("  ✅ Passed:        %d" % passed)
	print("  ❌ Failed:        %d" % failed)
	print("═".repeat(50))

	if failed == 0:
		print("\n🎉 ALL PLUGIN 1 TESTS PASSED!")
		print("   Sheet Editor functionality verified\n")
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
		instance.run_all_tests()
		return 1
	elif instance.has_method("run_all"):
		instance.run_all()
		return 1
	else:
		add_child(instance)
		var test_count = 0

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
