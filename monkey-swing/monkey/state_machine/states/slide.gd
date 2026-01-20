extends CharacterState

@export var stamina_decrease_multiplier_per_tick: float = 0.3
@export var sfx_tween_speed: float = 0.5

@onready var stream_player: AudioStreamPlayer = $AudioStreamPlayer

signal not_using_arm(side: bool)
signal trying_to_use_arm(side: bool)

func _ready():
	super()
	stream_player.volume_db = -30

func enter(_msg := {}) -> void:
	super(_msg)
	if character.current_stamina <= 1:
		state_machine.transition_to("Fall")
	stream_player.playing = true
	var tween: Tween = create_tween()
	tween.tween_property(stream_player, "volume_db", 0, sfx_tween_speed).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)


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
		print("gong to climb")
		state_machine.transition_to("Climb")

func exit() -> void:
	var tween: Tween = create_tween()
	tween.tween_property(stream_player, "volume_db", -30, sfx_tween_speed).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN)
	await tween.finished
	stream_player.playing = false
