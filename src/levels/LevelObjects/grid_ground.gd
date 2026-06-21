class_name GridGround
extends Node2D

@export var ground_size: Vector2 = Vector2(1536.0, 896.0):
	set(value):
		ground_size = value
		queue_redraw()

@export var cell_size: float = 64.0:
	set(value):
		cell_size = maxf(value, 1.0)
		queue_redraw()

@export var fill_color: Color = Color(0.20392157, 0.22745098, 0.18039216, 1.0):
	set(value):
		fill_color = value
		queue_redraw()

@export var grid_color: Color = Color(0.3019608, 0.34509805, 0.2509804, 1.0):
	set(value):
		grid_color = value
		queue_redraw()

@export var grid_width: float = 1.0:
	set(value):
		grid_width = maxf(value, 0.0)
		queue_redraw()


func _draw() -> void:
	var half_size: Vector2 = ground_size * 0.5
	var top_left: Vector2 = -half_size
	draw_rect(Rect2(top_left, ground_size), fill_color)

	if grid_width <= 0.0:
		return

	var vertical_line_count: int = int(floor(ground_size.x / cell_size))
	for index: int in range(vertical_line_count + 1):
		var x: float = top_left.x + float(index) * cell_size
		draw_line(Vector2(x, top_left.y), Vector2(x, half_size.y), grid_color, grid_width)

	var horizontal_line_count: int = int(floor(ground_size.y / cell_size))
	for index: int in range(horizontal_line_count + 1):
		var y: float = top_left.y + float(index) * cell_size
		draw_line(Vector2(top_left.x, y), Vector2(half_size.x, y), grid_color, grid_width)
