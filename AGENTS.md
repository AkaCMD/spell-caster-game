# Project Instructions

## Project Summary

- This is a Godot 4.7 2D spell-caster prototype. The player moves with WASD, enters spell tokens with arrow keys, and casts with Enter.
- Main scene is `src/levels/game.tscn` via `project.godot`; `src/core/game.gd` is the runtime coordinator.
- `Game` owns world layers: `%LevelRoot`, `%EntityRoot`, `%EffectRoot`; runtime gameplay effects should be spawned into `%EffectRoot`, not attached to the player.
- Prototype level is `src/levels/test_level.tscn`; level scripts must extend `BaseLevel` and provide `get_default_player_spawn()` and `get_player_camera()`.

## Verification

- Prefer the Godot project tools for launch checks. A useful smoke test is running `res://src/levels/game.tscn` and checking debug output for errors.
- There is no repo-local CI, package manifest, lockfile, or scripted test/lint command currently checked in.
- `godot` may not be available on the shell `PATH`; do not assume shell Godot commands work unless you verify them first.
- Use `git diff --check` before commits to catch whitespace errors.

## Editing Godot Files

- Use UTF-8 and LF for all text files.
- Do not edit files under `.godot/` unless explicitly requested; they are local editor/cache files.
- Prefer editor-safe changes for `.tscn`, `.tres`, `.import`, and UID-backed resources. Avoid hand-editing generated/cache files when a Godot tool can do it safely.
- Keep `.gd.uid` and `.gdshader.uid` files with their scripts/shaders when Godot creates them.
- New gameplay effects belong under `src/gameplay/effects/<effect_name>/`; player-specific UI/behavior belongs under `src/gameplay/player/`.

## GDScript Conventions

- Always use static typing for variables, parameters, returns, casts, and `@onready` references where Godot allows it.
- Prefer flat, modular, event-driven, component-based scripts over deep inheritance or large mixed-responsibility scripts.
- Use `%UniqueNodeName` for important local scene references and `@export` for editor-assigned dependencies; avoid parent-chain lookups like `get_parent().get_parent()`.
- Use groups for broad queries/tags and signals for gameplay events. Signal names should describe what happened, not what receivers should do.
- If a stored node reference is used after `await`, check `is_instance_valid(node)` first.
- Do not run long blocking work inside `_process`, `_physics_process`, `_input`, or signal callbacks; split long work across frames with `await get_tree().process_frame` when needed.

## Current Gameplay Wiring

- `src/gameplay/player/player.gd` owns movement, sprite facing/squash, spell token input, and emits `spell_cast(origin)` after a non-empty cast.
- `src/gameplay/player/spell_bubble.tscn` is an independent UI scene for the player's spell tokens. Keep visual tuning editor-driven; do not hard-code token color or frame opacity in script unless explicitly requested.
- `src/gameplay/effects/spell_cast_ripple/spell_cast_ripple.tscn` is a runtime effect scene. `Game` instances it and calls `play(origin)` when `Player.spell_cast` fires.
- Spell tokens currently use ASCII `^`, `v`, `<`, `>` to avoid font glyph issues.

## Commits

- Use Conventional Commits when asked to create or suggest a commit message: `type(scope): summary`.
- Prefer concise scopes already used in this repo, such as `level`, `player`, `ui`, `effects`, `scene`, `input`, `config`, or `docs`.
- Before committing, inspect status, staged diff, and recent commits. Stage only intended files; this repo often has small unrelated scene edits in the worktree.
