@tool
extends RefCounted
class_name ResourceConverter

## Reflection-based converter for mapping TableHandle rows to typed instances.
## Works with RefCounted or Resource classes.
##
## Usage:
##   var item = handle.get_data(TestItemData)


## Creates and populates a data instance from a TableHandle.
## Automatically maps table columns to class properties by matching names.
static func create_from_handle(handle: TableHandle, data_class) -> Variant:
	if not handle:
		push_error("ResourceConverter: TableHandle is null")
		return null

	if not handle.is_valid():
		push_error("ResourceConverter: TableHandle is invalid")
		return null

	if not data_class:
		push_error("ResourceConverter: No data class provided")
		return null

	var instance = _instantiate_class(data_class)
	if not instance:
		return null

	var row_data = handle.get_row_data()
	if row_data.is_empty():
		push_warning("ResourceConverter: No data in row '%s'" % handle.row_name)
		return instance

	var mapped_count = 0
	for prop_info in instance.get_property_list():
		var prop_name: String = prop_info["name"]
		var prop_type: int = prop_info["type"]
		var prop_usage: int = prop_info["usage"]

		if prop_name.begins_with("_"):
			continue

		if prop_usage & PROPERTY_USAGE_INTERNAL:
			continue

		if not (prop_usage & PROPERTY_USAGE_STORAGE):
			continue

		if prop_name in row_data:
			var value = row_data[prop_name]

			if _is_type_compatible(value, prop_type):
				instance.set(prop_name, value)
				mapped_count += 1
			else:
				push_warning("ResourceConverter: Type mismatch for '%s' (expected %s, got %s)" %
					[prop_name, type_string(prop_type), type_string(typeof(value))])

	if mapped_count == 0:
		push_warning("ResourceConverter: No properties mapped. Check column names match property names.")
	elif OS.is_debug_build():
		print("ResourceConverter: Mapped %d properties" % mapped_count)

	return instance


static func _instantiate_class(data_class) -> Variant:
	if data_class is Script:
		return data_class.new()

	if data_class is String:
		if ClassDB.class_exists(data_class):
			return ClassDB.instantiate(data_class)
		push_error("ResourceConverter: Class '%s' not found in ClassDB" % data_class)
		return null

	if data_class.has_method("new"):
		return data_class.new()

	push_error("ResourceConverter: Unable to instantiate class from type: %s" % str(data_class))
	return null


static func _is_type_compatible(value: Variant, expected_type: int) -> bool:
	if value == null:
		return true

	var value_type = typeof(value)

	if value_type == expected_type:
		return true

	# Allow numeric coercion
	if expected_type in [TYPE_INT, TYPE_FLOAT] and value_type in [TYPE_INT, TYPE_FLOAT]:
		return true

	return false

