extends CharacterState
class_name RunState

@export var walk_treshold: float = 0.4

@export var rdm_stream_delay: float = 0.1

@onready var rdm_stream_player: RandomStreamPlayer = $RandomStreamPlayer
@onready var rdm_stream_player2: RandomStreamPlayer = $RandomStreamPlayer2
@onready var animation_looping_timer: Timer = $AnimationLoopingTimer

func enter(_msg := {}) -> void:
	super()
	anim_duration = 1#character.skin.animation_tree.get_animation(self.name).length
	loop_sound()

func unhandled_input(_event: InputEvent):
	super(_event)
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Jump")

func loop_sound():
	rdm_stream_player.play_random()
	await get_tree().create_timer(rdm_stream_delay).timeout
	rdm_stream_player2.play_random()
	animation_looping_timer.wait_time = anim_duration / 2
	animation_looping_timer.timeout.connect(play_sound)
	animation_looping_timer.start()
	

func play_sound() -> void:
	rdm_stream_player.play_random()
	await get_tree().create_timer(rdm_stream_delay).timeout
	rdm_stream_player2.play_random()

func physics_update(_delta: float, _move_character: bool = true) -> void:
	super(_delta)
	if character.velocity.length() < walk_treshold:
		state_machine.transition_to("Walk")
	if not character.is_on_floor():
		state_machine.transition_to("Fall")

func exit() -> void:
	animation_looping_timer.stop()
	animation_looping_timer.timeout.disconnect(play_sound)
