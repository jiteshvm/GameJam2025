GameJam2025
================

Engine: Godot 4.5.1 (Forward+)
Executable: `C:\GodotEngine\Godot_v4.5.1-stable_win64.exe`
Language: GDScript

Getting Started
- Install Git and Git LFS (one-time): `git lfs install`
- Clone the repo, then open the folder in Godot (`Project Manager → Import` or run the executable with `--editor --path <repo>`).
- Main scene: `scenes/Main.tscn`.

Project Layout
- `assets/` — art, audio, video, fonts, 3D models (tracked by Git LFS)
- `scenes/` — `.tscn` scene files
- `scripts/` — `.gd` scripts
- `addons/` — optional plugins
- `export/` — build artifacts (ignored)

Notes
- `.godot/` and `.import/` are ignored; text resources use LF endings.
- If you’re on Windows, ensure your editor is configured for LF on project files.
- After cloning, each teammate should run `git lfs install` once on their machine.


Manual
- Quick Start: docs/Manual/QuickStart.md
- Daily Flow: docs/Manual/DailyFlow.md
