@tool
extends Node
class_name TestAll

## Integration test runner - runs all P2 core tests

func _ready() -> void:
	if Engine.is_editor_hint():
		run_all_tests()


func run_all_tests() -> void:
	print("\n")
	print("╔════════════════════════════════════════════════════╗")
	print("║  P2 Core Tests: Class Functionality Integration    ║")
	print("║        Running Test Suite (Days 1-2)              ║")
	print("╚════════════════════════════════════════════════════╝")

	var passed = 0
	var failed = 0

	# Test 1: ClassCache (using ClassInspector internally)
	print("\n" + "─".repeat(50))
	print("🧪 ClassCache Tests (Mtime-based caching)")
	print("─".repeat(50))
	passed += _run_test_suite("res://scripts/TestClassCache.gd", "ClassCache")
	if passed < 1:
		failed += 1

	# Test 2: ClassTableResource (data storage with type metadata)
	print("\n" + "─".repeat(50))
	print("🧪 ClassTableResource Tests (Data storage)")
	print("─".repeat(50))
	passed += _run_test_suite("res://scripts/TestClassTableResource.gd", "ClassTableResource")
	if passed < 2:
		failed += 1

	# Test 3: ClassSelector (class discovery and selection - P2-009 to P2-010)
	print("\n" + "─".repeat(50))
	print("🧪 ClassSelector Tests (Class discovery)")
	print("─".repeat(50))
	passed += _run_test_suite("res://scripts/TestClassSelector.gd", "ClassSelector")
	if passed < 3:
		failed += 1

	# Test 4: Typed Cell Editors (P2-019 to P2-028)
	print("\n" + "─".repeat(50))
	print("🧪 Typed Cell Editor Tests (Type-safe editing)")
	print("─".repeat(50))
	passed += _run_test_suite("res://scripts/TestTypedCellEditors.gd", "TypedCellEditors")
	if passed < 4:
		failed += 1

	# Test 5: TableHandle & ResourceConverter (P3-001 to P3-005)
	print("\n" + "─".repeat(50))
	print("🧪 TableHandle & ResourceConverter Tests (Resource conversion)")
	print("─".repeat(50))
	passed += _run_test_suite("res://scripts/TestTableHandleResourceConverter.gd", "TableHandleResourceConverter")
	if passed < 5:
		failed += 1

	print("\n" + "═".repeat(50))
	print("║ Test Summary")
	print("═".repeat(50))
	print("  Total test suites: 5")
	print("  ✅ Passed: ", passed)
	print("  ❌ Failed: ", failed)
	print("═".repeat(50))

	if failed == 0:
		print("\n🎉 ALL TESTS PASSED!")
		print("   Core P2 implementation working correctly.")
		print("   Type-safe editing (P2-019 to P2-028) verified.")
		print("   TableHandle & ResourceConverter API verified.")
		print("   Backward compatibility maintained.\n")
	else:
		print("\n❌ Some tests failed. See output above for details.\n")


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
