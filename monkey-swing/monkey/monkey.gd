extends CharacterBody3D
class_name Monkey

@export var active_camera: Node3D
@export var max_stamina: float = 3

@onready var state_machine: StateMachine = $StateMachine
@onready var skin: MonkeySkin = %MonkeySkin
@onready var tps_camera: MouseFollowCamera = %TPSCamera
@onready var fps_camera: FPSCamera = %FPSCamera
@onready var hitbox: CollisionShape3D = %Hitbox
@onready var hud: MonkeyHUD = %MonkeyHUD
#@onready var particles_manager: ParticlesManager = %ParticlesManager

@onready var stamina_recharge_timer: Timer = %StaminaRechargeTimer

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

var current_stamina: float = max_stamina:
	set(value):
		if value < current_stamina:
			stamina_recharge_timer.start()
		current_stamina = clampf(value, 0, max_stamina)
		stamina_updated.emit(current_stamina, max_stamina)

signal stamina_updated(stamina_value: float)

func _ready():
	## deactivated for gameplay reason -> add in gameplay/accessibility option
	active_camera.is_colliding.connect(hud.tween_crosshair_collision)
	var arm_swing_state: CharacterState = state_machine.get_state_by_name("ArmAttached")
	arm_swing_state.not_using_arm.connect(hud.tween_hand.bind("Hide"))
	arm_swing_state.trying_to_attach_arm.connect(hud.tween_hand.bind("Try"))
	arm_swing_state.arm_used.connect(hud.tween_hand.bind("Used"))
	var slide_state: CharacterState = state_machine.get_state_by_name("Slide")
	slide_state.not_using_arm.connect(hud.tween_hand.bind("Hide"))
	slide_state.trying_to_use_arm.connect(hud.tween_hand.bind("Try"))
	var climb_state: CharacterState = state_machine.get_state_by_name("Climb")
	climb_state.not_using_arm.connect(hud.tween_hand.bind("Hide"))

	self.stamina_updated.connect(hud.set_stamina_value)
	

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

func _physics_process(_delta):
	if state_machine.state.name != "Climb" && stamina_recharge_timer.is_stopped():
		self.current_stamina += _delta
