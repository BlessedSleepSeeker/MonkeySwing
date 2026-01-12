extends CharacterState
class_name GlidingState

@export var normal_glide_gravity_clamp: float = -3
@export var fast_glide_gravity_clamp: float = -20

@export var normal_glide_horizontal_speed: float = 20
@export var fast_glide_horizontal_speed: float = 80

@export var tilt_amount_constant: float = 20

var fast_gliding: bool = false

func enter(_msg := {}) -> void:
	super()
	fast_gliding = false
	character.skin.toggle_fishing_rod(false)
	character.skin.kite_model.show()

func unhandled_input(_event: InputEvent):
	if Input.is_action_just_pressed("jump") && not character.did_double_jump:
		state_machine.transition_to("DoubleJump")
	if Input.is_action_just_pressed("forward"):
		fast_gliding = true
		toggle_fast_gliding_tilt()
	if Input.is_action_just_released("forward"):
		fast_gliding = false
		toggle_fast_gliding_tilt()

	var tilt_input: float = Input.get_action_strength("right") - Input.get_action_strength("left")

	var forward: Vector3 = character.camera.real_camera.global_basis.z
	var right: Vector3 = character.camera.real_camera.global_basis.x

	character.direction = forward * -1 + right * tilt_input
	character.direction.y = 0.0
	character.direction = character.direction.normalized()


func physics_update(_delta: float, _move_character: bool = true) -> void:
	super(_delta)
	if character.is_on_floor():
		state_machine.transition_to("Land")

	## Extracting vertical velocity
	var y_velocity: float = character.velocity.y
	character.velocity.y = 0.0

	if not fast_gliding:
		character.velocity = character.velocity.move_toward(character.direction * normal_glide_horizontal_speed, _delta * 100)
	else:
		character.velocity = character.velocity.move_toward(character.direction * fast_glide_horizontal_speed, _delta * 100)
	## Incorporating vertical velocity back into the mix.
	character.velocity.y = y_velocity
	character.velocity.y += physics_parameters.GRAVITY * _delta
	# making sure we never fall faster than that
	if character.velocity.y < 0:
		if not fast_gliding:
			character.velocity.y = clampf(character.velocity.y, normal_glide_gravity_clamp, 0)
		else:
			character.velocity.y = clampf(character.velocity.y, fast_glide_gravity_clamp, 0)
	character.move_and_slide()

func update(_delta: float) -> void:
	tilt_right_left(_delta)

func exit() -> void:
	character.skin.toggle_fishing_rod(true)
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(character.skin, "rotation:z", 0, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	character.skin.kite_model.hide()
	character.skin.travel_kite("to_glide")


func toggle_fast_gliding_tilt() -> void:
	var tween_value: float = deg_to_rad(20) if fast_gliding else 0.0
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(character.skin, "rotation:x", tween_value, 0.3).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
	if fast_gliding:
		character.skin.travel_kite("to_dive")
	if not fast_gliding:
		character.skin.travel_kite("to_glide")

var previous_dir: float = 0
var tilt_amount: float = 0
func tilt_right_left(_delta: float) -> void:
	# print("forward : %s" % forward)
	# print("direction : %f" % character.direction.z)
	# print("current rotation : %s" % character.skin.rotation)
	if character.direction.z < previous_dir:
		tilt_amount = deg_to_rad(tilt_amount_constant) if character.velocity.x <= 0 else deg_to_rad(-tilt_amount_constant)
	if character.direction.z > previous_dir:
		tilt_amount = deg_to_rad(-tilt_amount_constant) if character.velocity.x <= 0 else deg_to_rad(tilt_amount_constant)
	if character.direction.z == previous_dir:
		tilt_amount = 0
	character.skin.global_rotation.z = lerp_angle(character.skin.rotation.z, tilt_amount, smoothstep(0, 1, _delta * 10))
	previous_dir = character.direction.z
	return
