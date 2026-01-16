extends CanvasLayer
class_name MonkeyHUD


@export_group("Crosshair")
@export var crosshair_base_texture: Texture2D = preload("res://monkey/hud/assets/crosshairs/crosshair001.png")
@export var crosshair_base_color: Color = Color("ffffff")
@export var crosshair_color_on_colliding: Color = Color("70ff7c")

@export_group("Settings")
@export var base_indicator_size: int = 48

@onready var crosshair_container: Container = %CrosshairContainer
@onready var crosshair: TextureRect = %CrosshairCenter
@onready var crosshair_collision: TextureRect = %CrosshairCollision
@onready var crosshair_arm_left: TextureRect = %CrosshairArmLeft
@onready var crosshair_arm_right: TextureRect = %CrosshairArmRight

@onready var double_jump_indicator: TextureRect = %DoubleJumpIndicator
@onready var bullet_time_indicator: TextureRect = %BulletTimeIndicator

@onready var bullet_time_screen_fx: ColorRect = %BulletTimeVFX


#region Settings
func _ready():
	#settings.settings_changed.connect(apply_settings)
	apply_settings()

func apply_settings() -> void:
	set_crosshair_size()
	set_indicators_size()

func set_crosshair_size() -> void:
	pass
	# var multiplier: float = settings.read_setting_value_by_key("CROSSHAIR_SIZE")
	# crosshair.custom_minimum_size = multiplier * crosshair_base_texture.get_size()
	# collision_crosshair.custom_minimum_size = multiplier * crosshair_base_texture.get_size()

func set_indicators_size() -> void:
	pass
	# var multiplier: float = settings.read_setting_value_by_key("INDICATORS_SIZE")
	# double_jump_indicator.custom_minimum_size = Vector2(base_indicator_size, base_indicator_size) * multiplier
	# bullet_time_indicator.custom_minimum_size = Vector2(base_indicator_size, base_indicator_size) * multiplier

#endregion

#region Tweening
func set_double_jump_base_color(new_color: Color) -> void:
	double_jump_indicator.modulate = new_color

func set_double_jump_cooldown_color(new_color: Color) -> void:
	double_jump_indicator.material.set_shader_parameter("cooldown_color", new_color)

func set_double_jump_current_cooldown(remaining_time: float, max_time: float) -> void:
	var percent: float = remaining_time / max_time
	double_jump_indicator.material.set_shader_parameter("percent", percent)

func tween_double_jump_cooldown(wanted_time: float, max_time: float, tween_speed: float) -> void:
	var percent: float = wanted_time / max_time
	var tween: Tween = create_tween()
	tween.tween_property(double_jump_indicator.material, "shader_parameter/percent", percent, tween_speed)

func tween_reel_value(value: float, max_value: float, tween_speed: float) -> void:
	var percent: float = value / max_value
	var tween: Tween = create_tween()
	tween.tween_property(crosshair.material, "shader_parameter/percent", percent, tween_speed)

func tween_crosshair_collision(is_colliding: bool) -> void:
	var tween_collision: Tween = create_tween()
	if is_colliding:
		tween_collision.tween_property(crosshair_collision, "modulate:a", 1, 0.1).set_ease(Tween.EASE_OUT)
	else:
		tween_collision.tween_property(crosshair_collision, "modulate:a", 0, 0.1).set_ease(Tween.EASE_OUT)

func fade_crosshair(direction: bool) -> void:
	var tween: Tween = create_tween()
	if direction:
		tween.tween_property(crosshair, "modulate:a", 1, 0.1).set_ease(Tween.EASE_OUT)
	else:
		tween.tween_property(crosshair, "modulate:a", 0, 0.1).set_ease(Tween.EASE_OUT)

func change_crosshair_to(crosshair_texture: Texture2D) -> void:
	if crosshair_texture:
		crosshair.texture = crosshair_texture
	else:
		if crosshair.texture != crosshair_base_texture:
			crosshair.texture = crosshair_base_texture

func tween_bullet_time(wanted_time: float, max_time: float, tween_speed: float):
	pass
	# var percent: float = wanted_time / max_time
	# var tween: Tween = create_tween()
	# tween.tween_property(bullet_time_screen_fx.material, "shader_parameter/levels", clampi(int(percent) * 10, 3, 10), tween_speed)
	# var tween3: Tween = create_tween()
	# tween3.tween_property(bullet_time_screen_fx, "modulate:a", inverse_number_around_another(percent, 0.5), tween_speed)


static func inverse_number_around_another(number: float, axis: float) -> float:
	return axis - (number - axis)

#endregion