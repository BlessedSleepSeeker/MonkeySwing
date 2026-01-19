extends CharacterState
class_name ArmAttached

@export var right_hand_mesh: PackedScene = preload("res://monkey/skin/hands/RightHandMesh.tscn")
@export var left_hand_mesh: PackedScene = preload("res://monkey/skin/hands/LeftHandMesh.tscn")

@onready var random_stream_player: RandomStreamPlayer = $RandomStreamPlayer

var right_arm_attached: bool = false:
	set(value):
		right_arm_attached = value
		right_hand_model.visible = value
		right_hand_model.global_position = right_arm_node.global_position
		if right_arm_attached:
			arm_used.emit(true)
			random_stream_player.play_random()

var left_arm_attached: bool = false:
	set(value):
		left_arm_attached = value
		left_hand_model.visible = value
		left_hand_model.global_position = left_arm_node.global_position
		if left_arm_attached:
			arm_used.emit(false)
			random_stream_player.play_random()

var try_use_right_arm: bool = false:
	set(value):
		try_use_right_arm = value
		if try_use_right_arm:
			trying_to_attach_arm.emit(true)
		elif not right_arm_attached:
			not_using_arm.emit(true)

var try_use_left_arm: bool = false:
	set(value):
		try_use_left_arm = value
		if try_use_left_arm:
			trying_to_attach_arm.emit(false)
		elif not left_arm_attached:
			not_using_arm.emit(false)

var right_arm_node: Node3D = Node3D.new()
var left_arm_node: Node3D = Node3D.new()

var swing_center: Vector3 = Vector3.ZERO
var distance: float

var arm_raycast: RayCast3D = null

var right_hand_model: Node3D
var left_hand_model: Node3D

var can_reset_dj: bool = false

enum LastArmUsed {
	NONE,
	LEFT,
	RIGHT
}
var last_arm_used: LastArmUsed = LastArmUsed.NONE

signal not_using_arm(side: bool)
signal trying_to_attach_arm(side: bool)
signal arm_used(side: bool)

func _ready():
	super()
	self.add_child(right_arm_node)
	self.add_child(left_arm_node)
	
	right_hand_model = right_hand_mesh.instantiate()
	self.add_child(right_hand_model)
	right_hand_model.hide()

	left_hand_model = left_hand_mesh.instantiate()
	self.add_child(left_hand_model)
	left_hand_model.hide()


func enter(_msg := {}) -> void:
	super(_msg)
	arm_raycast = character.active_camera.raycast
	arm_raycast.target_position.z = -self.physics_parameters.GRAPPLE_MAX_RANGE
	#print("Entering %s" % name)
	if _msg["arm"] == "left":
		try_use_left_arm = true
	if _msg["arm"] == "right":
		try_use_right_arm = true


# true = right
# false = left
func raycast_arm(side: bool) -> bool:
	#print("raycasting %s arm" % ["right" if side else "left"])
	if arm_raycast.is_colliding():
		var collider: Node3D = arm_raycast.get_collider()
		attach_arm(side, collider)
		return true
	return false

func attach_arm(side: bool, collider: Object) -> void:
	var arm_pos_node: Node3D = right_arm_node if side else left_arm_node
	arm_pos_node.reparent(collider)
	arm_pos_node.global_position = arm_raycast.get_collision_point()
	if side:
		try_use_right_arm = false
		right_arm_attached = true
	else:
		try_use_left_arm = false
		left_arm_attached = true
	distance = physics_parameters.GRAPPLE_MAX_RANGE #character.global_position.distance_to(calculate_swing_center())
	#print("attached %s arm" % ["right" if side else "left"])

func detach_arm(side: bool) -> void:
	if side:
		right_arm_attached = false
		try_use_right_arm = false
		if not left_arm_attached:
			last_arm_used = LastArmUsed.RIGHT
	else:
		left_arm_attached = false
		try_use_left_arm = false
		if not right_arm_attached:
			last_arm_used = LastArmUsed.LEFT
	not_using_arm.emit(side)
	if not is_attached_to_something():
		state_machine.transition_to("Fall")

func is_attached_to_something() -> bool:
	return right_arm_attached || left_arm_attached

func calculate_swing_center() -> Vector3:
	if right_arm_attached && left_arm_attached:
		return (right_arm_node.global_position + left_arm_node.global_position) / 2
	elif right_arm_attached:
		return right_arm_node.global_position
	elif left_arm_attached:
		return left_arm_node.global_position
	return Vector3.ZERO


func swing(_delta: float) -> void:
	if not is_attached_to_something():
		return
	## No need to adjust movement if we are not outside of range !
	var current_distance = character.global_position.distance_to(calculate_swing_center())
	if current_distance < distance:
		return

	## Find the future position with current velocity
	var future_pos = character.global_position + (character.velocity * _delta)
	## Find the position where your character should be when being attached to the hookshot.
	var new_point = swing_center + (swing_center.direction_to(future_pos) * distance)
	## Update velocity to go in the direction of the new_point.

	
	character.velocity = (new_point - character.global_position) / _delta

	## if you alternate between right and left arm, you get a velocity boost
	var swing_multiplier = 1.0
	if (last_arm_used == LastArmUsed.LEFT && right_arm_attached && not left_arm_attached) || (last_arm_used == LastArmUsed.RIGHT && left_arm_attached && not right_arm_attached):
		swing_multiplier = 1.2
	character.velocity *= swing_multiplier

func physics_update(_delta: float, _move_character: bool = true):
	super(_delta, false)

	try_for_arm_if_needed()

	swing_center = calculate_swing_center()
	swing(_delta)

	## reset double jump only if you've gone downward once
	if character.velocity.y < 0:
		can_reset_dj = true
	if can_reset_dj && character.velocity.y > 0:
		character.did_double_jump = false
	character.move_and_slide()

	if character.is_on_wall():
		state_machine.transition_to("Slide")
	if character.is_on_floor():
		state_machine.transition_to("Land")

func try_for_arm_if_needed() -> void:
	#print("%s : %s" % [try_use_left_arm, try_use_right_arm])
	if try_use_left_arm:
		if not left_arm_attached:
			raycast_arm(false)
		else:
			detach_arm(false)
	if try_use_right_arm:
		if not right_arm_attached:
			raycast_arm(true)
		else:
			detach_arm(true)

func unhandled_input(_event: InputEvent) -> void:
	super(_event)
	if Input.is_action_just_pressed("jump"):
		state_machine.transition_to("Fall")

	if Input.is_action_just_pressed("use_left_arm"):
		try_use_left_arm = true
	if Input.is_action_just_released("use_left_arm"):
		try_use_left_arm = false
	if Input.is_action_just_pressed("use_right_arm"):
		try_use_right_arm = true
	if Input.is_action_just_released("use_right_arm"):
		try_use_right_arm = false


func exit() -> void:
	right_arm_attached = false
	left_arm_attached = false
	try_use_left_arm = false
	try_use_right_arm = false
	not_using_arm.emit(true)
	not_using_arm.emit(false)
