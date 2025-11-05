@tool
extends EditorPlugin

class_name ResourceEditorPlugin

# Preload the dock scene
const DOCK_SCENE := preload("res://addons/resource_collection_editor/resource_editor_dock.tscn")

var button_2d: Button
var button_3d: Button
var button_inspector: Button
var resource_editor_dock: Control
var current_collection: ResourceCollection


func _enter_tree() -> void:
	_add_toolbar_buttons()
	_create_resource_editor_dock()
	add_control_to_bottom_panel(resource_editor_dock, "Resource Collection")
	print("Resource Collection Editor Plugin loaded")


func _handles(object: Object) -> bool:
	"""Only handle ResourceCollection resources"""
	if _is_object_resource_collection(object):
		return true
	return false


func _edit(object: Object) -> void:
	"""Edit a ResourceCollection when selected"""
	if not _is_object_resource_collection(object):
		print("Not a ResourceCollection, hiding dock")
		_hide_dock()
		return

	print("Editing ResourceCollection")
	current_collection = object
	_show_dock()

	# Add to recent collections if it has a path
	if current_collection.resource_path and not current_collection.resource_path.is_empty():
		if resource_editor_dock and resource_editor_dock.has_method("add_to_recent_collections"):
			resource_editor_dock.add_to_recent_collections(current_collection.resource_path)


func _show_dock() -> void:
	"""Show the resource editor dock and update its content"""
	make_bottom_panel_item_visible(resource_editor_dock)
	if resource_editor_dock and resource_editor_dock.has_method("set_collection"):
		resource_editor_dock.set_collection(current_collection)


func _hide_dock() -> void:
	"""Hide the resource editor dock when editing non-ResourceCollection objects"""
	if resource_editor_dock:
		hide_bottom_panel()


func _is_object_resource_collection(object: Object) -> bool:
	"""Check if the given object is a ResourceCollection"""
	if not object:
		return false
	if object is not Resource:
		return false
	return object is ResourceCollection


func _add_toolbar_buttons() -> void:
	"""Add toolbar buttons to open the resource editor dock"""
	button_2d = Button.new()
	button_2d.text = "Resource Collection"
	button_2d.pressed.connect(_on_button_pressed)
	add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, button_2d)

	button_3d = Button.new()
	button_3d.text = "Resource Collection"
	button_3d.pressed.connect(_on_button_pressed)
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, button_3d)

	button_inspector = Button.new()
	button_inspector.text = "Resource Collection"
	button_inspector.pressed.connect(_on_button_pressed)
	add_control_to_container(EditorPlugin.CONTAINER_INSPECTOR_BOTTOM, button_inspector)


func _create_resource_editor_dock() -> void:
	"""Create and initialize the resource editor dock with signal connections"""
	resource_editor_dock = DOCK_SCENE.instantiate()

	# Connect signals from the dock
	resource_editor_dock.collection_changed.connect(_on_collection_changed)
	resource_editor_dock.resource_added.connect(_on_resource_added)
	resource_editor_dock.resource_removed.connect(_on_resource_removed)
	resource_editor_dock.save_requested.connect(_save_collection)
	resource_editor_dock.load_collection_requested.connect(_load_collection)
	resource_editor_dock.close_requested.connect(_hide_dock)
	resource_editor_dock.new_collection_requested.connect(_create_new_collection)
	resource_editor_dock.collection_selected.connect(_on_collection_selected_from_recent)


func _on_collection_changed() -> void:
	"""Handle collection changes"""
	if not current_collection:
		return
	print("Resource Collection changed")


func _on_resource_added() -> void:
	"""Handle resource addition to collection"""
	if not current_collection:
		return
	print("Resource added to collection")


func _on_resource_removed() -> void:
	"""Handle resource removal from collection"""
	if not current_collection:
		return
	print("Resource removed from collection")


func _create_new_collection() -> void:
	"""Create a new ResourceCollection and start editing it"""
	var new_collection := ResourceCollection.new()
	new_collection.collection_name = "Untitled Collection"

	current_collection = new_collection
	_show_dock()

	# Select in inspector so it can be saved
	get_editor_interface().edit_resource(new_collection)


