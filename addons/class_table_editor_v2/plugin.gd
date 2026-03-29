@tool
extends EditorPlugin
## Phase 1: Hosts the grid comparison prototype as a bottom panel.

var _comparison_dock: Control = null


func _enter_tree() -> void:
	var scene: PackedScene = preload("res://addons/class_table_editor_v2/prototypes/grid_comparison.tscn")
	_comparison_dock = scene.instantiate()
	add_control_to_bottom_panel(_comparison_dock, "Grid Comparison")


func _exit_tree() -> void:
	if _comparison_dock:
		remove_control_from_bottom_panel(_comparison_dock)
		_comparison_dock.queue_free()
		_comparison_dock = null
