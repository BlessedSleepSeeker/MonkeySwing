extends CharacterState
class_name DoubleJumpState

@onready var rdm_stream_player: RandomStreamPlayer = $RandomStreamPlayer

func enter(_msg := {}) -> void:
	character.did_double_jump = true
	character.velocity.y = physics_parameters.JUMP_IMPULSE
	rdm_stream_player.play_random()
	#character.particles_manager.emit("SmokeCloudDJ")
	super()
	play_animation("Jump")

func unhandled_input(_event: InputEvent):
	super(_event)

func physics_update(_delta: float, _move_character: bool = true) -> void:
	super(_delta)
	
	if character.is_on_floor():
		state_machine.transition_to("Idle")
	if character.velocity.y < 0:
		state_machine.transition_to("Fall")