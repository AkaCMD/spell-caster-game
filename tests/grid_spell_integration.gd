extends SceneTree
## Run with Godot --headless --path . --fixed-fps 60 --script res://tests/grid_spell_integration.gd

var _game: Game
var _board: GridBoard
var _player: Player
var _failures: int = 0
var _checks: int = 0
var _feedback: Array[bool] = []


func _initialize() -> void:
	_run.call_deferred()


func _run() -> void:
	_game = (load("res://src/levels/game.tscn") as PackedScene).instantiate() as Game
	root.add_child(_game)
	await _frames(5)
	_player = _game.player
	_board = _player.board
	_game._spell_executor.feedback_requested.connect(_on_feedback)
	_check(_board != null and _board.pillars.size() == 3, "main scene loads three pillars")
	_test_layout()
	await _test_movement()
	await _test_spell_programs()
	await _test_solution_route()
	await _test_second_solution_route()
	_key(KEY_R)
	_check(not _board.solved and _board.door.state == Door.DoorState.LOCKED, "R restores closed door")
	_check(_board.player_cell == _board.layout.spawn_cell and not _player.spell_locked, "R restores player and control")
	for index: int in range(_board.pillars.size()):
		_check(_board.pillars[index].cell == _board.layout.pillar_cells[index] and not _board.pillars[index].is_moving, "R restores pillar %d" % index)
	_game.queue_free()
	await _frames(3)
	print("Grid/spell integration: %d checks, %d failures" % [_checks, _failures])
	quit(0 if _failures == 0 else 1)


func _test_layout() -> void:
	_check(_board.matches_solution([Vector2i(6, 4), Vector2i(9, 4), Vector2i(6, 5)]), "first translated solution")
	_check(_board.matches_solution([Vector2i(7, 5), Vector2i(7, 4), Vector2i(10, 4)]), "second translated solution, interchangeable pillars")
	_check(not _board.matches_solution([Vector2i(6, 4), Vector2i(9, 4), Vector2i(9, 5)]), "mirror rejected")
	_check(not _board.matches_solution([Vector2i(6, 4), Vector2i(6, 7), Vector2i(5, 4)]), "rotation rejected")
	var reachable: Array[Vector2i] = [_board.layout.spawn_cell]
	var index: int = 0
	while index < reachable.size():
		var cell: Vector2i = reachable[index]
		index += 1
		for direction: Vector2i in [Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.RIGHT]:
			var next: Vector2i = cell + direction
			if _board.is_walkable(next) and not reachable.has(next):
				reachable.append(next)
	_check(not reachable.has(Vector2i(9, 5)), "island cannot be reached on foot, so remote magic is necessary")
	_check(_board.find_target(Vector2i(9, 8), Vector2i.UP, 3) == _board.pillars[2], "gaps do not block spells")
	_check(_board.find_target(Vector2i(9, 8), Vector2i.UP, 2) == null, "three-cell initial range")
	_board.layout.wall_cells.append(Vector2i(9, 7))
	_check(_board.find_target(Vector2i(9, 8), Vector2i.UP, 3) == null, "wall occludes pillar")
	_board.layout.wall_cells.clear()
	_check(_board.find_target(Vector2i(4, 5), Vector2i.RIGHT, 3) == _board.pillars[0], "first object blocks later targets")
	_check(_board.find_target(Vector2i(16, 5), Vector2i.RIGHT, 3) == _board.door, "closed door is a blocking target")


