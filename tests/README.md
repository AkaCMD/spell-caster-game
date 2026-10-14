# Gameplay integration check

Run with Godot 4.7 (use the installed editor's full path if `godot` is not on `PATH`):

```sh
godot --headless --path . --fixed-fps 60 --script res://tests/grid_spell_integration.gd
```

This loads the real main scene and exercises walking, input buffering, pushing,
spell validation/execution/cancellation, reset, and two playable solutions.
Failed assertions produce a nonzero exit status.

Godot 4.7.2's headless audio playback can report audio resources still in use at
shutdown. The same warning reproduces on the original prototype; gameplay
assertions are reported separately as `checks` and `failures`.
