@tool
extends EditorPlugin
## Class Table Editor v2 — native Variant-based data table editor.

const TableDock := preload("res://addons/class_table_editor_v2/ui/table_dock.gd")

var _dock: Control = null


func _enter_tree() -> void:
	_dock = TableDock.new()
	_dock.name = "ClassTableV2"
	add_control_to_bottom_panel(_dock, "Class Table v2")


func _exit_tree() -> void:
	if _dock:
		remove_control_from_bottom_panel(_dock)
		_dock.queue_free()
		_dock = null


func _handles(object: Object) -> bool:
	return object is ClassTableResourceV2


func _edit(object: Object) -> void:
	if object is ClassTableResourceV2 and _dock:
		_dock.edit_resource(object as ClassTableResourceV2)
		make_bottom_panel_item_visible(_dock)
