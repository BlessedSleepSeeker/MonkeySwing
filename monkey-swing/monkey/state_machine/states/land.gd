extends CharacterState
class_name LandState

@onready var rdm_stream_player: RandomStreamPlayer = $RandomStreamPlayer

func enter(_msg := {}) -> void:
	character.did_double_jump = false
	#anim_duration = character.skin.animation_tree.get_animation(self.name).length
	#character.particles_manager.emit("SmokeCloudLanding")
	rdm_stream_player.play_random()
	super()
	#get_tree().create_timer(anim_duration).timeout.connect(land_finished)

func unhandled_input(_event: InputEvent):
	super(_event)
	if Input.is_action_pressed("forward"):
		state_machine.transition_to("Walk")
	if Input.is_action_pressed("back"):
		state_machine.transition_to("Walk")
	if Input.is_action_pressed("right"):
		state_machine.transition_to("Walk")
	if Input.is_action_pressed("left"):
		state_machine.transition_to("Walk")
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Jump")

## actually : if we jump while landing, we get a second DJ because we go here thanks to the connection to here from the timer.
## FUNNY, DO NO FIX FOR NOW
func land_finished() -> void:
	if state_machine.state == self:
		state_machine.transition_to("Idle")

func physics_update(_delta: float, _move_character: bool = true) -> void:
	super(_delta)

func exit() -> void:
	pass
