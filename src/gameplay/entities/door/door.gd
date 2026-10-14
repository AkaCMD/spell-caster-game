class_name Door
extends Node2D

enum DoorState { LOCKED, ACTIVATING, COMPLETE }

@export var open_duration: float = 0.35
@export var closed_color: Color = Color(0.46, 0.52, 0.53)
@export var active_color: Color = Color(0.75, 0.84, 0.70)
@export var target_color: Color = Color(0.55, 0.95, 1.0)

@onready var visual: Polygon2D = %Visual
@onready var collision_shape: CollisionShape2D = %CollisionShape2D

var state: DoorState = DoorState.LOCKED
var _elapsed: float = 0.0
var _selected: bool = false
var _shake_remaining: float = 0.0


func _ready() -> void:
	reset_door()


func open() -> void:
	if state != DoorState.LOCKED:
		return
	state = DoorState.ACTIVATING
	_elapsed = 0.0
	collision_shape.set_deferred("disabled", true)
	visual.modulate = active_color
	set_selected(false)


func reset_door() -> void:
	state = DoorState.LOCKED
	_elapsed = 0.0
	_shake_remaining = 0.0
	visible = true
	visual.position = Vector2.ZERO
	visual.scale = Vector2.ONE
	visual.modulate = closed_color
	collision_shape.set_deferred("disabled", false)
	set_selected(false)


func set_selected(selected: bool) -> void:
	_selected = selected
	queue_redraw()


func show_blocked() -> void:
	_shake_remaining = 0.24


func _process(delta: float) -> void:
	if state == DoorState.ACTIVATING:
		_elapsed += delta
		var progress: float = clampf(_elapsed / maxf(open_duration, 0.01), 0.0, 1.0)
		visual.scale.x = lerpf(1.0, 0.05, progress)
		visual.modulate.a = 1.0 - progress
		if progress >= 1.0:
			state = DoorState.COMPLETE
			visible = false
	if _shake_remaining > 0.0:
		_shake_remaining = maxf(0.0, _shake_remaining - delta)
		visual.position.x = sin(_shake_remaining * 90.0) * 7.0 if _shake_remaining > 0.0 else 0.0


func _draw() -> void:
	if _selected:
		draw_rect(Rect2(Vector2(-70, -70), Vector2(140, 140)), target_color, false, 5.0)
