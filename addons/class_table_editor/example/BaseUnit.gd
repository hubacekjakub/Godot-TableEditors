@tool
extends Resource
class_name BaseUnit
## Base unit data class for the example
## Demonstrates type-safe properties for the class table editor

@export var unit_name: String = "Unnamed Unit"
@export var max_health: int = 100
@export var attack_damage: int = 10
@export var movement_speed: float = 5.0
@export var description: String = "A basic unit"
@export var unit_color: Color = Color.WHITE
