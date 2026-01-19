extends CharacterState

@export var stamina_decrease_multiplier_per_tick: float = 0.3

@onready var random_stream_player: RandomStreamPlayer = $RandomStreamPlayer

signal not_using_arm(side: bool)
signal trying_to_use_arm(side: bool)

func enter(_msg := {}) -> void:
	super(_msg)
	if character.current_stamina <= 1:
		state_machine.transition_to("Fall")


func physics_update(_delta: float, _move_character: bool = true):
	super(_delta)
	character.current_stamina -= _delta * stamina_decrease_multiplier_per_tick
	if character.current_stamina <= 0:
		state_machine.transition_to("Fall")
	if not character.is_on_wall_only():
		state_machine.transition_to("Fall")


func unhandled_input(_event: InputEvent) -> void:
	super(_event)
	if Input.is_action_just_pressed("use_left_arm"):
		trying_to_use_arm.emit(false)
	if Input.is_action_just_released("use_left_arm"):
		not_using_arm.emit(false)

	if Input.is_action_just_pressed("use_right_arm"):
		trying_to_use_arm.emit(true)
	if Input.is_action_just_released("use_right_arm"):
		not_using_arm.emit(true)

	if Input.is_action_pressed("use_left_arm") && Input.is_action_pressed("use_right_arm"):
		state_machine.transition_to("Climb")

func exit() -> void:
	pass
