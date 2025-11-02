@tool
extends EditorPlugin

class_name SpreadsheetPlugin

# Preload the dock scene
const DOCK_SCENE := preload("res://addons/sheet_editor/spreadsheet_dock.tscn")

var button_2d: Button
var button_3d: Button
var button_inspector: Button
var sheet_editor_dock: Control
var current_sheet: Resource

# Dialog instances (reused to avoid memory leaks)
var save_dialog: EditorFileDialog = null
var load_dialog: EditorFileDialog = null


func _enter_tree() -> void:
	_add_toolbar_buttons()
	_create_sheet_editor_dock()
	add_control_to_bottom_panel(sheet_editor_dock, "Sheet Editor")
	print("Sheet Editor Plugin loaded")


func _handles(object: Object) -> bool:
	"""Only handle SpreadsheetResource resources"""
	if _is_object_sheet_resource(object):
		return true
	return false

func _edit(object: Object) -> void:
	"""Edit a SpreadsheetResource when selected"""
	# Handle SpreadsheetResource
	if not _is_object_sheet_resource(object):
		print("Not a SpreadsheetResource resource, hiding dock")
		_hide_dock()
		return

	print("Editing SpreadsheetResource resource")
	current_sheet = object
	_show_dock()

	# Add to recent sheets if it has a path
	if current_sheet.resource_path and not current_sheet.resource_path.is_empty():
		if sheet_editor_dock and sheet_editor_dock.has_method("add_to_recent_sheets"):
			sheet_editor_dock.add_to_recent_sheets(current_sheet.resource_path)


func _show_dock() -> void:
	make_bottom_panel_item_visible(sheet_editor_dock)
	if sheet_editor_dock and sheet_editor_dock.has_method("set_sheet"):
		sheet_editor_dock.set_sheet(current_sheet)

func _hide_dock() -> void:
	"""Hide the sheet editor dock (currently no-op as dock stays visible)"""
	pass


func _is_object_sheet_resource(object: Object) -> bool:
	"""Check if the given object is a SpreadsheetResource resource"""
	if not object:
		return false
	if object is not Resource:
		return false

	return object is SpreadsheetResource

func _add_toolbar_buttons() -> void:
	button_2d = Button.new()
	button_2d.text = "Sheet Editor"
	button_2d.pressed.connect(_on_button_pressed)
	add_control_to_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, button_2d)

	button_3d = Button.new()
	button_3d.text = "Sheet Editor"
	button_3d.pressed.connect(_on_button_pressed)
	add_control_to_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, button_3d)

	button_inspector = Button.new()
	button_inspector.text = "Sheet Editor"
	button_inspector.pressed.connect(_on_button_pressed)
	add_control_to_container(EditorPlugin.CONTAINER_INSPECTOR_BOTTOM, button_inspector)

func _create_sheet_editor_dock() -> void:
	"""Create and initialize the sheet editor dock with signal connections"""
	sheet_editor_dock = DOCK_SCENE.instantiate()

	# Connect signals from the dock
	sheet_editor_dock.column_added.connect(_on_add_column_pressed)
	sheet_editor_dock.row_added.connect(_on_add_row_pressed)
	sheet_editor_dock.column_deleted.connect(_on_column_deleted)
	sheet_editor_dock.row_deleted.connect(_on_row_deleted)
	sheet_editor_dock.column_renamed.connect(_on_column_renamed)
	sheet_editor_dock.row_renamed.connect(_on_row_renamed)
	sheet_editor_dock.data_cleared.connect(_clear_all_data)
	sheet_editor_dock.save_requested.connect(_save_sheet)
	sheet_editor_dock.load_requested.connect(_load_sheet)
	sheet_editor_dock.close_requested.connect(_hide_dock)
	sheet_editor_dock.new_sheet_requested.connect(_create_new_sheet)
	sheet_editor_dock.sheet_selected.connect(_on_sheet_selected_from_recent)
	sheet_editor_dock.create_table_requested.connect(_on_create_table_requested)
func _on_add_column_pressed() -> void:
	"""Add a new column to the current sheet"""
	if not _validate_current_sheet():
		return

	var sheet := current_sheet as SpreadsheetResource
	sheet.column_count += 1
	_update_dock_ui()


func _on_add_row_pressed() -> void:
	"""Add a new row to the current sheet"""
	if not _validate_current_sheet():
		return

	var sheet := current_sheet as SpreadsheetResource
	sheet.row_count += 1
	_update_dock_ui()


func _on_column_renamed(col: int, new_name: String) -> void:
	"""Update column name in the sheet"""
	if not _validate_current_sheet():
		return

	var sheet := current_sheet as SpreadsheetResource
	sheet.set_column_name(col, new_name)
	_update_dock_ui()