func _test_movement() -> void:
	_place_player(Vector2i(4, 5))
	_player.walker.request_step(Vector2i.RIGHT)
	_check(_board.player_cell == Vector2i(4, 5), "no chain pushing")
	_check(_player.walker.facing == Vector2i.RIGHT, "blocked move updates facing")
	_place_player(Vector2i(5, 6))
	await _step(Vector2i.UP)
	_check(_board.pillars[0].cell == Vector2i(5, 4) and _board.player_cell == Vector2i(5, 5), "near push moves player into vacated slot")
	_game._reset_room()
	_player.walker.request_step(Vector2i.LEFT)
	for index: int in range(5):
		_player.walker.request_step(Vector2i.UP)
	_check(_player.walker.queued_step_count() == 2, "movement queue capped at two")
	await _frames(5)
	_check(_player.walker._elapsed > 5.0 / 60.0, "queued inputs accelerate walking animation")
	await _frames(45)
	_check(_board.player_cell == Vector2i(2, 4), "only queued two steps execute")
	_check(_player.global_position.is_equal_approx(_board.cell_to_world(_board.player_cell)), "movement ends exactly on cell")
	_game._reset_room()
	_key(KEY_UP)
	_key(KEY_RIGHT)
	_player.walker.request_step(Vector2i.LEFT)
	_player.walker.request_step(Vector2i.UP)
	_key(KEY_ENTER)
	_check(_player.spell_locked and _player.walker.queued_step_count() == 0, "Enter clears queue and defers cast")
	await _frames(30)
	_check(_board.player_cell == Vector2i(2, 6) and not _player.spell_locked, "cast finishes current step only")
	_key(KEY_UP)
	_key(KEY_RIGHT)
	_key(KEY_BACKSPACE)
	_check(_player._spell_tokens == PackedStringArray(["^"]), "Backspace removes final token")
	_key(KEY_ESCAPE)
	_check(_player._spell_tokens.is_empty(), "Esc clears input instead of quitting game")
	_game._reset_room()
	_key(KEY_D)
	await _frames(5)
	_check(_board.player_cell == Vector2i(4, 6), "physical WASD starts one step")
	await _frames(20)
	_key_release(KEY_D)
	await _frames(30)
	_check(_board.player_cell.x > 4, "held WASD repeats after delay")
	var stopped_cell: Vector2i = _board.player_cell
	await _frames(30)
	_check(_board.player_cell == stopped_cell, "release stops repeat after buffered steps")
	_game._reset_room()
	for index: int in range(20):
		_key(KEY_UP)
		_key(KEY_RIGHT)
	_check(_player._spell_tokens.size() == 40, "real input has no instruction length cap")
	_check(_player.spell_bubble.label.text.begins_with("..."), "long input is retained with a bounded visual tail")
	_player.walker.request_step(Vector2i.LEFT)
	_key(KEY_ENTER)
	var feedback_before: int = _feedback.size()
	_key(KEY_ESCAPE)
	await _frames(20)
	_check(not _player.spell_locked and _feedback.size() == feedback_before, "Esc cancels pending cast while current step finishes")
	_check(_board.player_cell == Vector2i(2, 6), "pending cast cancellation preserves current walking step")


func _test_spell_programs() -> void:
	_game._reset_room()
	_place_player(Vector2i(9, 8), Vector2i.UP)
	_cast(PackedStringArray(["^", ">", "v", ">"]))
	await _frames(20)
	_check(_board.pillars[2].cell == Vector2i(9, 5), "unknown instruction rejects entire spell atomically")
	_check(not _feedback.back(), "invalid sequence requests subdued feedback")
	_cast(PackedStringArray(["^"]))
	await _frames(10)
	_check(_board.pillars[2].cell == Vector2i(9, 5), "incomplete instruction rejected")
	var long_program: PackedStringArray = PackedStringArray()
	for index: int in range(2048):
		long_program.append("^")
		long_program.append(">")
	long_program.append("v")
	long_program.append(">")
	_cast(long_program)
	await _frames(20)
	_check(_board.pillars[2].cell == Vector2i(9, 5), "late invalid opcode prevents earlier effects in long program")
	long_program.resize(4096)
	_cast(long_program)
	await _frames(35)
	_check(_board.pillars[2].cell == Vector2i(9, 4) and not _player.spell_locked, "unbounded valid program stops at obstruction, preserves first push")
	_game._reset_room()
	_board.pillars[2].reset_to(Vector2i(9, 4), _board.cell_to_local(Vector2i(9, 4)))
	_place_player(Vector2i(7, 4), Vector2i.RIGHT)
	_cast(PackedStringArray(["^", ">", "^", ">", "^", ">"]))
	await _frames(45)
	_check(_board.pillars[2].cell == Vector2i(11, 4), "locked target continues past initial range")
	_game._reset_room()
	_place_player(Vector2i(9, 8), Vector2i.UP)
	_cast(PackedStringArray(["^", ">", "^", ">"]))
	await _frames(4)
	_key(KEY_ESCAPE)
	await _frames(20)
	_check(_board.pillars[2].cell == Vector2i(9, 4) and not _player.spell_locked, "Esc retains committed move and restores control")
	_game._reset_room()
	_place_player(Vector2i(9, 8), Vector2i.UP)
	_cast(long_program)
	await _frames(2)
	_game._reset_room()
	await _frames(20)
	_check(_board.pillars[2].cell == Vector2i(9, 5), "R cancels long validation without later side effects")
	_place_player(Vector2i(9, 8), Vector2i.UP)
	_cast(PackedStringArray(["^", ">"]))
	await _frames(4)
	_game._reset_room()
	await _frames(20)
	_check(_board.pillars[2].cell == Vector2i(9, 5) and not _player.spell_locked, "R interrupts animation and restores grid state")
	_place_player(Vector2i(3, 6), Vector2i.LEFT)
	_cast(PackedStringArray(["^", ">"]))
	await _frames(10)
	_check(not _player.spell_locked, "valid spell without target restores control")
	_check(_feedback.back(), "valid spell without target still requests cast feedback")
	_game._reset_room()
	_place_player(Vector2i(9, 8), Vector2i.UP)
	_cast(long_program)
	await _frames(2)
	_game.load_level(Game.TEST_LEVEL)
	await _frames(12)
	_board = _player.board
	_check(_board != null and _board.pillars[2].cell == Vector2i(9, 5) and not _player.spell_locked, "level reload cancels outstanding spell and binds fresh board")


