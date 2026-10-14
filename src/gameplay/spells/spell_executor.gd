class_name SpellExecutor
extends Node
## Validation and execution advance across frames, including unbounded input.

signal feedback_requested(origin: Vector2, valid_program: bool)
signal execution_finished

enum Phase { IDLE, VALIDATING, EXECUTING }

@export var instruction_duration: float = 0.18
@export var validation_pairs_per_frame: int = 256

var board: GridBoard
var phase: Phase = Phase.IDLE
var _tokens: PackedStringArray = PackedStringArray()
var _index: int = 0
var _origin: Vector2 = Vector2.ZERO
var _direction: Vector2i = Vector2i.RIGHT
var _target: Node2D = null
var _wait_remaining: float = 0.0


func begin(tokens: PackedStringArray, direction: Vector2i, origin: Vector2) -> void:
	cancel()
	_tokens = PackedStringArray(tokens)
	_direction = direction
	_origin = origin
	_index = 0
	phase = Phase.VALIDATING


func cancel() -> void:
	if phase == Phase.IDLE:
		return
	# Already committed pillar moves finish normally; no partial grid positions.
	_finish()


func _process(delta: float) -> void:
	if phase == Phase.VALIDATING:
		_validate_chunk()
	elif phase == Phase.EXECUTING:
		_wait_remaining = maxf(0.0, _wait_remaining - delta)
		if _wait_remaining == 0.0:
			_execute_next()


func _validate_chunk() -> void:
	if _tokens.is_empty() or _tokens.size() % 2 != 0:
		_reject()
		return
	var end: int = mini(_index + maxi(1, validation_pairs_per_frame) * 2, _tokens.size())
	while _index < end:
		if _tokens[_index] != "^" or _tokens[_index + 1] != ">":
			_reject()
			return
		_index += 2
	if _index < _tokens.size():
		return
	feedback_requested.emit(_origin, true)
	_target = board.find_target(board.player_cell, _direction, 3)
	board.highlight_target(_target)
	_index = 0
	_wait_remaining = 0.0
	phase = Phase.EXECUTING
	if _target == null:
		_finish()


func _execute_next() -> void:
	if not is_instance_valid(_target):
		_finish()
		return
	var pillar: MagicPillar = _target as MagicPillar
	if pillar != null and pillar.is_moving:
		return
	if _index >= _tokens.size():
		board.check_solution()
		_finish()
		return
	if pillar == null or not board.try_push(pillar, _direction, instruction_duration):
		if _target is Door:
			(_target as Door).show_blocked()
		_finish()
		return
	_index += 2
	_wait_remaining = instruction_duration
	board.set_status("Spell  %d / %d" % [_index / 2, _tokens.size() / 2])


func _reject() -> void:
	feedback_requested.emit(_origin, false)
	_finish()


func _finish() -> void:
	phase = Phase.IDLE
	_tokens = PackedStringArray()
	_target = null
	if is_instance_valid(board):
		board.set_status("The stone door is open." if board.solved else "")
	execution_finished.emit()
