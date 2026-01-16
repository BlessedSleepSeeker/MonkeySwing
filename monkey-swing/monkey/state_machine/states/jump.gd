extends CharacterState
class_name JumpState

@export var dj_minimum_delay: int = 6

@onready var rdm_stream_player: RandomStreamPlayer = $RandomStreamPlayer

var current_frame: int = 0

func enter(_msg := {}) -> void:
	character.velocity.y = physics_parameters.JUMP_IMPULSE
	rdm_stream_player.play_random()
	fade_crosshair(true)
	current_frame = 0
	super()

func unhandled_input(_event: InputEvent):
	super(_event)
	if Input.is_action_just_pressed("jump") && not character.did_double_jump && current_frame > dj_minimum_delay:
		state_machine.transition_to("DoubleJump")
	if Input.is_action_just_pressed("use_left_arm"):
		state_machine.transition_to("ArmAttached", {"arm": "left"})
	if Input.is_action_just_pressed("use_right_arm"):
		state_machine.transition_to("ArmAttached", {"arm": "right"})

func physics_update(_delta: float, _move_character: bool = true) -> void:
	super(_delta)
	
	if character.is_on_floor():
		state_machine.transition_to("Land")
	if character.velocity.y < 0:
		state_machine.transition_to("Fall")
	current_frame += 1
