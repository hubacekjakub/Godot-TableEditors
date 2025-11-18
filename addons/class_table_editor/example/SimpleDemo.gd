@tool
extends Control
## Simple demo showing unit properties from a TableHandle
## Demonstrates basic TableHandle usage and data extraction

@export var unit: TableHandle:
	set(value):
		unit = value
		if is_node_ready():
			_update_display()

@onready var properties_label: Label = $PanelContainer/VBoxContainer/PropertiesLabel

func _ready() -> void:
	_update_display()

func _update_display() -> void:
	"""Update the display with unit properties"""
	# Safety check - ensure label exists
	if properties_label == null:
		return

	if unit == null:
		properties_label.text = "[No unit selected]"
		return

	# Convert handle to BaseUnit resource
	var unit_data = unit.get_data(BaseUnit) as BaseUnit

	if unit_data == null:
		properties_label.text = "[Invalid unit data]"
		return

	# Format properties nicely
	var text = ""
	text += "Unit: %s\n" % unit_data.unit_name
	text += "\n"
	text += "Max Health: %d\n" % unit_data.max_health
	text += "Attack Damage: %d\n" % unit_data.attack_damage
	text += "Movement Speed: %.1f\n" % unit_data.movement_speed
	text += "\n"
	text += "Description:\n%s" % unit_data.description

	properties_label.text = text
