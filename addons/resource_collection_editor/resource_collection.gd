@tool
extends Resource
class_name ResourceCollection

## Resource Collection data structure for Plugin 3: Bulk Resource Editor
## Stores metadata about a collection of resource files for bulk editing

@export var collection_name: String = "Untitled"
@export var resource_folder_path: String = ""  # Path to folder containing resources
@export var resource_type_filter: String = ""  # Optional: filter by resource type
@export var resource_file_list: Array[String] = []  # List of .tres file paths in collection
@export var resource_metadata: Dictionary = {}  # Additional metadata about resources


func add_resource(file_path: String) -> void:
	"""Add a resource file to the collection"""
	if file_path.is_empty() or file_path in resource_file_list:
		return
	resource_file_list.append(file_path)


func remove_resource(file_path: String) -> void:
	"""Remove a resource file from the collection"""
	if file_path in resource_file_list:
		resource_file_list.erase(file_path)


func clear_collection() -> void:
	"""Clear all resources from the collection"""
	resource_file_list.clear()
	resource_metadata.clear()


func get_resource_count() -> int:
	"""Get the number of resources in the collection"""
	return resource_file_list.size()


func get_all_resources() -> Array[String]:
	"""Get all resource file paths in the collection"""
	return resource_file_list


func set_resource_metadata(file_path: String, metadata: Dictionary) -> void:
	"""Store metadata about a resource"""
	resource_metadata[file_path] = metadata


func get_resource_metadata(file_path: String) -> Dictionary:
	"""Retrieve metadata about a resource"""
	return resource_metadata.get(file_path, {})
