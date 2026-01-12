extends Node3D
class_name MouseFollowCamera

@export var parameters: CameraParameters = CameraParameters.new()

@onready var spring_arm: SpringArm3D = $SpringArm3D
@onready var real_camera: Camera3D = %Camera3D
@onready var raycast: RayCast3D = %HookRayCast
@onready var behind: Marker3D = %Behind
@onready var camera_position: Node3D = %CameraPosition

# @onready var sphere_indicator: Node3D = %ShpereIndicator

signal is_colliding(is_colliding: bool)

var raycast_range: float = 10:
	set(value):
		raycast_range = value
		raycast.target_position.z = -value

var _camera_input_direction: Vector2 = Vector2.ZERO

var character: Monkey

func _ready():
	character = owner as Monkey

func _unhandled_input(_event: InputEvent):
	## Make mouse aiming speed resolution-independent
	## (required when using the `canvas_items` stretch mode).
	var scale_factor: float = min(
			(float(get_viewport().size.x) / get_viewport().get_visible_rect().size.x),
			(float(get_viewport().size.y) / get_viewport().get_visible_rect().size.y)
	)

	if _event is InputEventMouseMotion && Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED && InputHandler.last_input_mode == InputHandler.INPUT_MODE.KEYBOARD:
		_camera_input_direction = _event.screen_relative * (InputHandler.camera_sensitivity * parameters.CAMERA_MOUSE_SENSIBILITY) * scale_factor

func rotate_camera(_delta) -> void:
	## Inverse the input if the option is toggled on.
	# if settings.read_setting_value_by_key("INVERSE_CAMERA"):
	# 	_camera_input_direction = _camera_input_direction * -1

	##	We scale the speed during bullet time, so they can move the camera faster during it.
	if character.bullet_time_on:
		self.rotation.x += self._camera_input_direction.y * (_delta * 5)
	else:
		self.rotation.x += self._camera_input_direction.y * _delta
	self.rotation.x = clampf(self.rotation.x, parameters.CAMERA_X_ROT_MIN, parameters.CAMERA_X_ROT_MAX)

	self.rotation.y -= self._camera_input_direction.x * _delta
	if character.bullet_time_on:
		self.rotation.y -= self._camera_input_direction.x * (_delta * 5) 
	else:
		self.rotation.y -= self._camera_input_direction.x * _delta
	self.rotation.y = wrapf(self.rotation.y, 0.0, deg_to_rad(360))
	self._camera_input_direction = Vector2.ZERO

func _process(_delta):
	pass#real_camera.global_position = lerp(real_camera.global_position, camera_position.global_position, parameters.SPRING_ARM_SPEED * _delta)

func _physics_process(_delta):
	if raycast.is_colliding():
		is_colliding.emit(true)
	else:
		is_colliding.emit(false)

	## input camera handling must be here because holding a stick in a direction does not trigger _unhandled_input somehow
	var scale_factor: float = min(
			(float(get_viewport().size.x) / get_viewport().get_visible_rect().size.x),
			(float(get_viewport().size.y) / get_viewport().get_visible_rect().size.y)
	)
	if InputHandler.last_input_mode == InputHandler.INPUT_MODE.CONTROLLER:
		_camera_input_direction = Input.get_vector("controller_camera_left", "controller_camera_right", "controller_camera_up", "controller_camera_down") * 10 * (InputHandler.camera_sensitivity * parameters.CAMERA_MOUSE_SENSIBILITY) * scale_factor
	# 	sphere_indicator.global_position = raycast.get_collision_point()
	# 	sphere_indicator.show()
	# else:
	# 	sphere_indicator.hide()


func tween_spring_length(length: float, tween_duration: float) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(spring_arm, "spring_length", length, tween_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)


func tween_fov(new_fov: float, tween_duration: float) -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(real_camera, "fov", new_fov, tween_duration).set_trans(Tween.TRANS_CUBIC).set_ease(Tween.EASE_IN_OUT)
