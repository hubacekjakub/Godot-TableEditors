@tool
extends EditorPlugin

class_name SheetEditorPlugin

# Preload the dock scene
const DOCK_SCENE := preload("res://addons/sheet_editor/sheet_editor_dock.tscn")

var button_2d: Button
var button_3d: Button
var button_inspector: Button
var sheet_editor_dock: Control
var current_sheet: Resource



func _enter_tree() -> void:
	_add_toolbar_buttons()
	_create_sheet_editor_dock()
	add_control_to_bottom_panel(sheet_editor_dock, "Sheet Editor")
	print("Sheet Editor Plugin loaded")


func _handles(object: Object) -> bool:
	if _is_object_sheet_resource(object):
		return true

	return false

func _edit(object: Object) -> void:
	if not _is_object_sheet_resource(object):
		print("Not a Sheet resource, hiding dock")
		_hide_dock()
		return

	print("Editing Sheet resource")
	current_sheet = object
	_show_dock()


func _show_dock() -> void:
	make_bottom_panel_item_visible(sheet_editor_dock)
	if sheet_editor_dock and sheet_editor_dock.has_method("set_sheet"):
		sheet_editor_dock.set_sheet(current_sheet)

func _hide_dock() -> void:
	return
	#sheet_editor_dock.hide()


func _is_object_sheet_resource(object: Object) -> bool:
	if not object:
		return false
	if object is not Resource:
		return false

	# best approach I quess
	if object is Sheet:
		return true

	# second approach, uses preloaded script variable
	#if object.get_script() == SHEET_SCRIPT_RESOURCE:
	#	return true

	# third approach, uses string comparison
	#if object.get_script() and object.get_script().get_global_name() == "Sheet":
	#	return true

	return false

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
	# Load the dock scene
	print("Loading dock scene...")
	sheet_editor_dock = DOCK_SCENE.instantiate()
	print("Dock scene loaded: ", sheet_editor_dock)

	# Connect signals from the dock
	print("Connecting signals...")
	if sheet_editor_dock.has_signal("column_added"):
		sheet_editor_dock.column_added.connect(_on_add_column_pressed)
		print("✓ Connected column_added signal")
	if sheet_editor_dock.has_signal("row_added"):
		sheet_editor_dock.row_added.connect(_on_add_row_pressed)
		print("✓ Connected row_added signal")
	if sheet_editor_dock.has_signal("column_deleted"):
		sheet_editor_dock.column_deleted.connect(_on_column_deleted)
		print("✓ Connected column_deleted signal")
	if sheet_editor_dock.has_signal("row_deleted"):
		sheet_editor_dock.row_deleted.connect(_on_row_deleted)
		print("✓ Connected row_deleted signal")
	if sheet_editor_dock.has_signal("column_renamed"):
		sheet_editor_dock.column_renamed.connect(_on_column_renamed)
		print("✓ Connected column_renamed signal")
	if sheet_editor_dock.has_signal("row_renamed"):
		sheet_editor_dock.row_renamed.connect(_on_row_renamed)
		print("✓ Connected row_renamed signal")
	if sheet_editor_dock.has_signal("data_cleared"):
		sheet_editor_dock.data_cleared.connect(_clear_all_data)
		print("✓ Connected data_cleared signal")
	if sheet_editor_dock.has_signal("save_requested"):
		sheet_editor_dock.save_requested.connect(_save_sheet)
		print("✓ Connected save_requested signal")
	if sheet_editor_dock.has_signal("close_requested"):
		sheet_editor_dock.close_requested.connect(_hide_dock)
		print("✓ Connected close_requested signal")
	if sheet_editor_dock.has_signal("new_sheet_requested"):
		sheet_editor_dock.new_sheet_requested.connect(_create_new_sheet)
		print("✓ Connected new_sheet_requested signal")
func _on_add_column_pressed() -> void:
	print("=== ADD COLUMN PRESSED ===")
	print("Current sheet: ", current_sheet)

	if not current_sheet or not current_sheet is Sheet:
		print("ERROR: No valid sheet!")
		return

	var sheet := current_sheet as Sheet
	print("Before: column_count = ", sheet.column_count)
	sheet.column_count += 1
	print("After: column_count = ", sheet.column_count)

	if sheet_editor_dock and sheet_editor_dock.has_method("update_ui"):
		print("Calling update_ui()...")
		sheet_editor_dock.update_ui()
	else:
		print("ERROR: sheet_editor_dock or update_ui() not available")

	print("=== ADD COLUMN COMPLETE ===")


func _on_add_row_pressed() -> void:
	print("=== ADD ROW PRESSED ===")
	print("Current sheet: ", current_sheet)

	if not current_sheet or not current_sheet is Sheet:
		print("ERROR: No valid sheet!")
		return

	var sheet := current_sheet as Sheet
	print("Before: row_count = ", sheet.row_count)
	sheet.row_count += 1
	print("After: row_count = ", sheet.row_count)

	if sheet_editor_dock and sheet_editor_dock.has_method("update_ui"):
		print("Calling update_ui()...")
		sheet_editor_dock.update_ui()
	else:
		print("ERROR: sheet_editor_dock or update_ui() not available")

	print("=== ADD ROW COMPLETE ===")


