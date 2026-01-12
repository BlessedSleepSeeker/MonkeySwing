extends Node
class_name State

var state_machine: StateMachine = null

func input(_event: InputEvent) -> void:
	pass

func unhandled_input(_event: InputEvent) -> void:
	pass

func update(_delta: float) -> void:
	pass

func physics_update(_delta: float, _move_character: bool = true) -> void:
	pass

func enter(_msg := {}) -> void:
	pass

func exit() -> void:
	pass

func play_animation(_anim_name: String = "") -> void:
	pass