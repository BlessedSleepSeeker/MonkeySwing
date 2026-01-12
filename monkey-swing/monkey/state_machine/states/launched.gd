extends CharacterState
class_name LaunchedState

@onready var cooldown: Timer = %LaunchedCD

func enter(_msg := {}) -> void:
	if cooldown.time_left == 0:
		cooldown.start()
	else:
		return state_machine.transition_to("Fall")
	super()
	character.did_double_jump = false


	character.velocity = Vector3.ZERO
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(character, "global_position", _msg["launcher_center_position"], _msg["velocity_decrease_time"])
