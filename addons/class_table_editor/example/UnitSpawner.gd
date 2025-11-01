@tool
extends Node2D
## Example scene that spawns units from a ClassTable using TableHandles
## Demonstrates the class table editor workflow

# TableHandles for 4 different units
@export var unit_1_handle: TableHandle
@export var unit_2_handle: TableHandle
@export var unit_3_handle: TableHandle
@export var unit_4_handle: TableHandle

# Spacing between spawned units
@export var spawn_spacing: float = 150.0

# Reference to the info label
@onready var info_label: Label = $CanvasLayer/InfoLabel if has_node("CanvasLayer/InfoLabel") else null

func _ready() -> void:
	if Engine.is_editor_hint():
		return

	spawn_units()
	display_unit_info()

func spawn_units() -> void:
	"""Spawns 4 units based on the table handles"""
	var handles = [unit_1_handle, unit_2_handle, unit_3_handle, unit_4_handle]

	for i in range(handles.size()):
		if handles[i] == null:
			push_warning("Unit handle %d is null, skipping" % (i + 1))
			continue

		var unit_data = _get_data_from_handle(handles[i])
		if unit_data == null:
			push_warning("Could not get data from handle %d" % (i + 1))
			continue

		spawn_unit_visual(unit_data, i)

func spawn_unit_visual(unit_data: BaseUnit, index: int) -> void:
	"""Creates a visual representation of a unit"""
	var unit_node = Node2D.new()
	unit_node.name = unit_data.unit_name
	unit_node.position = Vector2(100 + index * spawn_spacing, 300)
	add_child(unit_node)

	# Define colors for each unit based on index
	var colors = [
		Color(0.7, 0.7, 0.9, 1),  # Blue for unit 1
		Color(0.2, 0.8, 0.2, 1),  # Green for unit 2
		Color(0.5, 0.3, 0.9, 1),  # Purple for unit 3
		Color(0.9, 0.9, 0.3, 1)   # Yellow for unit 4
	]

	# Create a colored circle to represent the unit
	var sprite = ColorRect.new()
	sprite.size = Vector2(60, 60)
	sprite.position = Vector2(-30, -30)  # Center the rect
	sprite.color = colors[index] if index < colors.size() else Color.WHITE
	unit_node.add_child(sprite)

	# Add unit name label
	var name_label = Label.new()
	name_label.text = unit_data.unit_name
	name_label.position = Vector2(-50, -60)
	name_label.add_theme_color_override("font_color", Color.WHITE)
	name_label.add_theme_color_override("font_outline_color", Color.BLACK)
	name_label.add_theme_constant_override("outline_size", 2)
	unit_node.add_child(name_label)

	# Add health bar background
	var health_bg = ColorRect.new()
	health_bg.size = Vector2(60, 8)
	health_bg.position = Vector2(-30, 35)
	health_bg.color = Color(0.2, 0.2, 0.2)
	unit_node.add_child(health_bg)

	# Add health bar
	var health_bar = ColorRect.new()
	health_bar.size = Vector2(60, 8)
	health_bar.position = Vector2(-30, 35)
	health_bar.color = Color(0.2, 0.8, 0.2)
	unit_node.add_child(health_bar)

	print("Spawned unit: %s at position %v" % [unit_data.unit_name, unit_node.position])


func display_unit_info() -> void:
	"""Displays information about all spawned units"""
	if info_label == null:
		return

	var info_text = "=== UNIT ROSTER ===\n\n"
	var handles = [unit_1_handle, unit_2_handle, unit_3_handle, unit_4_handle]

	for i in range(handles.size()):
		if handles[i] == null:
			continue

		var unit_data = _get_data_from_handle(handles[i])
		if unit_data == null:
			continue

		info_text += "Unit %d: %s\n" % [i + 1, unit_data.unit_name]
		info_text += "  HP: %d\n" % unit_data.max_health
		info_text += "  ATK: %d\n" % unit_data.attack_damage
		info_text += "  Speed: %.1f\n" % unit_data.movement_speed
		info_text += "  Info: %s\n\n" % unit_data.description

	info_label.text = info_text

func _get_data_from_handle(handle: TableHandle) -> BaseUnit:
	"""Extracts BaseUnit data from a TableHandle"""
	if handle == null or not handle.is_valid():
		return null

	# Use TableHandle's built-in to_resource() method to convert to BaseUnit
	return handle.to_resource(BaseUnit) as BaseUnit
