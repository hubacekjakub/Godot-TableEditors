extends CharacterBody2D

var speed = 300.0

func _physics_process(delta):
	var input_vector = Vector2.ZERO

	# Handle movement input (Arrow keys + WASD)
	if Input.is_action_pressed("ui_left") or Input.is_key_pressed(KEY_A):
		input_vector.x -= 1
	if Input.is_action_pressed("ui_right") or Input.is_key_pressed(KEY_D):
		input_vector.x += 1
	if Input.is_action_pressed("ui_up") or Input.is_key_pressed(KEY_W):
		input_vector.y -= 1
	if Input.is_action_pressed("ui_down") or Input.is_key_pressed(KEY_S):
		input_vector.y += 1

	# Normalize diagonal movement
	if input_vector != Vector2.ZERO:
		input_vector = input_vector.normalized()
		velocity = input_vector * speed
	else:
		velocity = Vector2.ZERO

	move_and_slide()

	# Keep ball within screen bounds
	var screen_size = get_viewport().get_visible_rect().size
	position.x = clamp(position.x, 25, screen_size.x - 25)
	position.y = clamp(position.y, 25, screen_size.y - 25)
