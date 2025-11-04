@tool
extends EditorInspectorPlugin

## Inspector plugin for TableHandle custom property editor
## Detects TableHandle properties and provides custom UI

const TableHandleEditorProperty = preload("res://addons/class_table_editor/inspector_plugins/table_handle_editor_property.gd")


func _can_handle(object: Object) -> bool:
	# We handle all objects that might have TableHandle properties
	return true


func _parse_property(object: Object, type: Variant.Type, name: String, hint_type: PropertyHint, hint_string: String, usage_flags: int, wide: bool) -> bool:
	# Check if this is a TableHandle property
	# TYPE_OBJECT with hint_string containing "TableHandle"
	if type == TYPE_OBJECT and hint_string.contains("TableHandle"):
		# Add our custom property editor
		var editor = TableHandleEditorProperty.new()
		add_property_editor(name, editor)

		# Return true to replace the default editor
		return true

	# Let default editor handle other properties
	return false
