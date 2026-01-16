extends CharacterState
class_name FallState

@export var dj_minimum_delay: int = 6
@export var coyote_frames: int = 6
var can_coyote_time: bool = false
var frame_count: int = 0

func enter(_msg := {}) -> void:
	super()
	frame_count = 0
	if _msg["PreviousState"] == "Idle" or _msg["PreviousState"] == "Run" or _msg["PreviousState"] == "Walk":
		can_coyote_time = true
	if _msg["PreviousState"] == "Jump":
		frame_count = dj_minimum_delay + 1

func unhandled_input(_event: InputEvent):
	super(_event)
	if Input.is_action_just_pressed("jump") && frame_count < coyote_frames && can_coyote_time:
		state_machine.transition_to("Jump")
	elif Input.is_action_just_pressed("jump") && not character.did_double_jump && frame_count > dj_minimum_delay:
		state_machine.transition_to("DoubleJump")
	if Input.is_action_just_pressed("use_left_arm"):
		state_machine.transition_to("ArmAttached", {"arm": "left"})
	if Input.is_action_just_pressed("use_right_arm"):
		state_machine.transition_to("ArmAttached", {"arm": "right"})

func physics_update(_delta: float, _move_character: bool = true) -> void:
	super(_delta)
	frame_count += 1
	if character.is_on_floor():
		state_machine.transition_to("Land")

func exit() -> void:
	can_coyote_time = false