func _save_collection() -> void:
	"""Save the current collection to file"""
	if not current_collection:
		push_warning("Resource Collection Editor: No collection to save")
		return

	var path := current_collection.resource_path
	if path.is_empty():
		_show_save_dialog()
		return

	var error := ResourceSaver.save(current_collection, path)
	if error == OK:
		print("Collection saved to: ", path)
	else:
		push_error("Resource Collection Editor: Failed to save collection - error code: " + str(error))


func _show_save_dialog() -> void:
	"""Show file dialog to save collection with a new path"""
	var dialog := EditorFileDialog.new()
	dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
	dialog.access = EditorFileDialog.ACCESS_RESOURCES
	dialog.add_filter("*.tres", "Godot Resource")
	dialog.title = "Save Collection As"

	var default_name := "new_collection.tres"
	if current_collection and not current_collection.collection_name.is_empty():
		default_name = current_collection.collection_name.to_snake_case() + ".tres"

	dialog.current_file = default_name
	dialog.current_dir = "res://"
	dialog.file_selected.connect(_on_save_file_selected)

	get_editor_interface().get_base_control().add_child(dialog)
	dialog.popup_centered_ratio(0.6)


func _on_save_file_selected(path: String) -> void:
	"""Save the collection to the selected file path"""
	if not current_collection:
		return

	if not path.ends_with(".tres"):
		path += ".tres"

	var error := ResourceSaver.save(current_collection, path)
	if error == OK:
		print("Collection saved to: ", path)
		current_collection.resource_path = path
		get_editor_interface().get_resource_filesystem().scan()

		# Add to recent collections
		if resource_editor_dock and resource_editor_dock.has_method("add_to_recent_collections"):
			resource_editor_dock.add_to_recent_collections(path)
	else:
		push_error("Resource Collection Editor: Failed to save collection - error code: " + str(error))


func _load_collection() -> void:
	"""Show dialog to load a collection from file"""
	_show_load_dialog()


func _show_load_dialog() -> void:
	"""Show file dialog to load an existing collection"""
	var dialog := EditorFileDialog.new()
	dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
	dialog.access = EditorFileDialog.ACCESS_RESOURCES
	dialog.add_filter("*.tres", "Godot Resource")
	dialog.title = "Load Collection"
	dialog.current_dir = "res://"
	dialog.file_selected.connect(_on_load_file_selected)

	get_editor_interface().get_base_control().add_child(dialog)
	dialog.popup_centered_ratio(0.6)


func _on_load_file_selected(path: String) -> void:
	"""Load collection from the selected file path"""
	_load_collection_from_path(path)


func _load_collection_from_path(path: String) -> void:
	"""Load a collection from a given path"""
	var loaded_resource = ResourceLoader.load(path)

	if not loaded_resource:
		push_error("Resource Collection Editor: Failed to load resource from: " + path)
		return

	if not loaded_resource is ResourceCollection:
		push_error("Resource Collection Editor: File is not a ResourceCollection: " + path)
		return

	print("Collection loaded from: ", path)

	current_collection = loaded_resource
	_show_dock()
	get_editor_interface().edit_resource(loaded_resource)

	# Add to recent collections
	if resource_editor_dock and resource_editor_dock.has_method("add_to_recent_collections"):
		resource_editor_dock.add_to_recent_collections(path)


func _on_collection_selected_from_recent(path: String) -> void:
	"""Handle selection from recent collections list"""
	_load_collection_from_path(path)


func _exit_tree() -> void:
	"""Clean up when plugin is disabled"""
	remove_control_from_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, button_2d)
	button_2d.queue_free()

	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, button_3d)
	button_3d.queue_free()

	remove_control_from_container(EditorPlugin.CONTAINER_INSPECTOR_BOTTOM, button_inspector)
	button_inspector.queue_free()

	remove_control_from_bottom_panel(resource_editor_dock)
	resource_editor_dock.queue_free()


func _on_button_pressed() -> void:
	"""Handle toolbar button press"""
	if current_collection:
		make_bottom_panel_item_visible(resource_editor_dock)
	else:
		print("No collection selected")
