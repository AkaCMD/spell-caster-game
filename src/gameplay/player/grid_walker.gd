class_name GridWalker
extends Node

signal step_finished

@export var step_duration: float = 0.18
@export var queued_speed_multiplier: float = 1.8
@export var hold_delay: float = 0.25
@export var hold_interval: float = 0.12

var board: GridBoard
var body: Node2D
var facing: Vector2i = Vector2i.RIGHT
var is_moving: bool = false
var suspended: bool = false
var _queue: Array[Vector2i] = []
var _pressed: Array[Vector2i] = []
var _held_direction: Vector2i = Vector2i.ZERO
var _repeat_remaining: float = 0.0
var _start: Vector2 = Vector2.ZERO
var _end: Vector2 = Vector2.ZERO
var _elapsed: float = 0.0
var _pushed_pillar: MagicPillar = null


func bind(grid_board: GridBoard, player_body: Node2D) -> void:
	board = grid_board
	body = player_body
	reset_position()


func reset_position() -> void:
	is_moving = false
	suspended = false
	facing = Vector2i.RIGHT
	_elapsed = 0.0
	_pushed_pillar = null
	_clear_input()
	if is_instance_valid(board) and is_instance_valid(body):
		body.global_position = board.cell_to_world(board.player_cell)


func set_suspended(value: bool) -> void:
	suspended = value
	if value:
		_clear_input()


func handle_input(event: InputEvent) -> bool:
	var actions: Array[StringName] = [&"move_up", &"move_down", &"move_left", &"move_right"]
	var directions: Array[Vector2i] = [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]
	for index: int in range(actions.size()):
		if event.is_action_pressed(actions[index]):
			if not suspended:
				var direction: Vector2i = directions[index]
				_pressed.erase(direction)
				_pressed.append(direction)
				_held_direction = direction
				_repeat_remaining = hold_delay
				request_step(direction)
			return true
		if event.is_action_released(actions[index]):
			_pressed.erase(directions[index])
			_held_direction = _pressed.back() if not _pressed.is_empty() else Vector2i.ZERO
			return true
	return false


func request_step(direction: Vector2i) -> void:
	if suspended or not is_instance_valid(board):
		return
	if is_moving:
		if _queue.size() < 2:
			_queue.append(direction)
	else:
		_start_step(direction)


func queued_step_count() -> int:
	return _queue.size()


func _physics_process(delta: float) -> void:
	if not is_instance_valid(board) or not is_instance_valid(body):
		return
	if not suspended and _held_direction != Vector2i.ZERO:
		_repeat_remaining -= delta
		if _repeat_remaining <= 0.0:
			_repeat_remaining = hold_interval
			request_step(_held_direction)
	if not is_moving:
		return
	var playback_speed: float = queued_speed_multiplier if not _queue.is_empty() else 1.0
	if is_instance_valid(_pushed_pillar):
		_pushed_pillar.playback_speed = playback_speed
	_elapsed = minf(_elapsed + delta * playback_speed, step_duration)
	var progress: float = _elapsed / maxf(step_duration, 0.01)
	# Linear interpolation keeps adjacent queued steps flowing continuously.
	body.global_position = _start.lerp(_end, progress)
	if _elapsed < step_duration:
		return
	if is_instance_valid(_pushed_pillar):
		_pushed_pillar.finish_move()
	_pushed_pillar = null
	is_moving = false
	board.check_solution()
	step_finished.emit()
	if not suspended and not _queue.is_empty():
		_start_step(_queue.pop_front())


func _start_step(direction: Vector2i) -> void:
	facing = direction
	_pushed_pillar = board.pillar_at(board.player_cell + direction)
	if not board.try_player_step(direction, step_duration):
		_pushed_pillar = null
		_queue.clear()
		return
	_start = body.global_position
	_end = board.cell_to_world(board.player_cell)
	_elapsed = 0.0
	is_moving = true


func _clear_input() -> void:
	_queue.clear()
	_pressed.clear()
	_held_direction = Vector2i.ZERO
	_repeat_remaining = 0.0
