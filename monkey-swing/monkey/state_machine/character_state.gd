class_name CharacterState
extends State

var character: Monkey

@export var default_physics: bool = true
@export var apply_gravity: bool = true
@export var handle_movements_input: bool = true
@export var handle_camera_input: bool = true
@export var rotate_player_skin: bool = true
@export var allow_bullet_time = true
@export var should_play_animation_on_enter: bool = true
@export var update_max_speed_on_enter: bool = false

@export_group("Parameters")
@export var physics_parameters: CharacterPhysics = CharacterPhysics.new()
@export var camera_parameters: CameraParameters = CameraParameters.new()

@export_group("UI Assets")
@export var crosshair_texture: Texture2D = null

var anim_duration: float = 10

@onready var saved_max_speed: float = physics_parameters.MAX_SPEED


func _ready() -> void:
	character = owner as Monkey

func enter(_msg := {}) -> void:
	if should_play_animation_on_enter:
		play_animation()
	#character.hud_canvas.change_crosshair_to(crosshair_texture)
	character.camera.parameters = self.camera_parameters
	character.camera.tween_spring_length(self.camera_parameters.SPRING_ARM_LENGHT, self.camera_parameters.CAMERA_PARAMS_TWEEN_SPEED)
	character.camera.raycast_range = physics_parameters.GRAPPLE_MAX_RANGE
	if character.has_meta("debug_canvas"):
		character.debug_canvas.set_state(self.name)
	if update_max_speed_on_enter:
		physics_parameters.MAX_SPEED = max(abs(character.velocity.x) + abs(character.velocity.z), saved_max_speed)
		#print_debug("Updated max speed : %f" % physics_parameters.MAX_SPEED)


func input(_event: InputEvent) -> void:
	pass

func unhandled_input(_event: InputEvent) -> void:
	if handle_movements_input:
		character.raw_input = Input.get_vector("left", "right", "forward", "back")
		var forward: Vector3 = character.camera.real_camera.global_basis.z
		var right: Vector3 = character.camera.real_camera.global_basis.x

		character.direction = forward * character.raw_input.y + right * character.raw_input.x
		character.direction.y = 0.0
		character.direction = character.direction.normalized()
	if allow_bullet_time:
		if Input.is_action_just_pressed("bullet_time"):
			toggle_bullet_time(true)
		if Input.is_action_just_released("bullet_time"):
			toggle_bullet_time(false)

func physics_update(_delta: float, move_character: bool = true) -> void:
	if handle_camera_input:
		character.camera.rotate_camera(_delta)
	
	if default_physics:
		## Extracting vertical velocity
		var y_velocity: float = character.velocity.y
		character.velocity.y = 0.0
		
		## Horizontal Movement.
		## If we have no movement, stop using acceleration and use friction instead.
		## The more acceleration we have, the slower we accelerate.
		## The more friction we have, the slower we decelerate.
		if handle_movements_input:
			if character.raw_input == Vector2.ZERO:
				character.velocity = character.velocity.move_toward(character.direction * physics_parameters.MAX_SPEED, physics_parameters.FRICTION * _delta)
			else:
				character.velocity = character.velocity.move_toward(character.direction * physics_parameters.MAX_SPEED, physics_parameters.ACCELERATION * _delta)

		## Incorporating vertical velocity back into the mix.
		character.velocity.y = y_velocity

		if apply_gravity:
			character.velocity.y += physics_parameters.GRAVITY * _delta

		if move_character:
			character.move_and_slide()
	if character.has_meta("debug_canvas"):
		character.debug_canvas.set_speedometer(character.velocity)
		character.debug_canvas.set_world_position(character.position)
	## Reseting raw input
	character.raw_input = Vector2.ZERO

	## character angling
	if rotate_player_skin:
		if character.direction.length() > 0.2:
			character.last_movement_direction = character.direction
		var target_angle: float = Vector3.BACK.signed_angle_to(character.last_movement_direction, Vector3.UP)
		character.skin.global_rotation.y = lerp_angle(character.skin.rotation.y, target_angle, physics_parameters.ROTATION_SPEED * _delta)

func exit() -> void:
	pass

func play_animation(_anim_name: String = "") -> void:
	if _anim_name:
		character.play_animation(_anim_name)
	else:
		character.play_animation(self.name)

func fade_crosshair(direction: bool):
	pass#character.hud_canvas.fade_crosshair(direction)

func toggle_bullet_time(toggle: bool) -> void:
	#print("toggled : %s" % toggle)
	if toggle:
		if character.bullet_time_cooldown.is_stopped():
			character.bullet_time_on = true
			character.bullet_time_stopwatch.pause = false
			character.hud_canvas.tween_bullet_time(0, 1, physics_parameters.BULLET_TIME_TRANSITION_SPEED)
			var tween: Tween = get_tree().create_tween()
			tween.tween_property(Engine, "time_scale", physics_parameters.BULLET_TIME_STRENGHT, physics_parameters.BULLET_TIME_TRANSITION_SPEED).set_trans(Tween.TRANS_CUBIC)
	else:
		if character.bullet_time_stopwatch.current_time > 0.0:
			character.bullet_time_on = false
			character.bullet_time_cooldown.wait_time = max(character.bullet_time_stopwatch.current_time, physics_parameters.BULLET_TIME_TRANSITION_SPEED)
			character.bullet_time_cooldown.start()
			character.bullet_time_stopwatch.reset()
			character.hud_canvas.tween_bullet_time(1, 1, character.bullet_time_cooldown.wait_time)
			var tween: Tween = get_tree().create_tween()
			tween.tween_property(Engine, "time_scale", 1, physics_parameters.BULLET_TIME_TRANSITION_SPEED).set_trans(Tween.TRANS_CUBIC)
