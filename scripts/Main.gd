extends Node2D

@onready var ball = $Ball

func _ready():
	print("Godot QuickStart Template Ready!")

	# Position ball at center
	var screen_size = get_viewport().get_visible_rect().size
	ball.position = screen_size / 2

func _input(event):
	if event.is_action_pressed("ui_cancel"):
		get_tree().quit()
