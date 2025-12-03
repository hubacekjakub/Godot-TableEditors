@tool
extends EditorPlugin

var panel: Control


func _enter_tree():
	# Load a regular .tscn scene - same workflow as game UI!
	panel = preload("res://addons/bazinga/bazinga_panel.tscn").instantiate()
	panel.set_meta("editor_plugin", self)
	add_control_to_bottom_panel(panel, "🎉 Bazinga!")
	print("Bazinga Panel loaded! Click the button to spawn Bazingas everywhere!")


func _exit_tree():
	if panel:
		if panel.has_method("cleanup_spawned_buttons"):
			panel.cleanup_spawned_buttons(self)
		remove_control_from_bottom_panel(panel)
		panel.queue_free()