# Column naming (P1-008)
func _on_column_renamed(col: int, new_name: String) -> void:
	print("=== RENAME COLUMN %d ==="%col)
	print("New name: '%s'" % new_name)

	if not current_sheet or not current_sheet is Sheet:
		print("ERROR: No valid sheet!")
		return

	var sheet := current_sheet as Sheet
	sheet.set_column_name(col, new_name)

	if sheet_editor_dock and sheet_editor_dock.has_method("update_ui"):
		sheet_editor_dock.update_ui()

	print("=== COLUMN RENAMED ===")


# Row naming (P1-013)
func _on_row_renamed(row: int, new_name: String) -> void:
	print("=== RENAME ROW %d ===" % row)
	print("New name: '%s'" % new_name)

	if not current_sheet or not current_sheet is Sheet:
		print("ERROR: No valid sheet!")
		return

	var sheet := current_sheet as Sheet
	sheet.set_row_name(row, new_name)

	if sheet_editor_dock and sheet_editor_dock.has_method("update_ui"):
		sheet_editor_dock.update_ui()

	print("=== ROW RENAMED ===")


# Column deletion (P1-009)
func _on_column_deleted(col: int) -> void:
	print("=== DELETE COLUMN %d ===" % col)

	if not current_sheet or not current_sheet is Sheet:
		print("ERROR: No valid sheet!")
		return

	var sheet := current_sheet as Sheet
	print("Before: column_count = ", sheet.column_count)

	sheet.delete_column(col)

	print("After: column_count = ", sheet.column_count)

	if sheet_editor_dock and sheet_editor_dock.has_method("update_ui"):
		sheet_editor_dock.update_ui()

	print("=== COLUMN DELETED ===")


# Row deletion (P1-014)
func _on_row_deleted(row: int) -> void:
	print("=== DELETE ROW %d ===" % row)

	if not current_sheet or not current_sheet is Sheet:
		print("ERROR: No valid sheet!")
		return

	var sheet := current_sheet as Sheet
	print("Before: row_count = ", sheet.row_count)

	sheet.delete_row(row)

	print("After: row_count = ", sheet.row_count)

	if sheet_editor_dock and sheet_editor_dock.has_method("update_ui"):
		sheet_editor_dock.update_ui()

	print("=== ROW DELETED ===")


func _clear_all_data() -> void:
	if not current_sheet or not current_sheet is Sheet:
		return

	var sheet := current_sheet as Sheet
	sheet.column_count = 0
	sheet.row_count = 0
	sheet.clear_all_cells()  # Also clear cell data
	if sheet_editor_dock and sheet_editor_dock.has_method("update_ui"):
		sheet_editor_dock.update_ui()
	print("Cleared all data including cells")


func _create_new_sheet() -> void:
	"""Create a new Sheet resource and start editing it"""
	print("=== CREATING NEW SHEET ===")

	# Create a new Sheet instance
	var new_sheet := Sheet.new()
	new_sheet.sheet_name = "Untitled Sheet"
	new_sheet.column_count = 3  # Start with 3 columns
	new_sheet.row_count = 5     # Start with 5 rows

	print("New sheet created: ", new_sheet)
	print("  sheet_name: ", new_sheet.sheet_name)
	print("  column_count: ", new_sheet.column_count)
	print("  row_count: ", new_sheet.row_count)

	# Set it as the current sheet and start editing
	current_sheet = new_sheet
	_show_dock()

	# Also select it in the inspector so it can be saved
	get_editor_interface().edit_resource(new_sheet)

	print("=== NEW SHEET READY ===")


func _save_sheet() -> void:
	if not current_sheet:
		print("No sheet to save")
		return

	# Get the resource path
	var path := current_sheet.resource_path
	if path.is_empty():
		print("Sheet has no path, cannot save")
		return

	var error := ResourceSaver.save(current_sheet, path)
	if error == OK:
		print("Sheet saved successfully to: ", path)
	else:
		push_error("Failed to save sheet: " + str(error))


func _exit_tree() -> void:
	remove_control_from_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, button_2d)
	button_2d.queue_free()

	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, button_3d)
	button_3d.queue_free()

	remove_control_from_container(EditorPlugin.CONTAINER_INSPECTOR_BOTTOM, button_inspector)
	button_inspector.queue_free()

	remove_control_from_bottom_panel(sheet_editor_dock)
	sheet_editor_dock.queue_free()


func _on_button_pressed() -> void:
	if current_sheet:
		make_bottom_panel_item_visible(sheet_editor_dock)
	else:
		print("No sheet selected")

