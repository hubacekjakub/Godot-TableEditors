@tool
extends EditorPlugin

class_name ClassTablePlugin

const DOCK_SCENE := preload("res://addons/class_table_editor/ui/class_table_dock.tscn")
const TABLE_HANDLE_INSPECTOR_PLUGIN := preload("res://addons/class_table_editor/inspector_plugins/table_handle_inspector_plugin.gd")

const DEFAULT_COLUMN_COUNT := 3
const DEFAULT_ROW_COUNT := 5
const DEFAULT_SHEET_NAME := "Untitled Class Table"

var button_2d: Button
var button_3d: Button
var button_inspector: Button
var class_table_dock: Control
var current_sheet: ClassTableResource
var table_handle_inspector: EditorInspectorPlugin

# Dialog instances (reused to prevent memory leaks)
var save_dialog: EditorFileDialog = null
var load_dialog: EditorFileDialog = null


func _enter_tree() -> void:
	_add_toolbar_buttons()
	_create_class_table_dock()
	add_control_to_bottom_panel(class_table_dock, "Class Table")

	table_handle_inspector = TABLE_HANDLE_INSPECTOR_PLUGIN.new()
	add_inspector_plugin(table_handle_inspector)
	_debug_log("Class Table Plugin loaded")


func _exit_tree() -> void:
	if table_handle_inspector:
		remove_inspector_plugin(table_handle_inspector)

	_remove_toolbar_button(button_2d, EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU)
	_remove_toolbar_button(button_3d, EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU)
	_remove_toolbar_button(button_inspector, EditorPlugin.CONTAINER_INSPECTOR_BOTTOM)

	if class_table_dock:
		remove_control_from_bottom_panel(class_table_dock)
		class_table_dock.queue_free()

	# Clean up dialogs
	if save_dialog:
		save_dialog.queue_free()
	if load_dialog:
		load_dialog.queue_free()


## Return true when the object is a ClassTableResource.
func _handles(object: Object) -> bool:
	return object is ClassTableResource


## Start editing a ClassTableResource.
func _edit(object: Object) -> void:
	if not (object is ClassTableResource):
		_debug_log("Not a ClassTableResource, hiding dock")
		_hide_dock()
		return

	current_sheet = object as ClassTableResource
	_debug_log("Editing ClassTableResource")
	_show_dock()
	_add_to_recent(current_sheet.resource_path)


## Show the dock with the current sheet selected.
func _show_dock() -> void:
	if not class_table_dock:
		return

	class_table_dock.show()
	make_bottom_panel_item_visible(class_table_dock)
	if class_table_dock.has_method("set_sheet"):
		class_table_dock.set_sheet(current_sheet)


## Hide the dock.
func _hide_dock() -> void:
	if class_table_dock:
		class_table_dock.hide()


## Add all toolbar buttons used by the plugin.
func _add_toolbar_buttons() -> void:
	button_2d = _create_toolbar_button(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU)
	button_3d = _create_toolbar_button(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU)
	button_inspector = _create_toolbar_button(EditorPlugin.CONTAINER_INSPECTOR_BOTTOM)


## Create a toolbar button and register it in the requested container.
func _create_toolbar_button(container: int) -> Button:
	var button := Button.new()
	button.text = "Class Table"
	button.pressed.connect(_on_button_pressed)
	add_control_to_container(container, button)
	return button


## Remove a toolbar button from the editor UI.
func _remove_toolbar_button(button: Button, container: int) -> void:
	if not button:
		return
	remove_control_from_container(container, button)
	button.queue_free()


## Instantiate and wire up the dock scene.
func _create_class_table_dock() -> void:
	class_table_dock = DOCK_SCENE.instantiate()
	class_table_dock.editor_interface = get_editor_interface()

	class_table_dock.column_added.connect(_on_add_column_pressed)
	class_table_dock.row_added.connect(_on_add_row_pressed)
	class_table_dock.column_deleted.connect(_on_column_deleted)
	class_table_dock.row_deleted.connect(_on_row_deleted)
	class_table_dock.column_renamed.connect(_on_column_renamed)
	class_table_dock.row_renamed.connect(_on_row_renamed)
	class_table_dock.data_cleared.connect(_clear_all_data)
	class_table_dock.save_requested.connect(_save_sheet)
	class_table_dock.load_requested.connect(_load_sheet)
	class_table_dock.close_requested.connect(_hide_dock)
	class_table_dock.new_sheet_requested.connect(_create_new_sheet)
	class_table_dock.sheet_selected.connect(_on_sheet_selected_from_recent)
	class_table_dock.create_table_requested.connect(_on_create_table_requested)


