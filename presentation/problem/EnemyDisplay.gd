@tool
extends Panel
## EnemyDisplay - Individual enemy panel with exposed EnemyData resource
## Demonstrates the "vanilla" approach where each enemy needs a separate resource

@export var enemy_data: EnemyData:
	set(value):
		enemy_data = value
		_update_display()

@onready var _label: Label = $DescriptionLabel


func _ready() -> void:
	_update_display()


func _update_display() -> void:
	if not is_node_ready():
		return

	if enemy_data == null:
		_label.text = "[Empty]\n\nDrag an EnemyData .tres file here"
		modulate = Color(0.5, 0.5, 0.5, 0.7)
		return

	# Display enemy information
	_label.text = "%s\n\n%s\n\nHP: %d\nDMG: %d\nSPD: %.1f" % [
		enemy_data.enemy_name,
		enemy_data.description,
		enemy_data.hp,
		enemy_data.damage,
		enemy_data.speed
	]

	# Apply enemy color to panel
	var tinted_color = enemy_data.enemy_color
	tinted_color.a = 0.9
	modulate = tinted_color
