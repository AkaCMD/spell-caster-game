class_name SpellRangeIndicator
extends Node2D

@export var radius: float = 160.0:
	set(value):
		radius = value
		queue_redraw()

@export var fill_color: Color = Color(0.35, 0.78, 1.0, 0.22):
	set(value):
		fill_color = value
		queue_redraw()

@export var outline_color: Color = Color(0.55, 0.95, 1.0, 0.95):
	set(value):
		outline_color = value
		queue_redraw()

@export var outline_width: float = 4.0:
	set(value):
		outline_width = value
		queue_redraw()


func _draw() -> void:
	draw_circle(Vector2.ZERO, radius, fill_color)
	draw_arc(Vector2.ZERO, radius, 0.0, TAU, 96, outline_color, outline_width, true)


func set_radius(value: float) -> void:
	radius = value
