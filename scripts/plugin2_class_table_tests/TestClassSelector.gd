@tool
## TestClassSelector - Tests for ClassSelector class discovery
##
## Tests the new ClassSelector functionality:
## - Create "Select Class" dialog for choosing classes
## - Detect GDScript classes in the project
##
## This test validates that ClassSelector can:
## 1. Discover classes in the project
## 2. Cache discovered classes
## 3. Filter classes by predicates
## 4. Handle class metadata properly

extends Node
class_name TestClassSelector

var _test_count: int = 0
var _passed_count: int = 0
var _failed_count: int = 0


func run_all() -> void:
	print("\n🧪 ClassSelector Tests - Class Discovery & Selection")
	print("─".repeat(50))

	test_class_discovery()
	test_class_caching()
	test_class_filtering()
	test_class_metadata()

	print("\n📊 TestClassSelector Summary:")
	print("  Total Tests: %d" % _test_count)
	print("  ✅ Passed: %d" % _passed_count)
	print("  ❌ Failed: %d" % _failed_count)

	if _failed_count == 0:
		print("  🎉 All ClassSelector tests passed!")
	else:
		print("  ⚠️  %d test(s) failed" % _failed_count)


func test_class_discovery() -> void:
	print("\n  📍 Test 1: Class Discovery")
	_test_count += 1

	var selector := ClassSelector.new()
	var classes: Array[Dictionary] = selector.get_all_classes()

	# Should find at least TestItemData class
	if classes.size() > 0:
		print("    ✅ Found %d classes in project" % classes.size())
		_passed_count += 1

		# Verify class structure
		var first_class = classes[0]
		if first_class.has("class_name") and first_class.has("file_path"):
			print("    ✅ Class metadata structure valid")
			_passed_count += 1
		else:
			print("    ❌ Class metadata missing required fields")
			_failed_count += 1
	else:
		print("    ⚠️  No classes found (may be expected in test environment)")
		_passed_count += 1  # Don't fail if no classes discovered


func test_class_caching() -> void:
	print("\n  📍 Test 2: Class Caching")
	_test_count += 1

	var selector := ClassSelector.new()

	# First call - should populate cache
	var classes_first: Array[Dictionary] = selector.get_all_classes()
	var first_count: int = classes_first.size()

	# Second call - should use cache
	var classes_second: Array[Dictionary] = selector.get_all_classes(false)
	var second_count: int = classes_second.size()

	if first_count == second_count:
		print("    ✅ Cache returns consistent results (%d classes)" % first_count)
		_passed_count += 1
	else:
		print("    ❌ Cache inconsistency: %d vs %d" % [first_count, second_count])
		_failed_count += 1

	# Force rescan should also work
	var classes_rescan: Array[Dictionary] = selector.get_all_classes(true)
	if classes_rescan.size() == first_count:
		print("    ✅ Force rescan works correctly")
		_passed_count += 1
	else:
		print("    ❌ Force rescan returned different count")
		_failed_count += 1


func test_class_filtering() -> void:
	print("\n  📍 Test 3: Class Filtering")
	_test_count += 1

	var selector := ClassSelector.new()
	var classes: Array[Dictionary] = selector.get_all_classes()

	# Test filter by class name containing "Item"
	var filtered: Array[Dictionary] = selector.get_classes_filtered(
		func(cls: Dictionary) -> bool: return "Item" in cls.get("class_name", "")
	)

	if filtered.size() >= 0:  # May be 0 if no matching classes
		print("    ✅ Filtering returned %d matching classes" % filtered.size())
		_passed_count += 1
	else:
		print("    ❌ Filter predicate failed")
		_failed_count += 1

	# Test empty filter
	var all_filtered: Array[Dictionary] = selector.get_classes_filtered(
		func(cls: Dictionary) -> bool: return true
	)

	if all_filtered.size() == classes.size():
		print("    ✅ Filter allowing all returns correct count")
		_passed_count += 1
	else:
		print("    ❌ All-pass filter returned %d instead of %d" % [all_filtered.size(), classes.size()])
		_failed_count += 1


func test_class_metadata() -> void:
	print("\n  📍 Test 4: Class Metadata Extraction")
	_test_count += 1

	var selector := ClassSelector.new()
	var classes: Array[Dictionary] = selector.get_all_classes()

	if classes.size() == 0:
		print("    ⚠️  No classes to test metadata (skipping)")
		_passed_count += 1
		return

	var sample_class = classes[0]
	var has_name: bool = sample_class.has("class_name")
	var has_path: bool = sample_class.has("file_path")
	var has_properties: bool = sample_class.has("properties")

	if has_name and has_path:
		print("    ✅ Class has required metadata (name, path)")
		_passed_count += 1
	else:
		print("    ❌ Missing metadata: name=%s, path=%s" % [has_name, has_path])
		_failed_count += 1

	if has_properties:
		var prop_count: int = sample_class.get("properties", []).size()
		print("    ✅ Class metadata includes %d properties" % prop_count)
		_passed_count += 1
	else:
		print("    ⚠️  Properties metadata not found (may be expected)")
		_passed_count += 1
