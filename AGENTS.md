# Project Instructions

## Verification

- After gameplay or scene changes, smoke-test the main scene configured in `project.godot` and check debug output for errors. Prefer Godot project tools; verify the editor binary's location before using shell commands.
- For movement, spell, reset, or puzzle logic changes, follow `tests/README.md` and require zero failed checks.
- Before committing, run `git diff --check`.

## Editing Godot Files

- Use UTF-8 and LF for text files.
- Leave `.godot/` editor/cache files untouched unless explicitly requested.
- Prefer editor-safe changes for scenes and resources. Keep generated `.gd.uid` and `.gdshader.uid` files with their scripts/shaders.
- Put new gameplay effects under `src/gameplay/effects/<effect_name>/` and player-specific UI/behavior under `src/gameplay/player/`.

## GDScript Conventions

- Use static typing for variables, parameters, returns, casts, and `@onready` references where Godot allows it.
- Prefer flat, modular, event-driven components over deep inheritance or mixed-responsibility scripts.
- Use `%UniqueNodeName` for important local scene references and `@export` for editor-assigned dependencies; avoid parent-chain lookups.
- Use groups for broad queries/tags and signals for gameplay events. Name signals after what happened.
- Check `is_instance_valid(node)` before using a stored node reference after `await`.
- Split long work across frames so processing, input, and signal callbacks remain responsive.

## Gameplay Conventions

- Logical grid cells are the source of truth; interpolated node positions are visual state. Use the board's cell/world conversion methods at the boundary.
- Keep walking animation acceleration independent of spell animation timing.
- Spawn runtime gameplay effects in `Game`'s `%EffectRoot`.
- Keep spell-bubble visuals editor-driven unless explicitly requested otherwise.
- Use ASCII `^`, `v`, `<`, `>` for spell tokens with the current font to avoid missing glyphs.

## Commits

- Use Conventional Commits: `type(scope): summary`.
- Inspect status, staged diff, and recent commits; stage only intended files. This repo often has unrelated scene edits in the worktree.

## Project Docs

- For issues and specs, read `docs/agents/issue-tracker.md`.
- For issue triage, read `docs/agents/triage-labels.md`.
- Before changing gameplay rules or domain terminology, read `CONTEXT.md` and relevant decisions under `docs/adr/`. For spell language changes, read `docs/adr/0001-composable-spell-instructions.md`.
- For domain documentation structure, follow `docs/agents/domain.md`.
