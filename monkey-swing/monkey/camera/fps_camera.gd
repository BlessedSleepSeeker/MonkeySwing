extends Node3D
class_name FPSCamera

@export var parameters: CameraParameters = CameraParameters.new()

@onready var raycast: RayCast3D = %AimRayCast

signal is_colliding(is_colliding: bool)

var raycast_range: float = 6:
	set(value):
		raycast_range = value
		raycast.target_position.z = -value

var _camera_input_direction: Vector2 = Vector2.ZERO

var character: Monkey
var real_camera = self

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
	
	if _event is InputEventMouseButton:
		pass

func rotate_camera(_delta) -> void:
	## Inverse the input if the option is toggled on.
	# if settings.read_setting_value_by_key("INVERSE_CAMERA"):
	# 	_camera_input_direction = _camera_input_direction * -1

	##	We scale the speed during bullet time, so they can move the camera faster during it.
	if character.bullet_time_on:
		self.rotation.x -= self._camera_input_direction.y * (_delta * 5)
	else:
		self.rotation.x -= self._camera_input_direction.y * _delta
	self.rotation.x = clampf(self.rotation.x, parameters.CAMERA_X_ROT_MIN, parameters.CAMERA_X_ROT_MAX)

	character.rotation.y -= self._camera_input_direction.x * _delta
	if character.bullet_time_on:
		character.rotation.y -= self._camera_input_direction.x * (_delta * 5) 
	else:
		character.rotation.y -= self._camera_input_direction.x * _delta
	
	character.rotation.y = wrapf(character.rotation.y, 0.0, deg_to_rad(360))
	self._camera_input_direction = Vector2.ZERO

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