extends Area3D
class_name Banana

@onready var anim_player: AnimationPlayer = $AnimationPlayer
@onready var rdm_stream_player: RandomStreamPlayer = $RandomStreamPlayer

func _ready():
	self.body_entered.connect(_on_body_entered)

func _on_body_entered(body: Node3D) -> void:
	if body is Monkey:
		self.monitoring = false
		self.monitorable = false
		anim_player.play("taken")
		rdm_stream_player.play_random()
		await anim_player.animation_finished
		self.queue_free()