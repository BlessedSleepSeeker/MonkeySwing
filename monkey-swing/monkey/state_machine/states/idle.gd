extends CharacterState
class_name IdleState

@export var min_loop_before_fidget: int = 1
@export var fidget_chance: int = 50
var current_loop: int = 0

var rng: RandomNumberGenerator = RandomNumberGenerator.new()

@onready var crosshair_timer: Timer = $FadeCrosshairTimer

func enter(_msg := {}) -> void:
	current_loop = 0
	super()
	crosshair_timer.start()
	crosshair_timer.timeout.connect(fade_crosshair.bind(false))

func roll_for_fidget(_finished_animation: String):
	if current_loop >= min_loop_before_fidget && fidget_chance >= rng.randi_range(1, 100):
		play_animation("IdleFidget")
		current_loop = 0
	else:
		play_animation()
		current_loop += 1

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

func physics_update(_delta: float, _move_character: bool = true) -> void:
	super(_delta)
	if character.velocity.y < 0:
		state_machine.transition_to("Fall")

func exit() -> void:
	crosshair_timer.timeout.disconnect(fade_crosshair.bind(false))

func _notification(what: int) -> void:
	if what == Node.NOTIFICATION_WM_CLOSE_REQUEST || what == Node.NOTIFICATION_WM_GO_BACK_REQUEST:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)