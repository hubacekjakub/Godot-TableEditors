@tool
extends Node2D
## Advanced demo showing multiple TableHandles and visual unit display
## Demonstrates complex TableHandle usage with 4 units, colors, and UI panels

# TableHandles for 4 different units
@export var unit_1_handle: TableHandle:
	set(value):
		unit_1_handle = value
		if is_node_ready():
			update_panel(1, unit_1_handle, panel_1, label_1)

@export var unit_2_handle: TableHandle:
	set(value):
		unit_2_handle = value
		if is_node_ready():
			update_panel(2, unit_2_handle, panel_2, label_2)

@export var unit_3_handle: TableHandle:
	set(value):
		unit_3_handle = value
		if is_node_ready():
			update_panel(3, unit_3_handle, panel_3, label_3)

@export var unit_4_handle: TableHandle:
	set(value):
		unit_4_handle = value
		if is_node_ready():
			update_panel(4, unit_4_handle, panel_4, label_4)

# Panel references
@onready var panel_1: Panel = $CanvasLayer/CenterContainer/VBoxContainer/GridContainer/Panel1
@onready var panel_2: Panel = $CanvasLayer/CenterContainer/VBoxContainer/GridContainer/Panel2
@onready var panel_3: Panel = $CanvasLayer/CenterContainer/VBoxContainer/GridContainer/Panel3
@onready var panel_4: Panel = $CanvasLayer/CenterContainer/VBoxContainer/GridContainer/Panel4

@onready var label_1: Label = $CanvasLayer/CenterContainer/VBoxContainer/GridContainer/Panel1/DescriptionLabel
@onready var label_2: Label = $CanvasLayer/CenterContainer/VBoxContainer/GridContainer/Panel2/DescriptionLabel
@onready var label_3: Label = $CanvasLayer/CenterContainer/VBoxContainer/GridContainer/Panel3/DescriptionLabel
@onready var label_4: Label = $CanvasLayer/CenterContainer/VBoxContainer/GridContainer/Panel4/DescriptionLabel

func _ready() -> void:
	update_panels()


func update_panels() -> void:
	"""Update all 4 panels with unit descriptions"""
	update_panel(1, unit_1_handle, panel_1, label_1)
	update_panel(2, unit_2_handle, panel_2, label_2)
	update_panel(3, unit_3_handle, panel_3, label_3)
	update_panel(4, unit_4_handle, panel_4, label_4)


func update_panel(slot_number: int, handle: TableHandle, panel: Panel, label: Label) -> void:
	"""Update a single panel with unit data"""
	if handle == null or not handle.is_valid():
		label.text = "Slot %d\n\n[Empty - Select a unit using the TableHandle]" % slot_number
		if panel:
			panel.modulate = Color(0.5, 0.5, 0.5, 0.7)
		return

	var unit_data = handle.get_data(BaseUnit) as BaseUnit
	if unit_data == null:
		label.text = "Slot %d\n\n[Invalid unit data]" % slot_number
		if panel:
			panel.modulate = Color(1.0, 0.5, 0.5, 0.7)
		return

	# Display unit information prominently
	label.text = "%s\n\n%s\n\nHP: %d\nATK: %d\nSPD: %.1f" % [
		unit_data.unit_name,
		unit_data.description,
		unit_data.max_health,
		unit_data.attack_damage,
		unit_data.movement_speed
	]

	# Apply unit color to panel with tint effect
	if panel:
		var tinted_color = unit_data.unit_color
		tinted_color.a = 0.9
		panel.modulate = tinted_color
