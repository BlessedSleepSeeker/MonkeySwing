extends CharacterState
class_name HookThrowState

var hookshot_raycast: RayCast3D = null

@export var hookshot_delay: float = 0.0
@export var spawn_debug: bool = false
@export var debug_ball: PackedScene = preload("res://debug/DebugBall.tscn")

func enter(_msg := {}) -> void:
	super()
	hookshot_raycast = character.camera.raycast
	look_for_hookshot_hit()

func look_for_hookshot_hit() -> void:
	if hookshot_delay > 0:
		await get_tree().create_timer(hookshot_delay).timeout
	if hookshot_raycast.is_colliding():
		if spawn_debug:
			var inst: StaticBody3D = debug_ball.instantiate()
			add_child(inst)
			inst.global_position = hookshot_raycast.get_collision_point()
		state_machine.transition_to("HookActivated")
	else:
		state_machine.transition_to("Fall")

func exit() -> void:
	pass
