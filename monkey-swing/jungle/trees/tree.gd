extends Node3D
class_name JungleTree

@export var randomize_things: bool = true
@export_group("Random Toggles")
@export var randomize_rotation: bool = true
@export var randomize_height: bool = true
@export var randomize_top: bool = true

@onready var rng: RandomNumberGenerator = RandomNumberGenerator.new()

@onready var top_cylinder: CSGCylinder3D = %TopCylinder

func _ready():
	if randomize_things:
		randomize_model()

func randomize_model() -> void:
	if randomize_rotation:
		self.rotation_degrees.y = rng.randi_range(0, 360)
	if randomize_top:
		top_cylinder.radius = rng.randf_range(2, 8)
	if randomize_height:
		self.position.y -= rng.randf_range(0, 2)