class_name SpellRangeIndicator
extends Node2D

var _direction: Vector2i = Vector2i.RIGHT
var _cell_size: float = 64.0

@export var fill_color: Color = Color(0.35, 0.78, 1.0, 0.22):
	set(value):
		fill_color = value
		queue_redraw()

@export var outline_color: Color = Color(0.55, 0.95, 1.0, 0.95):
	set(value):
		outline_color = value
		queue_redraw()

@export var outline_width: float = 2.0:
	set(value):
		outline_width = value
		queue_redraw()


func _draw() -> void:
	var end: Vector2 = Vector2(_direction) * _cell_size * 3.0
	draw_line(Vector2.ZERO, end, fill_color, 3.0)
	for distance: int in range(1, 4):
		var center: Vector2 = Vector2(_direction) * _cell_size * distance
		draw_circle(center, 5.0, outline_color, false, outline_width, true)


func set_direction(direction: Vector2i, cell_size: float) -> void:
	if _direction == direction and _cell_size == cell_size:
		return
	_direction = direction
	_cell_size = cell_size
	queue_redraw()
