class_name GridRoomLayout
extends Resource
## Editable room data. Positions are grid cells, not animation positions.

@export var cell_size: float = 64.0
@export var dimensions: Vector2i = Vector2i(18, 10)
@export var spawn_cell: Vector2i = Vector2i(3, 6)
@export var door_cell: Vector2i = Vector2i(17, 5)
@export var slot_regions: Array[Rect2i] = [Rect2i(5, 4, 3, 3), Rect2i(9, 4, 3, 3)]
@export var gap_regions: Array[Rect2i] = [
	Rect2i(8, 3, 5, 1), Rect2i(8, 7, 5, 1),
	Rect2i(8, 4, 1, 3), Rect2i(12, 4, 1, 3),
]
@export var wall_cells: Array[Vector2i] = []
@export var pillar_cells: Array[Vector2i] = [Vector2i(5, 5), Vector2i(6, 5), Vector2i(9, 5)]
@export var solution_offsets: Array[Vector2i] = [Vector2i.ZERO, Vector2i(3, 0), Vector2i(0, 1)]


func is_inside(cell: Vector2i) -> bool:
	return Rect2i(Vector2i.ZERO, dimensions).has_point(cell)


func is_wall(cell: Vector2i) -> bool:
	if not is_inside(cell):
		return true
	if cell == door_cell:
		return false
	return cell.x == 0 or cell.x == dimensions.x - 1 or cell.y <= 1 or cell.y == dimensions.y - 1 or wall_cells.has(cell)


func is_gap(cell: Vector2i) -> bool:
	return _in_regions(cell, gap_regions)


func is_slot(cell: Vector2i) -> bool:
	return _in_regions(cell, slot_regions)


func _in_regions(cell: Vector2i, regions: Array[Rect2i]) -> bool:
	for region: Rect2i in regions:
		if region.has_point(cell):
			return true
	return false
