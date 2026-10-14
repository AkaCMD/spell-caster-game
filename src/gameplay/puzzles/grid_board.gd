class_name GridBoard
extends Node2D

signal puzzle_solved

const PILLAR_SCENE: PackedScene = preload("res://src/gameplay/entities/magic_pillar/magic_pillar.tscn")
const DOOR_SCENE: PackedScene = preload("res://src/gameplay/entities/door/door.tscn")

@export var layout: GridRoomLayout
@export var floor_color: Color = Color(0.16, 0.22, 0.24)
@export var wall_color: Color = Color(0.23, 0.29, 0.31)
@export var slot_color: Color = Color(0.44, 0.55, 0.52)
@export var gap_color: Color = Color(0.025, 0.04, 0.06)
@export var clue_color: Color = Color(0.82, 0.77, 0.57)

var pillars: Array[MagicPillar] = []
var door: Door
var player_cell: Vector2i = Vector2i.ZERO
var solved: bool = false
var _target: Node2D = null
var _status: String = ""


func _ready() -> void:
	if layout == null:
		layout = GridRoomLayout.new()
	for initial_cell: Vector2i in layout.pillar_cells:
		var pillar: MagicPillar = PILLAR_SCENE.instantiate() as MagicPillar
		add_child(pillar)
		pillar.reset_to(initial_cell, cell_to_local(initial_cell))
		pillars.append(pillar)
	door = DOOR_SCENE.instantiate() as Door
	add_child(door)
	door.position = cell_to_local(layout.door_cell)
	door.scale = Vector2(layout.cell_size / 128.0, layout.cell_size / 128.0)
	reset_room()


func cell_to_local(cell: Vector2i) -> Vector2:
	return (Vector2(cell) + Vector2(0.5, 0.5) - Vector2(layout.dimensions) * 0.5) * layout.cell_size


func cell_to_world(cell: Vector2i) -> Vector2:
	return to_global(cell_to_local(cell))


func world_to_cell(world_position: Vector2) -> Vector2i:
	return Vector2i((to_local(world_position) / layout.cell_size + Vector2(layout.dimensions) * 0.5).floor())


func pillar_at(cell: Vector2i) -> MagicPillar:
	for pillar: MagicPillar in pillars:
		if pillar.cell == cell:
			return pillar
	return null


func is_walkable(cell: Vector2i) -> bool:
	return not layout.is_wall(cell) and not layout.is_gap(cell) and (cell != layout.door_cell or solved)


func try_player_step(direction: Vector2i, duration: float) -> bool:
	var destination: Vector2i = player_cell + direction
	if not is_walkable(destination):
		return false
	var pillar: MagicPillar = pillar_at(destination)
	if pillar != null and not try_push(pillar, direction, duration):
		return false
	player_cell = destination
	return true


func try_push(pillar: MagicPillar, direction: Vector2i, duration: float) -> bool:
	var destination: Vector2i = pillar.cell + direction
	if pillar.is_moving or not layout.is_slot(destination) or layout.is_wall(destination) or destination == layout.door_cell or pillar_at(destination) != null or destination == player_cell:
		pillar.show_blocked()
		return false
	pillar.move_to(destination, cell_to_local(destination), duration)
	return true


func find_target(origin_cell: Vector2i, direction: Vector2i, range_cells: int) -> Node2D:
	for distance: int in range(1, range_cells + 1):
		var cell: Vector2i = origin_cell + direction * distance
		if layout.is_wall(cell):
			return null
		if cell == layout.door_cell and not solved:
			return door
		var pillar: MagicPillar = pillar_at(cell)
		if pillar != null:
			return pillar
	return null


func highlight_target(target: Node2D) -> void:
	_target = target
	for pillar: MagicPillar in pillars:
		pillar.set_selected(pillar == target)
	if is_instance_valid(door):
		door.set_selected(door == target)


func check_solution() -> bool:
	if solved:
		return true
	var cells: Array[Vector2i] = []
	for pillar: MagicPillar in pillars:
		if pillar.is_moving:
			return false
		cells.append(pillar.cell)
	if matches_solution(cells):
		solved = true
		door.open()
		set_status("The stone door is open.")
		puzzle_solved.emit()
	return solved


