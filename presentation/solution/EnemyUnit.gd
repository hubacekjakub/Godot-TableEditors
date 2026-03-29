extends RefCounted
class_name EnemyUnit
## EnemyUnit - The "Class Table" approach
## This class is used with the Class Table Editor
## All enemies live in ONE table, not separate .tres files

enum UnitType { MELEE, RANGED }

@export var enemy_name: String = "Unknown Enemy"
@export var hp: int = 100
@export var damage: int = 10
@export var speed: float = 3.0
@export var description: String = "A mysterious creature"
@export var enemy_color: Color = Color.WHITE
@export var unit_type: UnitType = UnitType.MELEE