func _on_row_renamed(row: int, new_name: String) -> void:
	"""Update row name in the sheet"""
	if not _validate_current_sheet():
		return

	var sheet := current_sheet as SpreadsheetResource
	sheet.set_row_name(row, new_name)
	_update_dock_ui()


func _on_column_deleted(col: int) -> void:
	"""Delete a column from the sheet"""
	if not _validate_current_sheet():
		return

	var sheet := current_sheet as SpreadsheetResource
	sheet.delete_column(col)
	_update_dock_ui()


func _on_row_deleted(row: int) -> void:
	"""Delete a row from the sheet"""
	if not _validate_current_sheet():
		return

	var sheet := current_sheet as SpreadsheetResource
	sheet.delete_row(row)
	_update_dock_ui()


func _clear_all_data() -> void:
	"""Clear all data from the current sheet"""
	if not _validate_current_sheet():
		return

	var sheet := current_sheet as SpreadsheetResource
	sheet.column_count = 0
	sheet.row_count = 0
	sheet.clear_all_cells()
	_update_dock_ui()


func _validate_current_sheet() -> bool:
	"""Validate that a valid sheet is currently loaded"""
	if not current_sheet:
		push_error("SpreadsheetPlugin: No sheet is currently loaded")
		return false
	if not current_sheet is SpreadsheetResource:
		push_error("SpreadsheetPlugin: Current resource is not a SpreadsheetResource")
		return false
	return true


func _update_dock_ui() -> void:
	"""Update the dock UI if available"""
	if sheet_editor_dock and sheet_editor_dock.has_method("update_ui"):
		sheet_editor_dock.update_ui()


func _create_new_sheet() -> void:
	"""Create a new SpreadsheetResource resource and start editing it"""
	var new_sheet := SpreadsheetResource.new()
	new_sheet.sheet_name = "Untitled Sheet"
	new_sheet.column_count = 3
	new_sheet.row_count = 5

	current_sheet = new_sheet
	_show_dock()

	# Select in inspector so it can be saved
	get_editor_interface().edit_resource(new_sheet)


func _save_sheet() -> void:
	"""Save the current sheet to file"""
	if not current_sheet:
		push_warning("Sheet Editor: No sheet to save")
		return

	var path := current_sheet.resource_path
	if path.is_empty():
		_show_save_dialog()
		return

	var error := ResourceSaver.save(current_sheet, path)
	if error == OK:
		print("Sheet saved to: ", path)
	else:
		push_error("Sheet Editor: Failed to save sheet - error code: " + str(error))


func _show_save_dialog() -> void:
	"""Show file dialog to save sheet with a new path"""
	if save_dialog == null:
		save_dialog = EditorFileDialog.new()
		save_dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
		save_dialog.access = EditorFileDialog.ACCESS_RESOURCES
		save_dialog.filters = PackedStringArray(["*.tres ; Godot Resource"])
		save_dialog.title = "Save Sheet As"
		save_dialog.file_selected.connect(_on_save_file_selected)
		save_dialog.canceled.connect(_on_save_dialog_canceled)
		get_editor_interface().get_base_control().add_child(save_dialog)

	var default_name := "new_sheet.tres"
	if current_sheet is SpreadsheetResource:
		var sheet := current_sheet as SpreadsheetResource
		if not sheet.sheet_name.is_empty() and sheet.sheet_name != "Untitled Sheet":
			default_name = sheet.sheet_name + ".tres"

	save_dialog.current_file = default_name
	save_dialog.current_dir = "res://"
	save_dialog.popup_centered_ratio(0.6)


func _on_save_file_selected(path: String) -> void:
	"""Save the sheet to the selected file path"""
	if not current_sheet:
		return

	if not path.ends_with(".tres"):
		path += ".tres"

	var error := ResourceSaver.save(current_sheet, path)
	if error == OK:
		print("Sheet saved to: ", path)
		current_sheet.resource_path = path
		get_editor_interface().get_resource_filesystem().scan()

		# Add to recent sheets
		if sheet_editor_dock and sheet_editor_dock.has_method("add_to_recent_sheets"):
			sheet_editor_dock.add_to_recent_sheets(path)
	else:
		push_error("Sheet Editor: Failed to save sheet - error code: " + str(error))


func _on_save_dialog_canceled() -> void:
	"""Handle save dialog cancellation"""
	pass  # Dialog remains in memory for reuse


func _on_load_file_selected(path: String) -> void:
	"""Load sheet from the selected file path"""
	_load_sheet_from_path(path)


func _on_load_dialog_canceled() -> void:
	"""Handle load dialog cancellation"""
	pass  # Dialog remains in memory for reuse


func _load_sheet() -> void:
	"""Show dialog to load a sheet from file"""
	_show_load_dialog()


