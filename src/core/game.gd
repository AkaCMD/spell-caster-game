class_name Game
extends Node
## Main entry point for the game.
## Responsible for setting up the World layers and coordinating high-level systems.

# Load test levels for prototype
const TEST_LEVEL : String = "uid://bvdioybxni18t"
const PLAYER_SCENE_UID : String = "uid://c82b1y5bnhj85"
const SPELL_CAST_RIPPLE_SCENE : PackedScene = preload("res://src/gameplay/effects/spell_cast_ripple/spell_cast_ripple.tscn")
const ROOM_CAMERA_MOVE_DURATION: float = 0.28
const OVERVIEW_CAMERA_MOVE_DURATION: float = 0.18

var player : Player = null
var _spell_executor: SpellExecutor

var _current_level : BaseLevel
var _current_room_index: int = 0
var _is_room_overview_active: bool = false
var _camera_tween: Tween = null

# Game World root nodes
@onready var level_root: Node2D = %LevelRoot
@onready var entity_root: Node2D = %EntityRoot
@onready var effect_root: Node2D = %EffectRoot
@onready var audio_manager: AudioManager = %AudioManager

# UI root nodes
@onready var hud_root: Control = %HudRoot
@onready var pause_root: Control = %PauseRoot
@onready var transition_root: Control = %TransitionRoot

func _ready() -> void:
	_spell_executor = SpellExecutor.new()
	add_child(_spell_executor)
	_spell_executor.feedback_requested.connect(_on_spell_feedback_requested)
	_spell_executor.execution_finished.connect(_on_spell_execution_finished)
	_init_player()
	
	load_level(TEST_LEVEL)


func _physics_process(_delta: float) -> void:
	_update_current_room_camera()


func _input(event: InputEvent) -> void:
	var key_event: InputEventKey = event as InputEventKey
	if key_event != null and not key_event.echo and key_event.keycode == KEY_TAB:
		_set_room_overview_active(key_event.pressed)
		get_viewport().set_input_as_handled()
		return

	if key_event != null and key_event.pressed and not key_event.echo:
		if key_event.keycode == KEY_R:
			_reset_room()
			get_viewport().set_input_as_handled()
		elif key_event.keycode == KEY_F10 and OS.is_debug_build():
			quit_game()


func quit_game() -> void:
	get_tree().root.propagate_notification(NOTIFICATION_WM_CLOSE_REQUEST)
	get_tree().quit()

## Called for loading a level scene.
## NOTE: The input level_scene must extend BaseLevel
func load_level(level_scene : String) -> void:
	# Make sure this is called during idle time
	_defered_load_level.call_deferred(level_scene)

func _defered_load_level(level_scene_uid : String) -> void:
	_spell_executor.cancel()
	_spell_executor.board = null
	if is_instance_valid(player):
		player.walker.set_suspended(true)
	if _current_level != null:
		_current_level.queue_free()
		_current_level = null
	
	# Allow the old level to finish freeing before adding the new one
	await get_tree().process_frame
	
	var new_level_packed : PackedScene =\
		ResourceLoader.load(level_scene_uid, "PackedScene") as PackedScene
	if new_level_packed == null:
		push_error("Could not load level as a packed scene: " + level_scene_uid)
		return
	
	_current_level = new_level_packed.instantiate() as BaseLevel
	if _current_level == null:
		push_error("Loaded level does not extend BaseLevel")
		return
		# FUTURE: Should have a fall back scene
	
	level_root.add_child(_current_level)
	
	# Allow level to fully process before accessing it
	await get_tree().process_frame
	if not is_instance_valid(_current_level) or not is_instance_valid(player):
		return
	var board: GridBoard = _current_level.get_grid_board()
	if board == null:
		push_error("Level does not provide a grid board")
		return
	_spell_executor.board = board
	board.puzzle_solved.connect(_on_puzzle_solved)
	player.bind_board(board)
	_place_player_at_level_spawn()
	_current_room_index = _current_level.get_room_index_at_position(player.global_position)
	_is_room_overview_active = false
	_setup_level_camera()


