class_name AudioManager
extends Node

const BGM_STREAM: AudioStream = preload("res://assets/audio/bgm.wav")
const SPELL_SUCCEED_STREAM: AudioStream = preload("res://assets/audio/spell_succeed.ogg")
const OPEN_DOOR_STREAM: AudioStream = preload("res://assets/audio/open_door.ogg")

@export var bgm_volume_db: float = -8.0
@export var sfx_volume_db: float = 0.0

@onready var bgm_player: AudioStreamPlayer = %BgmPlayer


func _ready() -> void:
	await get_tree().process_frame
	_start_bgm()


func _start_bgm() -> void:
	bgm_player.stream = BGM_STREAM
	bgm_player.volume_db = bgm_volume_db
	if not bgm_player.playing:
		bgm_player.play()


func play_spell_succeed() -> void:
	_play_sfx(SPELL_SUCCEED_STREAM)


func play_open_door(delay: float = 0.0) -> void:
	if delay > 0.0:
		await get_tree().create_timer(delay).timeout
	_play_sfx(OPEN_DOOR_STREAM)


func _play_sfx(stream: AudioStream) -> void:
	var player: AudioStreamPlayer = AudioStreamPlayer.new()
	player.stream = stream
	player.volume_db = sfx_volume_db
	add_child(player)
	player.finished.connect(player.queue_free)
	player.play()
