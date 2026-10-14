class_name Player
extends CharacterBody2D

signal spell_cast(origin: Vector2, tokens: PackedStringArray, direction: Vector2i)
signal spell_cancelled

@export var walk_squash_speed: float = 8.0
@export var walk_squash_amount: float = 0.05
@export var show_spell_range_indicator: bool = true

@onready var sprite: Sprite2D = %Sprite2D
@onready var spell_bubble: SpellBubble = %SpellBubble
@onready var spell_range_indicator: SpellRangeIndicator = %SpellRangeIndicator
@onready var walker: GridWalker = %GridWalker

var board: GridBoard
var spell_locked: bool = false
var _base_sprite_scale: Vector2 = Vector2.ONE
var _spell_tokens: PackedStringArray = PackedStringArray()
var _pending_tokens: PackedStringArray = PackedStringArray()
var _cast_pending: bool = false
var _walk_squash_time: float = 0.0


func _ready() -> void:
	_base_sprite_scale = sprite.scale
	spell_range_indicator.hide()
	walker.step_finished.connect(_on_step_finished)


func bind_board(grid_board: GridBoard) -> void:
	board = grid_board
	walker.bind(board, self)
	reset_player()


func reset_player() -> void:
	spell_locked = false
	_cast_pending = false
	_spell_tokens = PackedStringArray()
	_pending_tokens = PackedStringArray()
	walker.reset_position()
	spell_bubble.hide_spell()
	spell_range_indicator.hide()


func finish_spell() -> void:
	spell_locked = false
	walker.set_suspended(false)


func _physics_process(delta: float) -> void:
	if not is_instance_valid(board):
		return
	if walker.facing.x != 0:
		sprite.flip_h = walker.facing.x < 0
	_update_walk_squash(delta)
	spell_range_indicator.set_direction(walker.facing, board.layout.cell_size)
	if not spell_locked:
		board.highlight_target(board.find_target(board.player_cell, walker.facing, 3))


func _unhandled_input(event: InputEvent) -> void:
	if not is_instance_valid(board):
		return
	if walker.handle_input(event):
		get_viewport().set_input_as_handled()
		return
	var key_event: InputEventKey = event as InputEventKey
	if key_event == null or not key_event.pressed or key_event.echo:
		return
	if key_event.keycode == KEY_ESCAPE:
		if _cast_pending:
			_cast_pending = false
			_pending_tokens = PackedStringArray()
			finish_spell()
		elif spell_locked:
			spell_cancelled.emit()
		else:
			_clear_spell_input()
		get_viewport().set_input_as_handled()
		return
	if spell_locked:
		return
	match key_event.keycode:
		KEY_UP:
			_add_spell_token("^")
		KEY_DOWN:
			_add_spell_token("v")
		KEY_LEFT:
			_add_spell_token("<")
		KEY_RIGHT:
			_add_spell_token(">")
		KEY_BACKSPACE:
			if not _spell_tokens.is_empty():
				_spell_tokens.remove_at(_spell_tokens.size() - 1)
				_refresh_spell_input()
		KEY_ENTER, KEY_KP_ENTER:
			_cast_spell()
		_:
			return
	get_viewport().set_input_as_handled()


func _update_walk_squash(delta: float) -> void:
	if not walker.is_moving:
		_walk_squash_time = 0.0
		sprite.scale = _base_sprite_scale
		spell_bubble.set_walk_squash(0.0)
		return
	_walk_squash_time += delta * walk_squash_speed
	var squash: float = sin(_walk_squash_time) * walk_squash_amount
	sprite.scale = _base_sprite_scale * Vector2(1.0 + squash, 1.0 - squash)
	spell_bubble.set_walk_squash(squash)


func _add_spell_token(token: String) -> void:
	_spell_tokens.append(token)
	_refresh_spell_input()


func _refresh_spell_input() -> void:
	spell_bubble.set_tokens(_spell_tokens)
	spell_range_indicator.visible = show_spell_range_indicator and not _spell_tokens.is_empty()


func _clear_spell_input() -> void:
	_spell_tokens = PackedStringArray()
	_refresh_spell_input()


func _cast_spell() -> void:
	if _spell_tokens.is_empty():
		return
	_pending_tokens = PackedStringArray(_spell_tokens)
	_clear_spell_input()
	spell_locked = true
	_cast_pending = true
	walker.set_suspended(true)
	if not walker.is_moving:
		_on_step_finished()


func _on_step_finished() -> void:
	if not _cast_pending:
		return
	_cast_pending = false
	spell_cast.emit(global_position, _pending_tokens, walker.facing)
	_pending_tokens = PackedStringArray()
