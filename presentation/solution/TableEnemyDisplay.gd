@tool
extends Panel
## EnemyDisplay - Individual enemy panel using TableHandle
## Demonstrates the "solution" approach with Class Table Editor

@export var enemy_handle: TableHandle:
	set(value):
		enemy_handle = value
		_update_display()

@onready var _label: Label = $DescriptionLabel


func _ready() -> void:
	_update_display()


func _update_display() -> void:
	if not is_node_ready():
		return

	if enemy_handle == null or not enemy_handle.is_valid():
		_label.text = "[Empty]\n\nSelect a unit from the TableHandle dropdown"
		modulate = Color(0.5, 0.5, 0.5, 0.7)
		return

	# Get typed data using the Class Table Editor's reflection system
	var enemy = enemy_handle.get_data(EnemyUnit) as EnemyUnit
	if enemy == null:
		_label.text = "[Invalid]\n\nCould not load unit data"
		modulate = Color(1.0, 0.5, 0.5, 0.7)
		return

	# Display unit information
	_label.text = "%s\n\n%s\n\nHP: %d\nDMG: %d\nSPD: %.1f" % [
		enemy.enemy_name,
		enemy.description,
		enemy.hp,
		enemy.damage,
		enemy.speed
	]

	# Apply unit color to panel
	var tinted_color = enemy.enemy_color
	tinted_color.a = 0.9
	modulate = tinted_color
