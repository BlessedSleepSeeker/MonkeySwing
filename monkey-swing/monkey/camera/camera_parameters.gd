extends Resource
class_name CameraParameters



@export var CAMERA_CONTROLLER_ROTATION_SPEED: float = 3.0
@export var CAMERA_MOUSE_SENSIBILITY: float = 0.2
# A minimum angle lower than or equal to -90 breaks movement if the player is looking upward.
@export var CAMERA_X_ROT_MIN: float = deg_to_rad(-89.9)
@export var CAMERA_X_ROT_MAX: float = deg_to_rad(70)

## Unused
@export var SPRING_ARM_SPEED: float = 2
## Changing lenght allows zooming/unzooming
@export var SPRING_ARM_LENGHT: float = 8
@export var CAMERA_FOV: float = 75
@export var CAMERA_PARAMS_TWEEN_SPEED: float = 2


@export var CAMERA_BASE_OFFSET: Vector3 = Vector3(0, 2.75, 0)
@export var CAMERA_TOO_CLOSE_RANGE: float = 4
@export var CAMERA_TOO_CLOSE_OFFSET: Vector3 = Vector3(0, 2.75, 0)
@export var CAMERA_TOO_CLOSE_BEHIND_MULTIPLICATOR: float = 10
@export var CAMERA_TOO_CLOSE_MOVEMENT_TWEEN_SPEED: float = 0.3