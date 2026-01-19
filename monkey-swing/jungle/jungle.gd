extends Node3D
class_name Jungle

func _ready():
	InputHandler.handle_mouse(false)

func _unhandled_input(_event):
	if Input.is_action_just_pressed("reset"):
		get_tree().reload_current_scene()

func _input(event: InputEvent) -> void:
	if event is InputEventMouseButton:
		Input.mouse_mode = Input.MOUSE_MODE_CAPTURED