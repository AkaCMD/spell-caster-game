class_name Door
extends Node2D

enum DoorState {
	LOCKED,
	ACTIVATING,
	COMPLETE,
}

@export var required_spell_tokens: PackedStringArray = PackedStringArray(["^", ">", "v"])
@export var open_duration: float = 0.35

@onready var visual: Polygon2D = %Visual
@onready var collision_shape: CollisionShape2D = %CollisionShape2D

var state: DoorState = DoorState.LOCKED


func _ready() -> void:
	add_to_group("spell_doors")
	_apply_state_visuals()


func try_open(cast_origin: Vector2, spell_tokens: PackedStringArray, effect_radius: float) -> bool:
	if state != DoorState.LOCKED:
		return false
	if global_position.distance_to(cast_origin) > effect_radius:
		return false
	if not _matches_required_spell(spell_tokens):
		return false

	_activate()
	return true


func _matches_required_spell(spell_tokens: PackedStringArray) -> bool:
	if spell_tokens.size() != required_spell_tokens.size():
		return false

	for index: int in range(required_spell_tokens.size()):
		if spell_tokens[index] != required_spell_tokens[index]:
			return false

	return true


func _activate() -> void:
	state = DoorState.ACTIVATING
	_apply_state_visuals()

	var tween: Tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(visual, "scale", Vector2(0.12, 1.0), open_duration)
	tween.tween_property(visual, "modulate:a", 0.35, open_duration)
	await tween.finished

	state = DoorState.COMPLETE
	_apply_state_visuals()


func _apply_state_visuals() -> void:
	match state:
		DoorState.LOCKED:
			visible = true
			collision_shape.disabled = false
			visual.scale = Vector2.ONE
			visual.modulate = Color(0.36, 0.16, 0.08, 1.0)
		DoorState.ACTIVATING:
			visible = true
			collision_shape.disabled = true
			visual.modulate = Color(0.95, 0.63, 0.22, 1.0)
		DoorState.COMPLETE:
			visible = false
			collision_shape.disabled = true
