class_name SpellBubble
extends Node2D

@export var padding : Vector2 = Vector2(10.0, 6.0)
@export var min_size : Vector2 = Vector2(52.0, 28.0)
@export var text_color : Color = Color(0.18, 0.12, 0.28, 1.0)
@export var bubble_squash_amount : float = 1.0
@export var text_squash_amount : float = 1.0

@onready var bubble_root : Control = %BubbleRoot
@onready var frame_root : Control = %FrameRoot
@onready var bubble_fill : ColorRect = %BubbleFill
@onready var bubble_frame : NinePatchRect = %BubbleFrame
@onready var label : Label = %SpellLabel

var _bubble_size : Vector2 = min_size
var _current_squash : float = 0.0
var _label_base_position : Vector2 = Vector2.ZERO
var _label_base_size : Vector2 = Vector2.ZERO


func _ready() -> void:
	label.add_theme_color_override("font_color", text_color)
	hide_spell()


func set_tokens(tokens: PackedStringArray) -> void:
	if tokens.is_empty():
		hide_spell()
		return

	visible = true
	label.text = " ".join(tokens)
	_update_layout()


func hide_spell() -> void:
	visible = false
	label.text = ""
	_update_layout()


func _update_layout() -> void:
	var text_size : Vector2 = label.get_combined_minimum_size()
	_bubble_size = Vector2(
		maxf(min_size.x, text_size.x + padding.x * 2.0),
		maxf(min_size.y, text_size.y + padding.y * 2.0)
	)
	label.position = padding
	label.size = Vector2(_bubble_size.x - padding.x * 2.0, _bubble_size.y - padding.y * 2.0)
	_label_base_position = label.position
	_label_base_size = label.size
	bubble_root.position = Vector2(-_bubble_size.x * 0.5, -_bubble_size.y)
	bubble_root.size = _bubble_size
	frame_root.size = _bubble_size
	bubble_fill.size = _bubble_size
	bubble_frame.size = _bubble_size
	_apply_squash()


func set_walk_squash(squash: float) -> void:
	_current_squash = squash
	_apply_squash()


func _apply_squash() -> void:
	var frame_squash : float = _current_squash * bubble_squash_amount
	frame_root.scale = Vector2(1.0 + frame_squash, 1.0 - frame_squash)
	frame_root.position = _bubble_size * (Vector2.ONE - frame_root.scale) * 0.5

	var scaled_squash : float = _current_squash * text_squash_amount
	label.scale = Vector2(1.0 + scaled_squash, 1.0 - scaled_squash)
	label.position = _label_base_position + _label_base_size * (Vector2.ONE - label.scale) * 0.5
