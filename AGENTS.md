# Project Instructions

- Use UTF-8 and LF for all text files.
- Always using static typing
- Do not edit files under `.godot/` unless explicitly requested; they are local editor/cache files.
- Prefer editor-safe changes for Godot resources and scenes. Avoid hand-editing generated or cache files.

## GDScript Architecture

Prefer flat, modular, event-driven, component-based scripts. Godot uses a Scene Tree, but code architecture should not mechanically mirror that tree.

### Components

- Keep each script focused on one clear responsibility.
- Prefer child-node components for reusable behavior.
- Do not introduce deep inheritance unless explicitly requested.
- Avoid giant scripts that mix movement, health, combat, inventory, UI, and dialogue.

Good structure:

```text
Player
├── HealthComponent
├── MovementComponent
├── WeaponComponent
└── InteractionComponent
```

### Scene References

- Avoid hidden Scene Tree assumptions and parent-chain lookups such as `get_parent().get_parent()`.
- Use `%UniqueNodeName` for important local scene references.
- Use `@export` for editor-assigned dependencies.
- Avoid long hardcoded node paths.

Prefer:

```gdscript
@onready var weapon: Node2D = %Weapon
@export var target: Node2D
```

Avoid:

```gdscript
$A/B/C/D
get_parent().get_parent()
```

### Groups

- Use groups for broad queries, tags, and loose coupling.
- Prefer groups over manually maintained lists of dynamic nodes.

```gdscript
for enemy in get_tree().get_nodes_in_group(&"enemies"):
	enemy.alert()
```

### Signals

- Use signals for events; signal names should describe what happened, not what receivers should do.
- Prefer direct high-level signal wiring. (use signal breadboard)
- Avoid proxy chains like `Child -> Parent -> Grandparent -> Root` when direct high-level wiring is clearer.
- Keep important gameplay events visible near the coordinator.

Good:

```gdscript
signal died
signal health_changed(current: int, max_value: int)
```

Bad:

```gdscript
signal update_ui_and_play_damage_flash
```

### Async And Lifetime Safety

- Check `is_instance_valid(node)` before using stored node references after `await`.
- Use `queue_free()` for nodes unless there is a specific low-level reason to call `free()`.

Bad:

```gdscript
var enemy := %Enemy
enemy.stun()

await get_tree().create_timer(1.0).timeout

enemy.die()
```

Good:

```gdscript
var enemy := %Enemy
enemy.stun()

await get_tree().create_timer(1.0).timeout

if is_instance_valid(enemy):
	enemy.die()
```

### Frame Safety

- Do not run long blocking work inside `_process`, `_physics_process`, `_input`, or signal callbacks.
- Split long work across frames when needed.

```gdscript
await get_tree().process_frame
```

### Rewrite Triggers

- If code depends on long node paths or parent chains, rewrite it using `%UniqueNodeName`, `@export` references, groups, or signals.
- If one script owns unrelated systems, split behavior into focused components.
- If unrelated scene branches call each other directly, prefer signals, groups, or explicit coordinator wiring.
- If a stored node reference is used after `await`, validate it before use.

## Commit Messages

- Use Conventional Commits when asked to create or suggest a commit message.
- Format: `type(scope): summary`.
- Common types: `feat`, `fix`, `refactor`, `perf`, `chore`, `docs`, `style`, `test`.
- Use imperative mood and describe the logical intent, not the sequence of edits.
- Prefer concise, project-relevant scopes such as `scene`, `input`, `ui`, `player`, `config`, or `docs`.

Good:

```text
feat(player): add movement component
fix(scene): keep enemy reference valid after await
refactor(input): split interaction handling
chore(config): normalize text file settings
```

Bad:

```text
feat: update stuff
fix: fix bug
chore: changes
```
