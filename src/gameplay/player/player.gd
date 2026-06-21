class_name Player
extends CharacterBody2D

@export var move_speed : float = 160.0
@export var walk_squash_speed : float = 10.0
@export var walk_squash_amount : float = 0.08

@onready var sprite: Sprite2D = %Sprite2D
@onready var spell_bubble : SpellBubble = %SpellBubble

var _base_sprite_scale : Vector2 = Vector2.ONE
var _spell_tokens : PackedStringArray = PackedStringArray()
var _walk_squash_time : float = 0.0


func _ready() -> void:
	_base_sprite_scale = sprite.scale


func _physics_process(_delta: float) -> void:
	var input_direction : Vector2 = _get_movement_input()
	_update_facing(input_direction)
	_update_walk_squash(input_direction, _delta)
	velocity = input_direction * move_speed
	move_and_slide()


func _unhandled_input(event: InputEvent) -> void:
	var key_event : InputEventKey = event as InputEventKey
	if key_event == null or not key_event.pressed or key_event.echo:
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
		KEY_ENTER, KEY_KP_ENTER:
			_cast_spell()
		_:
			return

	get_viewport().set_input_as_handled()


func _get_movement_input() -> Vector2:
	var input_direction : Vector2 = Vector2.ZERO

	if Input.is_key_pressed(KEY_A):
		input_direction.x -= 1.0
	if Input.is_key_pressed(KEY_D):
		input_direction.x += 1.0
	if Input.is_key_pressed(KEY_W):
		input_direction.y -= 1.0
	if Input.is_key_pressed(KEY_S):
		input_direction.y += 1.0

	return input_direction.normalized()


func _update_facing(input_direction: Vector2) -> void:
	if input_direction.x < 0.0:
		sprite.flip_h = true
	elif input_direction.x > 0.0:
		sprite.flip_h = false


func _update_walk_squash(input_direction: Vector2, delta: float) -> void:
	if input_direction == Vector2.ZERO:
		_walk_squash_time = 0.0
		sprite.scale = _base_sprite_scale
		spell_bubble.set_walk_squash(0.0)
		return

	_walk_squash_time += delta * walk_squash_speed
	var squash : float = sin(_walk_squash_time) * walk_squash_amount
	sprite.scale = _base_sprite_scale * Vector2(1.0 + squash, 1.0 - squash)
	spell_bubble.set_walk_squash(squash)


func _add_spell_token(token: String) -> void:
	_spell_tokens.append(token)
	spell_bubble.set_tokens(_spell_tokens)


func _cast_spell() -> void:
	if _spell_tokens.is_empty():
		return

	_spell_tokens.clear()
	spell_bubble.hide_spell()
