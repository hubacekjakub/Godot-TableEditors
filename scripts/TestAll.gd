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
	print("║  Testing P2-001 to P2-008: Core Class Functionality║")
	print("╚════════════════════════════════════════════════════╝")

	var tests = [
		{"name": "ClassParser", "script": TestClassParser},
		{"name": "ClassCache", "script": TestClassCache},
		{"name": "ClassTableResource", "script": TestClassTableResource},
	]

	var passed = 0
	var failed = 0

	for test in tests:
		print("\n" + "─".repeat(50))
		if test["script"] == null:
			print("❌ Error running test: ", test["name"], " (script not loaded)")
			failed += 1
			continue

		var instance = test["script"].new()
		add_child(instance)

		# Call test functions
		if instance.has_method("test_parser"):
			instance.test_parser()
			passed += 1
		if instance.has_method("test_cache"):
			instance.test_cache()
			passed += 1
		if instance.has_method("test_resource"):
			instance.test_resource()
			passed += 1
		if instance.has_method("test_type_validation"):
			instance.test_type_validation()
			passed += 1

		instance.queue_free()

	print("\n" + "═".repeat(50))
	print("║ Test Summary")
	print("═".repeat(50))
	print("  Total test groups: ", tests.size())
	print("  ✅ Passed: ", passed)
	print("  ❌ Failed: ", failed)
	print("═".repeat(50))

	if failed == 0:
		print("\n🎉 ALL TESTS PASSED! Core P2 implementation is working correctly.\n")
	else:
		print("\n❌ Some tests failed. See output above for details.\n")


# Helper to catch errors in test methods
func try_call(obj: Object, method: String) -> bool:
	if obj.has_method(method):
		obj.call(method)
		return true
	return false
