@tool
extends VBoxContainer
## Main dock for Class Table Editor v2.
## Toolbar: [Load Class] [Save] [+Row] [-Row]   |   Status label
## Below: TableGrid with inline editing.

var _resource: ClassTableResourceV2 = null
var _table_grid: TableGrid = null
var _status_label: Label = null
var _file_dialog: EditorFileDialog = null

# Toolbar buttons
var _btn_load_class: Button
var _btn_save: Button
var _btn_add_row: Button
var _btn_remove_row: Button
var _btn_new_table: Button


func _ready() -> void:
	_build_toolbar()

	var sep := HSeparator.new()
	add_child(sep)

	# Table grid
	_table_grid = TableGrid.new()
	_table_grid.size_flags_vertical = SIZE_EXPAND_FILL
	_table_grid.cell_edited.connect(_on_cell_edited)
	add_child(_table_grid)

	_update_button_states()


# ── Toolbar ───────────────────────────────────────────────────────────

func _build_toolbar() -> void:
	var toolbar := HBoxContainer.new()
	toolbar.add_theme_constant_override("separation", 4)
	add_child(toolbar)

	_btn_new_table = Button.new()
	_btn_new_table.text = "New Table"
	_btn_new_table.tooltip_text = "Create a new table from a GDScript class"
	_btn_new_table.pressed.connect(_on_new_table_pressed)
	toolbar.add_child(_btn_new_table)

	_btn_load_class = Button.new()
	_btn_load_class.text = "Load .tres"
	_btn_load_class.tooltip_text = "Load an existing table resource"
	_btn_load_class.pressed.connect(_on_load_pressed)
	toolbar.add_child(_btn_load_class)

	_btn_save = Button.new()
	_btn_save.text = "Save"
	_btn_save.tooltip_text = "Save the table resource"
	_btn_save.pressed.connect(_on_save_pressed)
	toolbar.add_child(_btn_save)

	var spacer := Control.new()
	spacer.size_flags_horizontal = SIZE_EXPAND_FILL
	toolbar.add_child(spacer)

	_btn_add_row = Button.new()
	_btn_add_row.text = "+ Row"
	_btn_add_row.tooltip_text = "Add a new row"
	_btn_add_row.pressed.connect(_on_add_row_pressed)
	toolbar.add_child(_btn_add_row)

	_btn_remove_row = Button.new()
	_btn_remove_row.text = "- Row"
	_btn_remove_row.tooltip_text = "Remove the last row"
	_btn_remove_row.pressed.connect(_on_remove_row_pressed)
	toolbar.add_child(_btn_remove_row)

	var spacer2 := Control.new()
	spacer2.size_flags_horizontal = SIZE_EXPAND_FILL
	toolbar.add_child(spacer2)

	_status_label = Label.new()
	_status_label.text = "No table loaded"
	toolbar.add_child(_status_label)


# ── Actions ───────────────────────────────────────────────────────────

func _on_new_table_pressed() -> void:
	_open_file_dialog("Select GDScript class", ["*.gd ; GDScript Files"], _on_class_file_selected)


func _on_load_pressed() -> void:
	_open_file_dialog("Load Table Resource", ["*.tres ; Table Resources"], _on_tres_file_selected)


func _on_save_pressed() -> void:
	if _resource == null:
		return
	if _resource.resource_path.is_empty():
		_open_file_dialog("Save Table As...", ["*.tres ; Table Resources"], _on_save_path_selected, EditorFileDialog.FILE_MODE_SAVE_FILE)
	else:
		_save_resource(_resource.resource_path)


func _on_add_row_pressed() -> void:
	if _resource == null:
		return
	_resource.add_row()
	_table_grid.rebuild()
	_update_status()


func _on_remove_row_pressed() -> void:
	if _resource == null or _resource.row_count == 0:
		return
	_resource.remove_row(_resource.row_count - 1)
	_table_grid.rebuild()
	_update_status()


# ── File dialog ───────────────────────────────────────────────────────

func _open_file_dialog(title: String, filters: PackedStringArray, callback: Callable, mode: EditorFileDialog.FileMode = EditorFileDialog.FILE_MODE_OPEN_FILE) -> void:
	if _file_dialog:
		_file_dialog.queue_free()

	_file_dialog = EditorFileDialog.new()
	_file_dialog.title = title
	_file_dialog.file_mode = mode
	_file_dialog.access = EditorFileDialog.ACCESS_RESOURCES
	for f: String in filters:
		_file_dialog.add_filter(f)
	_file_dialog.file_selected.connect(callback)
	add_child(_file_dialog)
	_file_dialog.popup_centered(Vector2i(700, 500))


func _on_class_file_selected(path: String) -> void:
	var res := ClassTableResourceV2.new()
	if not res.create_from_class(path):
		_status_label.text = "ERROR: No @export properties found"
		return

	# Add a few starter rows
	res.add_row("row_1")
	res.add_row("row_2")
	res.add_row("row_3")

	_set_resource(res)


func _on_tres_file_selected(path: String) -> void:
	var res: Resource = load(path)
	if res is ClassTableResourceV2:
		_set_resource(res as ClassTableResourceV2)
	else:
		_status_label.text = "ERROR: Not a ClassTableResourceV2"


func _on_save_path_selected(path: String) -> void:
	_save_resource(path)


func _save_resource(path: String) -> void:
	if _resource == null:
		return
	_resource.resource_path = path
	var err: int = ResourceSaver.save(_resource, path)
	if err == OK:
		_status_label.text = "Saved: %s" % path.get_file()
	else:
		_status_label.text = "ERROR saving: %d" % err


# ── Internal ──────────────────────────────────────────────────────────

func _set_resource(res: ClassTableResourceV2) -> void:
	_resource = res
	_table_grid.set_resource(_resource)
	_update_status()
	_update_button_states()


## Called by plugin._edit() when a .tres is double-clicked in FileSystem.
func edit_resource(res: ClassTableResourceV2) -> void:
	_set_resource(res)


func _on_cell_edited(row: int, col: int, value: Variant) -> void:
	_update_status()


func _update_status() -> void:
	if _resource == null:
		_status_label.text = "No table loaded"
	else:
		var saved: String = _resource.resource_path.get_file() if not _resource.resource_path.is_empty() else "(unsaved)"
		_status_label.text = "%s | %d cols × %d rows | %s" % [
			_resource.table_name, _resource.column_count, _resource.row_count, saved]


func _update_button_states() -> void:
	var has_resource: bool = _resource != null
	_btn_save.disabled = not has_resource
	_btn_add_row.disabled = not has_resource
	_btn_remove_row.disabled = not has_resource or (_resource and _resource.row_count == 0)