func _show_load_dialog() -> void:
	"""Show file dialog to load an existing sheet"""
	if load_dialog == null:
		load_dialog = EditorFileDialog.new()
		load_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
		load_dialog.access = EditorFileDialog.ACCESS_RESOURCES
		load_dialog.filters = PackedStringArray(["*.tres ; Godot Resource"])
		load_dialog.title = "Load Sheet"
		load_dialog.file_selected.connect(_on_load_file_selected)
		load_dialog.canceled.connect(_on_load_dialog_canceled)
		get_editor_interface().get_base_control().add_child(load_dialog)

	load_dialog.current_dir = "res://"
	load_dialog.popup_centered_ratio(0.6)


func _load_sheet_from_path(path: String) -> void:
	"""Load a sheet from a given path"""
	var loaded_resource = ResourceLoader.load(path)

	if not loaded_resource:
		push_error("Sheet Editor: Failed to load resource from: " + path)
		return

	if not loaded_resource is SpreadsheetResource:
		push_error("Sheet Editor: File is not a SpreadsheetResource resource: " + path)
		return

	print("Sheet loaded from: ", path)

	current_sheet = loaded_resource
	_show_dock()
	get_editor_interface().edit_resource(loaded_resource)

	# Add to recent sheets
	if sheet_editor_dock and sheet_editor_dock.has_method("add_to_recent_sheets"):
		sheet_editor_dock.add_to_recent_sheets(path)


func _on_sheet_selected_from_recent(path: String) -> void:
	"""Handle selection from recent sheets list"""
	_load_sheet_from_path(path)


func _on_create_table_requested(table_name: String, file_name: String, rows: int, columns: int, save_path: String) -> void:
	"""Create a new table with specified parameters from the Create Table dialog"""
	var new_sheet := _create_sheet_resource(table_name, rows, columns)
	var full_path := _build_save_path(save_path, file_name)

	if _save_sheet_resource(new_sheet, full_path):
		_handle_successful_creation(new_sheet, full_path)


func _create_sheet_resource(table_name: String, rows: int, columns: int) -> SpreadsheetResource:
	"""Create a new SpreadsheetResource with the given parameters"""
	var sheet := SpreadsheetResource.new()
	sheet.sheet_name = table_name
	sheet.row_count = rows
	sheet.column_count = columns
	return sheet


func _build_save_path(save_path: String, file_name: String) -> String:
	"""Build a full save path from directory and filename"""
	var full_path := save_path
	if not full_path.begins_with("res://"):
		full_path = "res://" + full_path
	return full_path.path_join(file_name)


func _save_sheet_resource(sheet: SpreadsheetResource, path: String) -> bool:
	"""Save a sheet resource to the specified path"""
	# Ensure destination directory exists
	var dir_path := path.get_basename().get_basename()  # Get directory without filename
	if not dir_path.is_empty():
		var dir_access := DirAccess.open(dir_path.get_basename())
		if dir_access == null:
			# Directory doesn't exist, try to create it recursively
			var create_error := DirAccess.make_dir_recursive_absolute(dir_path)
			if create_error != OK:
				push_error("SpreadsheetPlugin: Failed to create directory '%s' - error: %d" % [dir_path, create_error])
				return false

	var error := ResourceSaver.save(sheet, path)
	if error != OK:
		push_error("SpreadsheetPlugin: Failed to save sheet to %s - error: %d" % [path, error])
		return false
	print("SpreadsheetPlugin: Sheet saved successfully to: ", path)
	return true


func _handle_successful_creation(sheet: SpreadsheetResource, path: String) -> void:
	"""Handle post-save actions after successful sheet creation"""
	sheet.resource_path = path
	get_editor_interface().get_resource_filesystem().scan()

	# Load and edit the new sheet
	current_sheet = sheet
	_show_dock()
	get_editor_interface().edit_resource(sheet)

	# Add to recent sheets
	if sheet_editor_dock and sheet_editor_dock.has_method("add_to_recent_sheets"):
		sheet_editor_dock.add_to_recent_sheets(path)


func _exit_tree() -> void:
	"""Clean up when plugin is disabled"""
	remove_control_from_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, button_2d)
	button_2d.queue_free()

	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, button_3d)
	button_3d.queue_free()

	remove_control_from_container(EditorPlugin.CONTAINER_INSPECTOR_BOTTOM, button_inspector)
	button_inspector.queue_free()

	remove_control_from_bottom_panel(sheet_editor_dock)
	sheet_editor_dock.queue_free()

	# Clean up dialogs
	if save_dialog:
		save_dialog.queue_free()
	if load_dialog:
		load_dialog.queue_free()


func _on_button_pressed() -> void:
	if is_instance_valid(current_sheet):
		make_bottom_panel_item_visible(sheet_editor_dock)
	else:
		print("No sheet selected or resource was freed")
