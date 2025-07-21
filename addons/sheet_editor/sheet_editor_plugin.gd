@tool
extends EditorPlugin



class_name SheetEditorPlugin

# Preload the Sheet resource for type checking
const SHEET_SCRIPT_RESOURCE := preload("res://addons/sheet_editor/sheet.gd")

var button_2d: Button
var button_3d: Button
var button_inspector: Button
var sheet_editor_dock: Control
var columns_label: Label
var rows_label: Label
var item_list: ItemList
var current_sheet: Resource



func _enter_tree() -> void:
	_add_toolbar_buttons()
	_create_sheet_editor_dock()
	add_control_to_bottom_panel(sheet_editor_dock, "Sheet Editor")
	print("Sheet Editor Plugin loaded")
	# No need to register custom type for resource editor


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

	print("Current sheet:", current_sheet)
	print("Properties:", current_sheet.get_property_list())
	print("row_count:", current_sheet.get("row_count"))
	print("column_count:", current_sheet.get("column_count"))


	if current_sheet is Resource and current_sheet.get_class() == "Sheet":
		print("Current sheet:", current_sheet)
		print("Properties:", current_sheet.get_property_list())
		print("row_count:", current_sheet.get("row_count"))
		print("column_count:", current_sheet.get("column_count"))

	if current_sheet as Sheet:
		print("We have a Sheet resource")
		print(current_sheet.row_count)
		print(current_sheet.column_count)
		columns_label.text = "Columns: %d" % current_sheet.column_count
		rows_label.text = "Rows: %d" % current_sheet.row_count

	#sheet_editor_dock.show()

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
	sheet_editor_dock = VBoxContainer.new()

	var menubar = _create_menu_bar()
	sheet_editor_dock.add_child(menubar)

	# Main content: ItemList and Grid side by side (draggable)
	var main_panel = HSplitContainer.new()
	main_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL

	# ItemList (left)
	item_list = ItemList.new()
	item_list.add_item("Item 1")
	item_list.add_item("Item 2")
	item_list.add_item("Item 3")
	item_list.size_flags_vertical = Control.SIZE_EXPAND_FILL
	item_list.custom_minimum_size = Vector2(120, 0)
	main_panel.add_child(item_list)

	# Grid (right)
	var grid_panel = VBoxContainer.new()
	grid_panel.size_flags_vertical = Control.SIZE_EXPAND_FILL
	_add_editable_grid(grid_panel)
	main_panel.add_child(grid_panel)

	sheet_editor_dock.add_child(main_panel)

func _create_menu_bar() -> HBoxContainer:
	var menubar = HBoxContainer.new()

	var menu_btn = MenuButton.new()
	menu_btn.text = "Menu"
	var popup = menu_btn.get_popup()
	popup.add_item("Load", 0)
	popup.add_item("Save", 1)
	popup.id_pressed.connect(_on_menu_item_pressed)
	menubar.add_child(menu_btn)

	var base_btn = Button.new()
	base_btn.text = "Quick Test"
	base_btn.pressed.connect(_on_base_button_pressed)
	menubar.add_child(base_btn)

	columns_label = Label.new()
	columns_label.text = "Columns: 0"
	menubar.add_child(columns_label)

	rows_label = Label.new()
	rows_label.text = "Rows: 0"
	menubar.add_child(rows_label)

	return menubar

func _add_editable_grid(parent: VBoxContainer) -> void:
	var grid = GridContainer.new()
	grid.columns = 5
	for i in range(25):
		var line_edit = LineEdit.new()
		line_edit.text = str(i + 1)
		grid.add_child(line_edit)
	parent.add_child(grid)


func _exit_tree() -> void:
	remove_control_from_container(EditorPlugin.CONTAINER_CANVAS_EDITOR_MENU, button_2d)
	button_2d.queue_free()

	remove_control_from_container(EditorPlugin.CONTAINER_SPATIAL_EDITOR_MENU, button_3d)
	button_3d.queue_free()

	remove_control_from_container(EditorPlugin.CONTAINER_INSPECTOR_BOTTOM, button_inspector)
	button_inspector.queue_free()

	remove_control_from_bottom_panel(sheet_editor_dock)
	sheet_editor_dock.queue_free()

	# No need to unregister custom type for resource editor

func _on_button_pressed() -> void:
	print("Hello, editor!")

func _on_menu_item_pressed(id: int) -> void:
	if id == 0:
		print("first option")
	elif id == 1:
		print("second option")

func _on_base_button_pressed() -> void:
	print("just button pressed")
