extends CharacterState
class_name HookAimingState

func enter(_msg := {}) -> void:
	super()

func unhandled_input(_event: InputEvent):
	super(_event)
	if Input.is_action_just_pressed("jump") && not character.did_double_jump:
		state_machine.transition_to("DoubleJump")

func physics_update(_delta: float, _move_character: bool = true) -> void:
	super(_delta)
	if character.is_on_floor():
		state_machine.transition_to("Land")

func exit() -> void:
	pass
