@tool
extends Node
class_name TestClassCache

## Test script for ClassCache functionality


func test_cache() -> void:
	print("\n=== Testing ClassCache ===\n")

	var cache = ClassCache.new()

	# Test 1: Parse and cache a class
	print("Test 1: Parsing and caching TestItemData.gd...")
	var result1 = cache.get_parsed_class("res://scripts/plugin2_class_table_tests/TestItemData.gd")
	print("  Class name: ", result1.get("class_name"))
	print("  Properties: ", result1.get("properties", []).size())

	# Verify stats
	var stats = cache.get_stats()
	print("  Cache size: ", stats["cached_files"])
	assert(stats["cached_files"] == 1, "Cache should have 1 entry")

	# Test 2: Get same class again (should be cached)
	print("\nTest 2: Getting cached class (should not re-parse)...")
	var result2 = cache.get_parsed_class("res://scripts/plugin2_class_table_tests/TestItemData.gd")

	# Results should be identical
	assert(result1.get("class_name") == result2.get("class_name"), "Cached results should match")
	print("  ✓ Cache hit successful")

	# Test 3: Invalidate cache
	print("\nTest 3: Invalidating cache...")
	cache.invalidate_file("res://scripts/plugin2_class_table_tests/TestItemData.gd")
	var stats_after = cache.get_stats()
	print("  Cache size after invalidate: ", stats_after["cached_files"])
	assert(stats_after["cached_files"] == 0, "Cache should be empty after invalidate")

	# Test 4: Parse multiple files and test cache clearing
	print("\nTest 4: Caching multiple files...")
	cache.get_parsed_class("res://scripts/plugin2_class_table_tests/TestItemData.gd")
	cache.get_parsed_class("res://scripts/plugin2_class_table_tests/ClassTableEditorTests.gd")  # Different file

	var stats_multi = cache.get_stats()
	print("  Cache size with multiple files: ", stats_multi["cached_files"])

	cache.clear_cache()
	var stats_cleared = cache.get_stats()
	print("  Cache size after clear: ", stats_cleared["cached_files"])
	assert(stats_cleared["cached_files"] == 0, "Cache should be empty after clear")

	print("\n✅ ClassCache test PASSED!\n")
