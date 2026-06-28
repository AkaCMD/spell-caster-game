@abstract
class_name BaseLevel
extends Node2D
## Abstract class for levels


## Provides a player spawn location
@abstract func get_default_player_spawn() -> Vector2

## Provides the camera used in the level
@abstract func get_player_camera() -> Camera2D

## Finds the room index containing a world position.
@abstract func get_room_index_at_position(world_position: Vector2) -> int

## Provides the camera center for a room.
@abstract func get_room_camera_position(room_index: int) -> Vector2

## Provides the overview camera center for the whole level.
@abstract func get_overview_camera_position() -> Vector2

## Provides the overview camera zoom for the whole level.
@abstract func get_overview_camera_zoom() -> Vector2
