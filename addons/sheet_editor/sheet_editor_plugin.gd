@tool
extends EditorPlugin

class_name SheetEditorPlugin

var button_2d: Button
var button_3d: Button
var button_inspector: Button
var sheet_editor_dock: Control

func _enter_tree() -> void:
	_add_toolbar_buttons()
	_create_sheet_editor_dock()
	add_control_to_bottom_panel(sheet_editor_dock, "Sheet Editor")

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
	_add_menu_and_button(sheet_editor_dock)
	_add_editable_grid(sheet_editor_dock)

func _add_menu_and_button(parent: VBoxContainer) -> void:
	var menubar = HBoxContainer.new()

	var menu_btn = MenuButton.new()
	menu_btn.text = "Menu"
	var popup = menu_btn.get_popup()
	popup.add_item("First option", 0)
	popup.add_item("Second option", 1)
	popup.id_pressed.connect(_on_menu_item_pressed)
	menubar.add_child(menu_btn)

	var base_btn = Button.new()
	base_btn.text = "Just Button"
	base_btn.pressed.connect(_on_base_button_pressed)
	menubar.add_child(base_btn)

	parent.add_child(menubar)

func _add_editable_grid(parent: VBoxContainer) -> void:
	var grid = GridContainer.new()
	grid.columns = 4
	for i in range(16):
		var line_edit = LineEdit.new()
		line_edit.text = str(randi() % 100)
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

func _on_button_pressed() -> void:
	print("Hello, editor!")

func _on_menu_item_pressed(id: int) -> void:
	if id == 0:
		print("first option")
	elif id == 1:
		print("second option")

func _on_base_button_pressed() -> void:
	print("just button pressed")
