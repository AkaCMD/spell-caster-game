class_name TestLevel
extends BaseLevel

@onready var player_spawn_marker : PlayerSpawn = %PlayerSpawn
@onready var player_camera : Camera2D = %PlayerCamera

func get_default_player_spawn() -> Vector2:
	return player_spawn_marker.global_position

func get_player_camera() -> Camera2D:
	return player_camera
