@tool
class_name ClassCache
extends RefCounted

## Cache for inspected GDScript classes to prevent re-parsing unchanged files
## Uses ClassInspector with native Godot property introspection API

var _cache: Dictionary = {}  # {file_path: {inspected_data, file_mtime}}


## Get inspected class data, using cache if file hasn't changed
func get_parsed_class(file_path: String) -> Dictionary:
	var current_mtime = _get_file_mtime(file_path)

	# Check if we have it cached and it's still valid
	if _cache.has(file_path):
		var cached = _cache[file_path]
		if cached.get("mtime") == current_mtime:
			return cached.get("data", {})

	# Inspect the class
	var inspected_data = ClassInspector.new().inspect_class(file_path)

	# Store in cache
	_cache[file_path] = {
		"data": inspected_data,
		"mtime": current_mtime
	}

	return inspected_data


## Invalidate cache for a specific file
func invalidate_file(file_path: String) -> void:
	if _cache.has(file_path):
		_cache.erase(file_path)


## Invalidate entire cache
func clear_cache() -> void:
	_cache.clear()


## Get file modification time
func _get_file_mtime(file_path: String) -> int:
	var file = FileAccess.open(file_path, FileAccess.READ)
	if file == null:
		return 0

	file.close()
	return FileAccess.get_modified_time(file_path)


## Get cache statistics
func get_stats() -> Dictionary:
	return {
		"cached_files": _cache.size(),
		"cache_keys": _cache.keys()
	}
