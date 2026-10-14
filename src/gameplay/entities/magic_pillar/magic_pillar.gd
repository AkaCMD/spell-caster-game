class_name MagicPillar
extends Node2D

@export var stone_color: Color = Color(0.60, 0.65, 0.65)
@export var edge_color: Color = Color(0.25, 0.31, 0.33)
@export var rune_color: Color = Color(0.79, 0.85, 0.80)
@export var target_color: Color = Color(0.55, 0.95, 1.0)
@export var size: float = 46.0

var cell: Vector2i = Vector2i.ZERO
var is_moving: bool = false
var playback_speed: float = 1.0
var _selected: bool = false
var _start: Vector2 = Vector2.ZERO
var _destination: Vector2 = Vector2.ZERO
var _elapsed: float = 0.0
var _duration: float = 0.18
var _shake_remaining: float = 0.0


func _process(delta: float) -> void:
	if is_moving:
		_elapsed = minf(_elapsed + delta * playback_speed, _duration)
		var progress: float = _elapsed / _duration
		position = _start.lerp(_destination, smoothstep(0.0, 1.0, progress))
		if _elapsed >= _duration:
			is_moving = false
	if _shake_remaining > 0.0:
		_shake_remaining = maxf(0.0, _shake_remaining - delta)
		queue_redraw()


func move_to(destination_cell: Vector2i, destination: Vector2, duration: float) -> void:
	cell = destination_cell
	_start = position
	_destination = destination
	_elapsed = 0.0
	_duration = maxf(duration, 0.01)
	playback_speed = 1.0
	is_moving = true


func finish_move() -> void:
	if is_moving:
		position = _destination
		is_moving = false


func reset_to(initial_cell: Vector2i, initial_position: Vector2) -> void:
	cell = initial_cell
	position = initial_position
	is_moving = false
	_shake_remaining = 0.0
	set_selected(false)
	queue_redraw()


func set_selected(selected: bool) -> void:
	if _selected == selected:
		return
	_selected = selected
	queue_redraw()


func show_blocked() -> void:
	_shake_remaining = 0.24
	queue_redraw()


func _draw() -> void:
	var offset: Vector2 = Vector2(sin(_shake_remaining * 90.0) * 4.0, 0.0) if _shake_remaining > 0.0 else Vector2.ZERO
	var half: float = size * 0.5
	draw_rect(Rect2(offset + Vector2(-half, -half + 7.0), Vector2(size, size)), Color(0.05, 0.08, 0.09, 0.6))
	draw_rect(Rect2(offset - Vector2(half, half), Vector2(size, size)), edge_color)
	draw_rect(Rect2(offset - Vector2(half - 5.0, half - 5.0), Vector2(size - 10.0, size - 10.0)), stone_color)
	draw_polyline(PackedVector2Array([offset + Vector2(0, -10), offset + Vector2(8, 0), offset + Vector2(0, 10), offset + Vector2(-8, 0), offset + Vector2(0, -10)]), rune_color, 2.0, true)
	if _selected:
		draw_rect(Rect2(Vector2(-half - 5.0, -half - 5.0), Vector2(size + 10.0, size + 10.0)), target_color, false, 3.0)
