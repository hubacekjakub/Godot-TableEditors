extends Resource
class_name EnemyData
## EnemyData Resource - The "Vanilla Godot" approach
## This is the PAINFUL way to manage game data in Godot
## Each enemy requires a separate .tres file, manually created and edited

@export var enemy_name: String = "Unknown Enemy"
@export var hp: int = 100
@export var damage: int = 10
@export var speed: float = 3.0
@export var description: String = "A mysterious creature"
@export var enemy_color: Color = Color.WHITE