func _test_solution_route() -> void:
	_game._reset_room()
	for direction: Vector2i in [Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.UP, Vector2i.DOWN, Vector2i.LEFT, Vector2i.LEFT, Vector2i.UP, Vector2i.RIGHT]:
		await _step(direction)
	_check(_board.pillars[0].cell == Vector2i(6, 5) and _board.pillars[1].cell == Vector2i(6, 4), "walking route arranges mainland pillars")
	for direction: Vector2i in [Vector2i.DOWN, Vector2i.DOWN, Vector2i.DOWN, Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.RIGHT]:
		await _step(direction)
	_check(_board.player_cell == Vector2i(9, 8), "walking route reaches island casting position")
	await _step(Vector2i.UP)
	_check(_board.player_cell == Vector2i(9, 8) and _player.walker.facing == Vector2i.UP, "gap blocks walking and allows aiming")
	_key(KEY_UP)
	_key(KEY_RIGHT)
	_key(KEY_ENTER)
	await _frames(45)
	_check(_board.solved and _board.door.state == Door.DoorState.COMPLETE, "real input completes puzzle and opens door")
	_check(_board.is_walkable(_board.layout.door_cell), "open doorway is passable")
	_place_player(Vector2i(5, 4), Vector2i.RIGHT)
	_cast(PackedStringArray(["^", ">"]))
	await _frames(20)
	_check(_board.pillars[1].cell == Vector2i(7, 4), "pillar moves away from completed arrangement")
	_check(_board.solved and _board.door.state == Door.DoorState.COMPLETE, "door stays open after arrangement changes")


func _test_second_solution_route() -> void:
	_game._reset_room()
	for direction: Vector2i in [Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.UP, Vector2i.RIGHT]:
		await _step(direction)
	_cast(PackedStringArray(["^", ">"]))
	await _frames(20)
	for direction: Vector2i in [Vector2i.DOWN, Vector2i.DOWN, Vector2i.DOWN, Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.RIGHT, Vector2i.UP]:
		await _step(direction)
	_cast(PackedStringArray(["^", ">"]))
	await _frames(20)
	for direction: Vector2i in [Vector2i.LEFT, Vector2i.LEFT, Vector2i.LEFT, Vector2i.LEFT, Vector2i.LEFT, Vector2i.UP, Vector2i.UP, Vector2i.UP, Vector2i.RIGHT, Vector2i.DOWN, Vector2i.LEFT, Vector2i.LEFT, Vector2i.UP, Vector2i.UP, Vector2i.RIGHT, Vector2i.RIGHT]:
		await _step(direction)
	_check(_board.pillars[0].cell == Vector2i(7, 4) and _board.pillars[1].cell == Vector2i(7, 5) and _board.pillars[2].cell == Vector2i(10, 4), "second translated arrangement is reachable")
	_check(_board.solved, "second translated arrangement opens door")


func _place_player(cell: Vector2i, facing: Vector2i = Vector2i.RIGHT) -> void:
	_board.player_cell = cell
	_player.reset_player()
	_player.walker.facing = facing


func _step(direction: Vector2i) -> void:
	_player.walker.request_step(direction)
	await _frames(15)


func _cast(tokens: PackedStringArray) -> void:
	_player._spell_tokens = PackedStringArray(tokens)
	_player._cast_spell()


func _key(keycode: Key) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = keycode
	event.physical_keycode = keycode
	event.pressed = true
	Input.parse_input_event(event)
	Input.flush_buffered_events()
	if keycode not in [KEY_W, KEY_A, KEY_S, KEY_D]:
		_key_release(keycode)


func _key_release(keycode: Key) -> void:
	var event: InputEventKey = InputEventKey.new()
	event.keycode = keycode
	event.physical_keycode = keycode
	event.pressed = false
	Input.parse_input_event(event)
	Input.flush_buffered_events()


func _frames(count: int) -> void:
	for index: int in range(count):
		await process_frame


func _check(condition: bool, description: String) -> void:
	_checks += 1
	if not condition:
		_failures += 1
		push_error("FAILED: " + description)


func _on_feedback(_origin: Vector2, valid_program: bool) -> void:
	_feedback.append(valid_program)
