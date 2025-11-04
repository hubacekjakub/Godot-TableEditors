extends Resource
class_name TestItemData

## Test class for parser verification
## This class demonstrates property types and @export decorators

@export var item_name: String = "Sword"
@export var damage: int = 10
@export var armor: float = 2.5
@export var is_stackable: bool = true
var description: String = "A sharp blade"
@export var rarity: float = 0.8

## Methods should be ignored
func get_damage() -> int:
	return damage
