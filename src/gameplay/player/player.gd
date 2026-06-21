class_name Player
extends CharacterBody2D

@export var move_speed : float = 160.0
@export var walk_squash_speed : float = 10.0
@export var walk_squash_amount : float = 0.08

@onready var sprite: Sprite2D = %Sprite2D

var _walk_squash_time : float = 0.0


func _physics_process(_delta: float) -> void:
	var input_direction : Vector2 = _get_movement_input()
	_update_facing(input_direction)
	_update_walk_squash(input_direction, _delta)
	velocity = input_direction * move_speed
	move_and_slide()


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
		sprite.scale = Vector2.ONE
		return

	_walk_squash_time += delta * walk_squash_speed
	var squash : float = sin(_walk_squash_time) * walk_squash_amount
	sprite.scale = Vector2(1.0 + squash, 1.0 - squash)