## Add a column to the active sheet.
func _on_add_column_pressed() -> void:
	var sheet := _get_sheet_or_warn("Class Table: Cannot add column - no valid sheet loaded")
	if not sheet:
		return

	sheet.column_count += 1
	_refresh_dock()


## Add a row to the active sheet.
func _on_add_row_pressed() -> void:
	var sheet := _get_sheet_or_warn("Class Table: Cannot add row - no valid sheet loaded")
	if not sheet:
		return

	sheet.row_count += 1
	_refresh_dock()


## Rename a column in the sheet.
func _on_column_renamed(col: int, new_name: String) -> void:
	var sheet := _get_sheet_or_warn("Class Table: Cannot rename column - no valid sheet loaded")
	if not sheet:
		return

	sheet.set_column_name(col, new_name)
	_refresh_dock()


## Rename a row in the sheet.
func _on_row_renamed(row: int, new_name: String) -> void:
	var sheet := _get_sheet_or_warn("Class Table: Cannot rename row - no valid sheet loaded")
	if not sheet:
		return

	sheet.set_row_name(row, new_name)
	_refresh_dock()


## Delete a column from the sheet.
func _on_column_deleted(col: int) -> void:
	var sheet := _get_sheet_or_warn("Class Table: Cannot delete column - no valid sheet loaded")
	if not sheet:
		return

	sheet.delete_column(col)
	_refresh_dock()


## Delete a row from the sheet.
func _on_row_deleted(row: int) -> void:
	var sheet := _get_sheet_or_warn("Class Table: Cannot delete row - no valid sheet loaded")
	if not sheet:
		return

	sheet.delete_row(row)
	_refresh_dock()


## Clear all data from the active sheet.
func _clear_all_data() -> void:
	var sheet := _get_sheet_or_warn()
	if not sheet:
		return

	sheet.column_count = 0
	sheet.row_count = 0
	sheet.clear_all_cells()
	_refresh_dock()


## Create a new in-memory sheet and begin editing it.
func _create_new_sheet() -> void:
	var new_sheet := ClassTableResource.new()
	new_sheet.sheet_name = DEFAULT_SHEET_NAME
	new_sheet.column_count = DEFAULT_COLUMN_COUNT
	new_sheet.row_count = DEFAULT_ROW_COUNT

	current_sheet = new_sheet
	_show_dock()
	get_editor_interface().edit_resource(new_sheet)


## Save the current sheet, prompting for a path when needed.
func _save_sheet() -> void:
	var sheet := _get_sheet_or_warn("Class Table: No sheet to save")
	if not sheet:
		return

	var path := sheet.resource_path
	if path.is_empty():
		_show_save_dialog()
		return

	_save_sheet_to_path(sheet, path)


## Show a file dialog for choosing a save destination.
func _show_save_dialog() -> void:
	var sheet := _get_sheet_or_warn()
	if not sheet:
		return

	if save_dialog == null:
		save_dialog = EditorFileDialog.new()
		save_dialog.file_mode = EditorFileDialog.FILE_MODE_SAVE_FILE
		save_dialog.access = EditorFileDialog.ACCESS_RESOURCES
		save_dialog.filters = PackedStringArray(["*.tres ; Godot Resource"])
		save_dialog.title = "Save Class Table As"
		save_dialog.file_selected.connect(_on_save_file_selected)
		save_dialog.canceled.connect(_on_save_dialog_canceled)
		get_editor_interface().get_base_control().add_child(save_dialog)

	var default_name := "new_class_table.tres"
	if sheet.sheet_name != DEFAULT_SHEET_NAME and not sheet.sheet_name.is_empty():
		default_name = sheet.sheet_name.to_snake_case() + ".tres"

	save_dialog.current_file = default_name
	save_dialog.current_dir = "res://"
	save_dialog.popup_centered_ratio(0.6)


## Persist the sheet at the selected path.
func _on_save_file_selected(path: String) -> void:
	var sheet := _get_sheet_or_warn()
	if not sheet:
		return

	var target_path := _ensure_tres_extension(path)
	_save_sheet_to_path(sheet, target_path)


## Trigger the load dialog.
func _load_sheet() -> void:
	_show_load_dialog()