## Instantiates the player and adds it to the entity layer
func _init_player() -> void:
	var player_scene : PackedScene = ResourceLoader.load(PLAYER_SCENE_UID) as PackedScene
	if player_scene == null:
		push_error("Could not load player scene: " + PLAYER_SCENE_UID)
		return
	
	player = player_scene.instantiate() as Player
	if player == null:
		push_error("Loaded player scene does not extend player or DNE: " + PLAYER_SCENE_UID)
		return
		
	entity_root.add_child(player)
	player.spell_cast.connect(_on_player_spell_cast)
	player.spell_cancelled.connect(_spell_executor.cancel)


func _on_player_spell_cast(origin: Vector2, tokens: PackedStringArray, direction: Vector2i) -> void:
	_spell_executor.begin(tokens, direction, origin)


func _on_spell_execution_finished() -> void:
	if is_instance_valid(player):
		player.finish_spell()


func _on_spell_feedback_requested(origin: Vector2, valid_program: bool) -> void:
	_spawn_spell_cast_ripple(origin, valid_program)
	if valid_program:
		audio_manager.play_spell_succeed()


func _on_puzzle_solved() -> void:
	audio_manager.play_open_door()


func _reset_room() -> void:
	if not is_instance_valid(_current_level) or not is_instance_valid(player):
		return
	_spell_executor.cancel()
	var board: GridBoard = _current_level.get_grid_board()
	if board == null:
		return
	board.reset_room()
	player.reset_player()
	for effect: Node in effect_root.get_children():
		effect.queue_free()


func _spawn_spell_cast_ripple(origin: Vector2, valid_program: bool = true) -> void:
	var ripple: SpellCastRipple = SPELL_CAST_RIPPLE_SCENE.instantiate() as SpellCastRipple
	if ripple == null:
		push_error("Spell cast ripple scene does not extend SpellCastRipple")
		return
	if not valid_program:
		ripple.effect_size = Vector2(80.0, 80.0)
		ripple.duration = 0.24
	effect_root.add_child(ripple)
	ripple.play(origin, not valid_program)


## Finds the default spawn location in currently loaded level, and places
##  the Player at that position.
func _place_player_at_level_spawn() -> void:
	if player == null:
		push_error("Cannot place player in level because it is null")
		return
	if _current_level == null:
		push_error("Cannot place player into level because level is null")
		return
		
	player.global_position = _current_level.get_default_player_spawn()
	
## Positions the level camera for prototype gameplay.
func _setup_level_camera() -> void:
	if player == null or _current_level == null:
		return
		
	var level_camera : Camera2D = _current_level.get_player_camera()
	if level_camera == null:
		return

	level_camera.global_position = _current_level.get_room_camera_position(_current_room_index)
	level_camera.zoom = Vector2.ONE
	level_camera.enabled = true
	level_camera.make_current()


func _update_current_room_camera() -> void:
	if player == null or _current_level == null:
		return

	var room_index: int = _current_level.get_room_index_at_position(player.global_position)
	if room_index == _current_room_index:
		return

	_current_room_index = room_index
	if not _is_room_overview_active:
		_move_camera_to(_current_level.get_room_camera_position(_current_room_index), Vector2.ONE, ROOM_CAMERA_MOVE_DURATION)


func _set_room_overview_active(is_active: bool) -> void:
	if _current_level == null:
		return
	if is_active == _is_room_overview_active:
		return

	_is_room_overview_active = is_active
	if _is_room_overview_active:
		_move_camera_to(
			_current_level.get_overview_camera_position(),
			_current_level.get_overview_camera_zoom(),
			OVERVIEW_CAMERA_MOVE_DURATION
		)
	else:
		_move_camera_to(
			_current_level.get_room_camera_position(_current_room_index),
			Vector2.ONE,
			ROOM_CAMERA_MOVE_DURATION
		)


func _move_camera_to(target_position: Vector2, target_zoom: Vector2, duration: float) -> void:
	var level_camera: Camera2D = _current_level.get_player_camera()
	if level_camera == null:
		return

	if _camera_tween != null:
		_camera_tween.kill()

	_camera_tween = create_tween()
	_camera_tween.set_parallel(true)
	_camera_tween.tween_property(level_camera, "global_position", target_position, duration)
	_camera_tween.tween_property(level_camera, "zoom", target_zoom, duration)


func _init_systems() -> void:
	pass # FUTURE (systems): Will be called to set up high level systems
