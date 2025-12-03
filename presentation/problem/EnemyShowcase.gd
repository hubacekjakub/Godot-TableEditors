@tool
extends Node2D
## Enemy Showcase - Demonstrates the "vanilla" resource approach
## Each enemy slot has an exported EnemyData resource that can be swapped in the Inspector
## This shows the PAIN: You need to open each .tres file separately to compare stats!

# Exported enemy resources - swap these in the Inspector
@export var enemy_1: EnemyData:
	set(value):
		enemy_1 = value
		if is_node_ready():
			update_panel(1, enemy_1, panel_1, label_1)

@export var enemy_2: EnemyData:
	set(value):
		enemy_2 = value
		if is_node_ready():
			update_panel(2, enemy_2, panel_2, label_2)

@export var enemy_3: EnemyData:
	set(value):
		enemy_3 = value
		if is_node_ready():
			update_panel(3, enemy_3, panel_3, label_3)

@export var enemy_4: EnemyData:
	set(value):
		enemy_4 = value
		if is_node_ready():
			update_panel(4, enemy_4, panel_4, label_4)

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
	"""Update all 4 panels with enemy data"""
	update_panel(1, enemy_1, panel_1, label_1)
	update_panel(2, enemy_2, panel_2, label_2)
	update_panel(3, enemy_3, panel_3, label_3)
	update_panel(4, enemy_4, panel_4, label_4)


func update_panel(slot_number: int, enemy: EnemyData, panel: Panel, label: Label) -> void:
	"""Update a single panel with enemy data"""
	if enemy == null:
		label.text = "Enemy Slot %d\n\n[Empty - Drag an EnemyData .tres file here]" % slot_number
		if panel:
			panel.modulate = Color(0.5, 0.5, 0.5, 0.7)
		return

	# Display enemy information
	label.text = "%s\n\n%s\n\nHP: %d\nDMG: %d\nSPD: %.1f" % [
		enemy.enemy_name,
		enemy.description,
		enemy.hp,
		enemy.damage,
		enemy.speed
	]

	# Apply enemy color to panel
	if panel:
		var tinted_color = enemy.enemy_color
		tinted_color.a = 0.9
		panel.modulate = tinted_color
