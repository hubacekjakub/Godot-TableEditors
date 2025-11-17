extends RefCounted
class_name TypeSafeTestData

## Example class for demonstrating type-safe editing
## Use this class to create a table and test all supported editor types

@export var item_name: String = "Example Item"
@export var quantity: int = 1
@export var price: float = 9.99
@export var is_available: bool = true
@export var highlight_color: Color = Color.WHITE
@export var spawn_position: Vector2 = Vector2(100, 200)
@export var world_position: Vector3 = Vector3(0, 0, 0)

## Properties for testing edge cases
@export var empty_string: String = ""
@export var zero_int: int = 0
@export var negative_float: float = -5.5
@export var false_bool: bool = false
@export var transparent_color: Color = Color(1, 1, 1, 0)
@export var zero_vector2: Vector2 = Vector2.ZERO
@export var zero_vector3: Vector3 = Vector3.ZERO
