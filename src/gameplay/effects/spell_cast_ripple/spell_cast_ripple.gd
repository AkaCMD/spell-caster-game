class_name SpellCastRipple
extends Node2D

@export var effect_size: Vector2 = Vector2(320.0, 320.0):
	set(value):
		effect_size = value
		_update_rect()

@export var duration: float = 0.55

@onready var ripple_rect: ColorRect = %RippleRect

var _material: ShaderMaterial
var _tween: Tween


func _ready() -> void:
	visible = false
	_material = ripple_rect.material as ShaderMaterial
	if _material != null:
		_material = _material.duplicate() as ShaderMaterial
		ripple_rect.material = _material
	_update_rect()


func play(origin: Vector2) -> void:
	global_position = origin
	visible = true
	_set_progress(0.0)

	if _tween != null:
		_tween.kill()

	_tween = create_tween()
	_tween.tween_method(Callable(self, "_set_progress"), 0.0, 1.0, duration)
	_tween.tween_callback(Callable(self, "queue_free"))


func _set_progress(value: float) -> void:
	if _material == null:
		return

	_material.set_shader_parameter(&"progress", value)


func _update_rect() -> void:
	if not is_node_ready():
		return

	ripple_rect.size = effect_size
	ripple_rect.position = -effect_size * 0.5
	if _material != null:
		_material.set_shader_parameter(&"effect_size", effect_size)
