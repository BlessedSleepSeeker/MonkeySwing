extends CharacterState

@export var climbing_speed: float = 300
@export var speed_decrease_curve: Curve = Curve.new()

signal not_using_arm(side: bool)

func _ready():
	super()

func enter(_msg := {}) -> void:
	super(_msg)


func physics_update(_delta: float, _move_character: bool = true):

	var progress_percent: float = inverse_number_around_another(character.current_stamina / character.max_stamina, 0.5)
	#print(progress_percent)
	var sample: float = speed_decrease_curve.sample(progress_percent)
	var v_velo: float = (sample * climbing_speed)
	#print(sample)
	#print(v_velo)
	#print(character.velocity.y)
	character.velocity.y = v_velo * _delta
	super(_delta)
	decrease_stamina(_delta)

func stop_climb_state() -> void:
	if character.is_on_wall_only():
		state_machine.transition_to("Slide")
	else:
		state_machine.transition_to("Fall")

func decrease_stamina(_delta: float) -> void:
	character.current_stamina -= _delta
	if character.current_stamina <= 0:
		stop_climb_state()

func unhandled_input(_event: InputEvent) -> void:
	super(_event)
	if Input.is_action_just_released("use_left_arm"):
		not_using_arm.emit(false)
	if Input.is_action_just_released("use_right_arm"):
		not_using_arm.emit(true)

	if Input.is_action_just_released("use_left_arm") || Input.is_action_just_released("use_left_arm"):
		stop_climb_state()

func exit() -> void:
	print("exiting climb")