func matches_solution(cells: Array[Vector2i]) -> bool:
	if cells.size() != layout.solution_offsets.size() or cells.is_empty():
		return false
	for anchor: Vector2i in cells:
		var matches: bool = true
		for offset: Vector2i in layout.solution_offsets:
			if not cells.has(anchor + offset):
				matches = false
				break
		if matches:
			return true
	return false


func reset_room() -> void:
	solved = false
	player_cell = layout.spawn_cell
	for index: int in range(pillars.size()):
		pillars[index].reset_to(layout.pillar_cells[index], cell_to_local(layout.pillar_cells[index]))
	door.reset_door()
	highlight_target(null)
	set_status("")


func set_status(status: String) -> void:
	_status = status
	queue_redraw()


func _process(_delta: float) -> void:
	check_solution()


func _draw() -> void:
	if layout == null:
		return
	var tile_size: Vector2 = Vector2.ONE * layout.cell_size
	for y: int in range(layout.dimensions.y):
		for x: int in range(layout.dimensions.x):
			var cell: Vector2i = Vector2i(x, y)
			var center: Vector2 = cell_to_local(cell)
			var rect: Rect2 = Rect2(center - tile_size * 0.5, tile_size)
			var color: Color = floor_color
			if layout.is_wall(cell) or (cell == layout.door_cell and not solved):
				color = wall_color
			elif layout.is_gap(cell):
				color = gap_color
			draw_rect(rect, color)
			draw_rect(rect, Color(0.32, 0.40, 0.41, 0.18), false, 1.0)
			if layout.is_slot(cell):
				draw_rect(rect.grow(-8.0), slot_color, false, 2.0)
				draw_circle(center, 3.0, slot_color)
	_draw_murals()
	var font: Font = ThemeDB.fallback_font
	draw_string(font, Vector2(-555, 336), "WASD  move / push     Arrows  inscribe     Enter  cast     Backspace  erase     Esc  clear / stop     R  reset", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, clue_color)
	draw_string(font, Vector2(-555, 356), _status, HORIZONTAL_ALIGNMENT_LEFT, -1, 18, clue_color)
	if solved:
		draw_string(font, cell_to_local(layout.door_cell) + Vector2(-74, -46), "OPEN", HORIZONTAL_ALIGNMENT_LEFT, -1, 16, clue_color)


func _draw_murals() -> void:
	var spell_center: Vector2 = Vector2(-235, -263)
	var pattern_center: Vector2 = Vector2(200, -263)
	for center: Vector2 in [spell_center, pattern_center]:
		draw_rect(Rect2(center - Vector2(140, 43), Vector2(280, 86)), Color(0.12, 0.17, 0.19))
		draw_rect(Rect2(center - Vector2(140, 43), Vector2(280, 86)), clue_color, false, 2.0)
	# A start dot followed by UP, RIGHT. The end has an arrowhead.
	var start: Vector2 = spell_center + Vector2(-55, 26)
	var bend: Vector2 = start + Vector2(0, -48)
	var end: Vector2 = bend + Vector2(72, 0)
	draw_circle(start, 6.0, clue_color)
	draw_polyline(PackedVector2Array([start, bend, end]), clue_color, 4.0, true)
	draw_polyline(PackedVector2Array([end + Vector2(-9, -8), end, end + Vector2(-9, 8)]), clue_color, 3.0, true)
	# The same rune links this stroke to the stone subject of the second mural.
	draw_rect(Rect2(spell_center + Vector2(64, -8), Vector2(26, 26)), clue_color, false, 3.0)
	draw_line(spell_center + Vector2(94, 5), spell_center + Vector2(119, 5), clue_color, 2.0)
	draw_line(spell_center + Vector2(119, 5), spell_center + Vector2(111, -1), clue_color, 2.0)
	for y: int in range(2):
		for x: int in range(4):
			var point: Vector2 = pattern_center + Vector2(x * 28 - 42, y * 28 - 14)
			draw_rect(Rect2(point - Vector2(12, 12), Vector2(24, 24)), slot_color, false, 1.0)
	for offset: Vector2i in layout.solution_offsets:
		var point: Vector2 = pattern_center + Vector2(offset) * 28.0 - Vector2(42, 14)
		draw_rect(Rect2(point - Vector2(8, 8), Vector2(16, 16)), clue_color)
