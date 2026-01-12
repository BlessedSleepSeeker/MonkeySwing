extends Node3D
class_name MonkeySkin


@export var play_animation_on_load: String = ""
@export var fishing_rod_models: Array[BoneAttachment3D] = []

@onready var animation_tree: AnimationTree = %AnimationTree
@onready var state_machine : AnimationNodeStateMachinePlayback = animation_tree.get("parameters/StateMachine/playback")


func _ready():
	if play_animation_on_load:
		travel(play_animation_on_load)

func travel(state_name: String) -> void:
	state_machine.travel(state_name)

func reset_swing_orientation() -> void:
	var tween: Tween = get_tree().create_tween()
	tween.tween_property(self, "rotation:x", 0, 1)
