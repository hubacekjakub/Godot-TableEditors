@tool
extends RefCounted
class_name ResourceConverter

## Generic Reflection-Based Resource Converter
## Automatically maps TableHandle row data to Resource properties using reflection.
## Works with any Resource class without modification.
##
## Usage:
##   var item = ResourceConverter.create_from_handle(handle, TestItemData)
##   # Properties automatically mapped from table columns
##
## Requirements:
##   - Table column names must match Resource property names exactly
##   - Resource properties should use @export for proper reflection
##   - TableHandle must be valid with existing row


## Creates a Resource instance from a TableHandle using reflection.
## Automatically maps table columns to Resource properties by matching names.
##
## @param handle: TableHandle - The table handle containing row data
## @param resource_class: Script or String - The Resource class to instantiate
## @return Resource - Newly created and populated Resource, or null on error
static func create_from_handle(handle: TableHandle, resource_class) -> Resource:
	# Validate handle
	if not handle:
		push_error("ResourceConverter: TableHandle is null")
		return null

	if not handle.is_valid():
		push_error("ResourceConverter: TableHandle is invalid (missing table or row)")
		return null

	# Validate resource class
	if not resource_class:
		push_error("ResourceConverter: No resource class provided")
		return null

	# Create instance
	var resource: Resource = _instantiate_resource(resource_class)
	if not resource:
		return null

	# Get row data from table
	var row_data = handle.get_row_data()
	if row_data.is_empty():
		push_warning("ResourceConverter: No data found in table row '%s'" % handle.row_name)
		return resource  # Return empty resource (graceful degradation)

	# Get all properties from the resource
	var property_list = resource.get_property_list()
	var mapped_count = 0

	# Auto-map matching properties
	for prop_info in property_list:
		var prop_name: String = prop_info["name"]
		var prop_type: int = prop_info["type"]
		var prop_usage: int = prop_info["usage"]

		# Skip internal properties (starts with underscore)
		if prop_name.begins_with("_"):
			continue

		# Skip internal engine properties
		if prop_usage & PROPERTY_USAGE_INTERNAL:
			continue

		# Only process storable properties (user-defined @export vars)
		if not (prop_usage & PROPERTY_USAGE_STORAGE):
			continue

		# If table has this column
		if prop_name in row_data:
			var value = row_data[prop_name]

			# Type check before assignment
			if _is_type_compatible(value, prop_type):
				resource.set(prop_name, value)
				mapped_count += 1
			else:
				push_warning("ResourceConverter: Type mismatch for property '%s' (expected %s, got %s)" %
					[prop_name, type_string(prop_type), type_string(typeof(value))])

	if mapped_count == 0:
		push_warning("ResourceConverter: No properties were mapped. Check column names match property names.")
	else:
		print("ResourceConverter: Successfully mapped %d properties from table" % mapped_count)

	return resource


## Instantiates a Resource from a Script or class name string.
## Handles both direct Script references and ClassDB string lookups.
##
## @param resource_class: Script or String - The class to instantiate
## @return Resource - New instance, or null on failure
static func _instantiate_resource(resource_class) -> Resource:
	var resource: Resource = null

	# Try Script-based instantiation
	if resource_class is Script:
		resource = resource_class.new()

	# Try ClassDB string-based instantiation
	elif resource_class is String:
		if ClassDB.class_exists(resource_class):
			resource = ClassDB.instantiate(resource_class)
		else:
			push_error("ResourceConverter: Class '%s' not found in ClassDB" % resource_class)
			return null

	# Try as class name if it has .new() method
	elif resource_class.has_method("new"):
		resource = resource_class.new()

	else:
		push_error("ResourceConverter: Unable to instantiate resource from type: %s" % str(resource_class))
		return null

	# Validate result is actually a Resource
	if not resource is Resource:
		push_error("ResourceConverter: Instantiated object is not a Resource: %s" % str(resource))
		return null

	return resource


## Checks if a value's type is compatible with the expected property type.
## Allows exact matches and numeric coercion (int <-> float).
##
## @param value: Variant - The value to check
## @param expected_type: int - The TYPE_* constant for expected type
## @return bool - True if compatible, false otherwise
static func _is_type_compatible(value: Variant, expected_type: int) -> bool:
	# Null is compatible with any type
	if value == null:
		return true

	var value_type = typeof(value)

	# Exact type match
	if value_type == expected_type:
		return true

	# Allow numeric coercion between int and float
	if expected_type in [TYPE_INT, TYPE_FLOAT] and value_type in [TYPE_INT, TYPE_FLOAT]:
		return true

	# Not compatible
	return false