## Show a file dialog for choosing an existing sheet.
func _show_load_dialog() -> void:
	if load_dialog == null:
		load_dialog = EditorFileDialog.new()
		load_dialog.file_mode = EditorFileDialog.FILE_MODE_OPEN_FILE
		load_dialog.access = EditorFileDialog.ACCESS_RESOURCES
		load_dialog.filters = PackedStringArray(["*.tres ; Godot Resource"])
		load_dialog.title = "Load Class Table"
		load_dialog.file_selected.connect(_on_load_file_selected)
		load_dialog.canceled.connect(_on_load_dialog_canceled)
		get_editor_interface().get_base_control().add_child(load_dialog)

	load_dialog.current_dir = "res://"
	load_dialog.popup_centered_ratio(0.6)


## Load the sheet at the chosen path.
func _on_load_file_selected(path: String) -> void:
	_load_sheet_from_path(path)


## Handle save dialog cancellation (keeps dialog in memory for reuse).
func _on_save_dialog_canceled() -> void:
	pass  # Dialog remains in memory for reuse


## Handle load dialog cancellation (keeps dialog in memory for reuse).
func _on_load_dialog_canceled() -> void:
	pass  # Dialog remains in memory for reuse


## Load a sheet from disk and begin editing it.
func _load_sheet_from_path(path: String) -> void:
	var loaded_resource := ResourceLoader.load(path)
	if not loaded_resource:
		push_error("Class Table: Failed to load resource from: " + path)
		return

	if not (loaded_resource is ClassTableResource):
		push_error("Class Table: File is not a ClassTableResource: " + path)
		return

	var sheet := loaded_resource as ClassTableResource
	_debug_log("Class Table loaded from: " + path)

	current_sheet = sheet
	_show_dock()
	get_editor_interface().edit_resource(sheet)
	_add_to_recent(path)


## Load a sheet selected from the recent list.
func _on_sheet_selected_from_recent(path: String) -> void:
	_load_sheet_from_path(path)


## Create and save a sheet using parameters from the dialog.
func _on_create_table_requested(table_name: String, file_name: String, rows: int, columns: int, save_path: String) -> void:
	var new_sheet := ClassTableResource.new()
	new_sheet.sheet_name = table_name
	new_sheet.column_count = columns
	new_sheet.row_count = rows

	var resolved_name := _ensure_tres_extension(file_name)
	var full_path := _build_full_path(save_path, resolved_name)

	if _save_sheet_to_path(new_sheet, full_path) != OK:
		return

	current_sheet = new_sheet
	_show_dock()
	get_editor_interface().edit_resource(new_sheet)


## Handle toolbar button presses.
func _on_button_pressed() -> void:
	if current_sheet:
		make_bottom_panel_item_visible(class_table_dock)
	else:
		_debug_log("No class table selected")


## Update the dock UI when the sheet changes.
func _refresh_dock() -> void:
	if class_table_dock and class_table_dock.has_method("update_ui"):
		class_table_dock.update_ui()


## Add a path to the dock's recent list when available.
func _add_to_recent(path: String) -> void:
	if path.is_empty() or not class_table_dock:
		return
	if class_table_dock.has_method("add_to_recent_sheets"):
		class_table_dock.add_to_recent_sheets(path)


## Retrieve the current sheet or emit a warning when missing.
func _get_sheet_or_warn(warning: String = "") -> ClassTableResource:
	if current_sheet is ClassTableResource:
		return current_sheet
	if not warning.is_empty():
		push_warning(warning)
	return null


## Ensure the produced path ends with a .tres extension.
func _ensure_tres_extension(path: String) -> String:
	var result := path
	if not result.ends_with(".tres"):
		result += ".tres"
	return result


## Resolve the final resource path from user input.
func _build_full_path(save_path: String, file_name: String) -> String:
	var base := save_path.strip_edges()
	if base.is_empty():
		base = "res://"
	if not base.begins_with("res://"):
		base = "res://" + base
	return base.path_join(file_name)


## Persist a sheet and update editor state.
func _save_sheet_to_path(sheet: ClassTableResource, target_path: String) -> int:
	var error := ResourceSaver.save(sheet, target_path)
	if error != OK:
		push_error("Class Table: Failed to save sheet - error code: " + str(error))
		return error

	_debug_log("Class Table saved to: " + target_path)
	sheet.resource_path = target_path
	_add_to_recent(target_path)

	var filesystem := get_editor_interface().get_resource_filesystem()
	if filesystem:
		filesystem.scan()

	return OK


## Print debug output only when running in a debug build.
func _debug_log(message: String) -> void:
	if OS.is_debug_build():
		print(message)

