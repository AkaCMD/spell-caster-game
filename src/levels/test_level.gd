class_name TestLevel
extends BaseLevel

const DOOR_SCENE: PackedScene = preload("res://src/gameplay/entities/door/door.tscn")

const ROOM_SIZE: Vector2 = Vector2(1280.0, 720.0)
const ROOM_COLUMNS: int = 2
const ROOM_ROWS: int = 2
const WALL_THICKNESS: float = 64.0
const DOOR_WIDTH: float = 160.0
const WALL_COLOR: Color = Color(0.18, 0.18, 0.22, 1.0)
const ROOM_COLORS: Array[Color] = [
	Color(0.34, 0.38, 0.31, 1.0),
	Color(0.31, 0.36, 0.42, 1.0),
	Color(0.39, 0.32, 0.38, 1.0),
	Color(0.37, 0.34, 0.27, 1.0),
]

@onready var player_spawn_marker : PlayerSpawn = %PlayerSpawn
@onready var player_camera : Camera2D = %PlayerCamera
@onready var map_root: Node2D = %MapRoot
@onready var generated_entities: Node2D = %GeneratedEntities

var _room_rects: Array[Rect2] = []

func get_default_player_spawn() -> Vector2:
	return player_spawn_marker.global_position

func get_player_camera() -> Camera2D:
	return player_camera


func get_room_index_at_position(world_position: Vector2) -> int:
	for index: int in range(_room_rects.size()):
		if _room_rects[index].has_point(to_local(world_position)):
			return index

	return 0


func get_room_camera_position(room_index: int) -> Vector2:
	if room_index < 0 or room_index >= _room_rects.size():
		return global_position

	return to_global(_room_rects[room_index].get_center())


func get_overview_camera_position() -> Vector2:
	return to_global(Vector2(ROOM_SIZE.x * ROOM_COLUMNS, ROOM_SIZE.y * ROOM_ROWS) * 0.5 - ROOM_SIZE * 0.5)


func get_overview_camera_zoom() -> Vector2:
	return Vector2(0.45, 0.45)


func _ready() -> void:
	_build_room_rects()
	_build_rooms()
	_build_walls_and_doors()
	player_spawn_marker.global_position = get_room_camera_position(0)
	player_camera.global_position = get_room_camera_position(0)


func _build_room_rects() -> void:
	_room_rects.clear()
	for row: int in range(ROOM_ROWS):
		for column: int in range(ROOM_COLUMNS):
			var top_left: Vector2 = Vector2(column, row) * ROOM_SIZE - ROOM_SIZE * 0.5
			_room_rects.append(Rect2(top_left, ROOM_SIZE))


func _build_rooms() -> void:
	for index: int in range(_room_rects.size()):
		var room_rect: Rect2 = _room_rects[index]
		_add_rect_visual(
			map_root,
			room_rect.get_center(),
			room_rect.size - Vector2(WALL_THICKNESS, WALL_THICKNESS),
			ROOM_COLORS[index % ROOM_COLORS.size()],
			-20
		)


func _build_walls_and_doors() -> void:
	_add_room_outer_walls()
	_add_vertical_connection(0, 1)
	_add_vertical_connection(2, 3)
	_add_horizontal_connection(0, 2)
	_add_horizontal_connection(1, 3)


func _add_room_outer_walls() -> void:
	var map_top_left: Vector2 = -ROOM_SIZE * 0.5
	var map_size: Vector2 = Vector2(ROOM_COLUMNS, ROOM_ROWS) * ROOM_SIZE
	var map_center: Vector2 = map_top_left + map_size * 0.5

	_add_wall(Vector2(map_center.x, map_top_left.y), Vector2(map_size.x + WALL_THICKNESS, WALL_THICKNESS))
	_add_wall(Vector2(map_center.x, map_top_left.y + map_size.y), Vector2(map_size.x + WALL_THICKNESS, WALL_THICKNESS))
	_add_wall(Vector2(map_top_left.x, map_center.y), Vector2(WALL_THICKNESS, map_size.y + WALL_THICKNESS))
	_add_wall(Vector2(map_top_left.x + map_size.x, map_center.y), Vector2(WALL_THICKNESS, map_size.y + WALL_THICKNESS))


func _add_vertical_connection(left_room_index: int, right_room_index: int) -> void:
	var left_room: Rect2 = _room_rects[left_room_index]
	var right_room: Rect2 = _room_rects[right_room_index]
	var x: float = left_room.position.x + left_room.size.x
	var y: float = left_room.get_center().y
	var segment_height: float = (ROOM_SIZE.y - DOOR_WIDTH) * 0.5

	_add_wall(Vector2(x, y - DOOR_WIDTH * 0.5 - segment_height * 0.5), Vector2(WALL_THICKNESS, segment_height))
	_add_wall(Vector2(x, y + DOOR_WIDTH * 0.5 + segment_height * 0.5), Vector2(WALL_THICKNESS, segment_height))
	_add_door(Vector2(x, (left_room.get_center().y + right_room.get_center().y) * 0.5), false)


func _add_horizontal_connection(top_room_index: int, bottom_room_index: int) -> void:
	var top_room: Rect2 = _room_rects[top_room_index]
	var bottom_room: Rect2 = _room_rects[bottom_room_index]
	var x: float = top_room.get_center().x
	var y: float = top_room.position.y + top_room.size.y
	var segment_width: float = (ROOM_SIZE.x - DOOR_WIDTH) * 0.5

	_add_wall(Vector2(x - DOOR_WIDTH * 0.5 - segment_width * 0.5, y), Vector2(segment_width, WALL_THICKNESS))
	_add_wall(Vector2(x + DOOR_WIDTH * 0.5 + segment_width * 0.5, y), Vector2(segment_width, WALL_THICKNESS))
	_add_door(Vector2((top_room.get_center().x + bottom_room.get_center().x) * 0.5, y), true)


func _add_wall(center: Vector2, size: Vector2) -> void:
	var body: StaticBody2D = StaticBody2D.new()
	body.position = center
	map_root.add_child(body)

	var shape: CollisionShape2D = CollisionShape2D.new()
	var rectangle_shape: RectangleShape2D = RectangleShape2D.new()
	rectangle_shape.size = size
	shape.shape = rectangle_shape
	body.add_child(shape)

	_add_rect_visual(body, Vector2.ZERO, size, WALL_COLOR, -10)


func _add_door(door_position: Vector2, horizontal: bool) -> void:
	var door: Door = DOOR_SCENE.instantiate() as Door
	if door == null:
		push_error("Door scene does not extend Door")
		return

	door.position = door_position
	if not horizontal:
		door.rotation_degrees = 90.0
	generated_entities.add_child(door)


func _add_rect_visual(parent: Node, center: Vector2, size: Vector2, color: Color, visual_z_index: int) -> void:
	var visual: Polygon2D = Polygon2D.new()
	visual.position = center
	visual.z_index = visual_z_index
	visual.color = color
	visual.polygon = PackedVector2Array([
		Vector2(-size.x * 0.5, -size.y * 0.5),
		Vector2(size.x * 0.5, -size.y * 0.5),
		Vector2(size.x * 0.5, size.y * 0.5),
		Vector2(-size.x * 0.5, size.y * 0.5),
	])
	parent.add_child(visual)
