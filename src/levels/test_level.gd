class_name TestLevel
extends BaseLevel

@export var room_layout: GridRoomLayout = GridRoomLayout.new()

@onready var player_spawn_marker: PlayerSpawn = %PlayerSpawn
@onready var player_camera: Camera2D = %PlayerCamera
@onready var map_root: Node2D = %MapRoot

var board: GridBoard


func _ready() -> void:
	board = GridBoard.new()
	board.name = "GridBoard"
	board.layout = room_layout
	map_root.add_child(board)
	player_spawn_marker.global_position = board.cell_to_world(room_layout.spawn_cell)
	player_camera.global_position = global_position


func get_grid_board() -> GridBoard:
	return board


func get_default_player_spawn() -> Vector2:
	return player_spawn_marker.global_position


func get_player_camera() -> Camera2D:
	return player_camera


func get_room_index_at_position(_world_position: Vector2) -> int:
	return 0


func get_room_camera_position(_room_index: int) -> Vector2:
	return global_position


func get_overview_camera_position() -> Vector2:
	return global_position


func get_overview_camera_zoom() -> Vector2:
	return Vector2.ONE
