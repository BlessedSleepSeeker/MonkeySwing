extends CharacterState
class_name WalkState

@export var walk_treshold: float = 0.6
@export var idle_treshold: float = 0.1

func enter(_msg := {}) -> void:
	super()

func unhandled_input(_event: InputEvent):
	super(_event)
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Jump")

func physics_update(_delta: float, _move_character: bool = true) -> void:
	super(_delta)
	if character.velocity.length() > walk_treshold:
		state_machine.transition_to("Run")
	if character.velocity.length() < idle_treshold:
		state_machine.transition_to("Idle")

func exit() -> void:
	pass
