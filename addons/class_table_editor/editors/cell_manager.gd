@tool
extends RefCounted
class_name CellManager

## CellManager - Handles creation and management of table cell editors
##
## Extracts cell creation, styling, and event binding logic from ClassTableDock
## to improve maintainability and separate concerns.

const TYPED_CELL_EDITOR_FACTORY := preload("res://addons/class_table_editor/utils/typed_cell_editor_factory.gd")

var dock: Control  # Reference to the dock for signal connections


func _init(p_dock: Control) -> void:
	dock = p_dock


## Create a type-specific cell editor for the given position.
func create_cell_editor(row: int, col: int, sheet: ClassTableResource) -> Control:
	# Get type info for this column
	var type_info = sheet.get_column_type_info(col)
	var type_id = type_info.get("type", TYPE_NIL)
	var type_name = type_info.get("type_name", "Variant")

	# Create type-specific editor
	var cell_editor = TYPED_CELL_EDITOR_FACTORY.create_editor(type_id, type_name, type_info)
	cell_editor.set_meta("row", row)
	cell_editor.set_meta("col", col)
	cell_editor.set_meta("type_id", type_id)
	cell_editor.set_meta("type_name", type_name)

	# Make cells match column width
	var col_name = sheet.get_column_name(col)
	var cell_width = max(120, col_name.length() * 8)
	cell_editor.custom_minimum_size = Vector2(cell_width, 30)

	# Set current value
	var current_value = sheet.get_cell(row, col)
	TYPED_CELL_EDITOR_FACTORY.set_editor_value(cell_editor, current_value)

	# Apply styling
	_apply_cell_styling(cell_editor, row, col, type_id)

	# Connect events
	_connect_cell_events(cell_editor, row, col)

	return cell_editor


## Apply appropriate styling to the cell editor.
func _apply_cell_styling(cell_editor: Control, row: int, col: int, type_id: int) -> void:
	# Style data cells with subtle alternating row colors
	var cell_style := StyleBoxFlat.new()
	# Use standard Godot theme colors with subtle alternation
	if row % 2 == 0:
		cell_style.bg_color = Color(0.24, 0.24, 0.24, 1)  # Slightly lighter
	else:
		cell_style.bg_color = Color(0.22, 0.22, 0.22, 1)  # Standard
	cell_style.border_width_right = 1
	cell_style.border_width_bottom = 1
	cell_style.border_color = Color(0.3, 0.3, 0.3, 1)

	# Apply styles based on control type
	if cell_editor is LineEdit:
		cell_editor.add_theme_stylebox_override("normal", cell_style)
		var focus_style := StyleBoxFlat.new()
		focus_style.bg_color = Color(0.25, 0.35, 0.45, 1)
		focus_style.border_width_left = 2
		focus_style.border_width_right = 2
		focus_style.border_width_top = 2
		focus_style.border_width_bottom = 2
		focus_style.border_color = Color(0.4, 0.6, 0.8, 1)
		cell_editor.add_theme_stylebox_override("focus", focus_style)
	elif cell_editor is Panel or cell_editor is PanelContainer:
		cell_editor.add_theme_stylebox_override("panel", cell_style)


## Connect appropriate events for the cell editor.
func _connect_cell_events(cell_editor: Control, row: int, col: int) -> void:
	# Connect signals based on control type
	if cell_editor is LineEdit:
		cell_editor.text_changed.connect(_on_typed_cell_changed.bind(row, col, cell_editor))
		cell_editor.text_submitted.connect(_on_typed_cell_submitted.bind(row, col, cell_editor))
		cell_editor.focus_entered.connect(_on_cell_focus_entered.bind(row, col, cell_editor))
		cell_editor.gui_input.connect(_on_cell_gui_input.bind(row, col))
	elif cell_editor is CheckBox:
		cell_editor.toggled.connect(_on_typed_cell_changed.bind(row, col, cell_editor))
		cell_editor.focus_entered.connect(_on_cell_focus_entered.bind(row, col, cell_editor))
		cell_editor.gui_input.connect(_on_cell_gui_input.bind(row, col))
	elif cell_editor is SpinBox:
		cell_editor.value_changed.connect(_on_typed_cell_changed.bind(row, col, cell_editor))
		cell_editor.get_line_edit().focus_entered.connect(_on_cell_focus_entered.bind(row, col, cell_editor))
		cell_editor.gui_input.connect(_on_cell_gui_input.bind(row, col))
	elif cell_editor is ColorPickerButton:
		cell_editor.color_changed.connect(_on_typed_cell_changed.bind(row, col, cell_editor))
		cell_editor.focus_entered.connect(_on_cell_focus_entered.bind(row, col, cell_editor))
		cell_editor.gui_input.connect(_on_cell_gui_input.bind(row, col))
	elif cell_editor is HBoxContainer:
		# Vector2/Vector3 editors
		cell_editor.gui_input.connect(_on_cell_gui_input.bind(row, col))
		for child in cell_editor.get_children():
			if child is SpinBox:
				child.value_changed.connect(_on_typed_cell_changed.bind(row, col, cell_editor))
				child.get_line_edit().focus_entered.connect(_on_cell_focus_entered.bind(row, col, cell_editor))


# Event forwarding methods - these will be connected to the dock's handlers
signal typed_cell_changed(new_value: Variant, row: int, col: int, editor: Control)
signal typed_cell_submitted(new_value: Variant, row: int, col: int, editor: Control)
signal cell_focus_entered(row: int, col: int, cell: Control)
signal cell_gui_input(event: InputEvent, row: int, col: int)


func _on_typed_cell_changed(new_value: Variant, row: int, col: int, editor: Control) -> void:
	typed_cell_changed.emit(new_value, row, col, editor)


func _on_typed_cell_submitted(new_value: Variant, row: int, col: int, editor: Control) -> void:
	typed_cell_submitted.emit(new_value, row, col, editor)


func _on_cell_focus_entered(row: int, col: int, cell: Control) -> void:
	cell_focus_entered.emit(row, col, cell)


func _on_cell_gui_input(event: InputEvent, row: int, col: int) -> void:
	cell_gui_input.emit(event, row, col)

