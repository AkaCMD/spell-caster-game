class_name Game
extends Node
## Main entry point for the game.
## Responsible for setting up the World layers and coordinating high-level systems.

# Load test levels for prototype
const TEST_LEVEL : String = "uid://bvdioybxni18t"
const PLAYER_SCENE_UID : String = "uid://c82b1y5bnhj85"
const SPELL_CAST_RIPPLE_SCENE : PackedScene = preload("res://src/gameplay/effects/spell_cast_ripple/spell_cast_ripple.tscn")

var player : Player = null

var _current_level : BaseLevel

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
	_init_player()
	
	load_level(TEST_LEVEL)
	

## Called for loading a level scene.
## NOTE: The input level_scene must extend BaseLevel
func load_level(level_scene : String) -> void:
	# Make sure this is called during idle time
	_defered_load_level.call_deferred(level_scene)

func _defered_load_level(level_scene_uid : String) -> void:
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
		push_error("Loaded level is not of tyoe Level or does not exist")
		return
		# FUTURE: Should have a fall back scene
	
	level_root.add_child(_current_level)
	
	# Allow level to fully process before accessing it
	await get_tree().process_frame
	_place_player_at_level_spawn()
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


func _on_player_spell_cast(origin: Vector2, tokens: PackedStringArray, effect_radius: float) -> void:
	if _notify_spell_doors(origin, tokens, effect_radius):
		audio_manager.play_spell_succeed()
		audio_manager.play_open_door(0.5)
		_spawn_spell_cast_ripple(origin)


func _spawn_spell_cast_ripple(origin: Vector2) -> void:
	var ripple: SpellCastRipple = SPELL_CAST_RIPPLE_SCENE.instantiate() as SpellCastRipple
	if ripple == null:
		push_error("Spell cast ripple scene does not extend SpellCastRipple")
		return

	effect_root.add_child(ripple)
	ripple.play(origin)


func _notify_spell_doors(origin: Vector2, tokens: PackedStringArray, effect_radius: float) -> bool:
	var spell_had_effect: bool = false

	for node: Node in get_tree().get_nodes_in_group("spell_doors"):
		var door: Door = node as Door
		if door == null:
			continue
		if door.try_open(origin, tokens, effect_radius):
			spell_had_effect = true

	return spell_had_effect


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

	level_camera.global_position = player.global_position
	level_camera.enabled = true
	level_camera.make_current()


func _init_systems() -> void:
	pass # FUTURE (systems): Will be called to set up high level systems
