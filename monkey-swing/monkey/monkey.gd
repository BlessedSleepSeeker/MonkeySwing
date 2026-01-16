extends CharacterBody3D
class_name Monkey

@export var active_camera: Node3D

@onready var state_machine: StateMachine = $StateMachine
@onready var skin: MonkeySkin = %MonkeySkin
@onready var tps_camera: MouseFollowCamera = %TPSCamera
@onready var fps_camera: FPSCamera = %FPSCamera
@onready var hitbox: CollisionShape3D = %Hitbox
@onready var hud: MonkeyHUD = %MonkeyHUD
#@onready var particles_manager: ParticlesManager = %ParticlesManager

var direction: Vector3 = Vector3.ZERO
var raw_input: Vector2 = Vector2.ZERO
var last_movement_direction: Vector3 = Vector3.BACK

var bullet_time_on: bool = false

var did_double_jump: bool = false:
	set(value):
		did_double_jump = value
		# if value:
		# 	hud_canvas.tween_double_jump_cooldown(0, 1, 0.1)
		# else:
		# 	hud_canvas.tween_double_jump_cooldown(1, 1, 0.1)

signal velocity_tweened

func _ready():
	pass
	## deactivated for gameplay reason -> add in gameplay/accessibility option
	active_camera.is_colliding.connect(hud.tween_crosshair_collision)

func transition_state(state_name: String, msg: Dictionary = {}):
	state_machine.transition_to(state_name, msg)

func has_state(state_name: String) -> bool:
	for state: CharacterState in state_machine.get_children():
		if state.name == state_name:
			return true
	return false

func play_animation(animation_name: String):
	if skin == null:
		return
	skin.travel(animation_name)

func set_hitbox_shape(shape: Shape3D) -> void:
	hitbox.shape = shape

func respawn(respawn_global_position: Vector3) -> void:
	self.global_position = respawn_global_position
	self.velocity = Vector3.ZERO
