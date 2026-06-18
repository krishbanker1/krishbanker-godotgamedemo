# Xogot Voxel Prototype

A small Godot 4.x / GDScript-only Minecraft-style voxel prototype designed to open directly from the repository in Godot or Xogot.

## What is included

- `project.godot` at the repo root
- Main scene: `scenes/main.tscn`
- First-person player: `scripts/player.gd`
- Runtime voxel world generator: `scripts/world.gd`
- Simple iPhone-friendly on-screen controls: `scripts/mobile_controls.gd`
- Grass, dirt, and stone blocks
- Block breaking and placing through a camera raycast

## Desktop controls

- `WASD` or arrow keys: move
- Mouse: look
- Left click: break block
- Right click: place grass block
- Space: jump
- `Q` / `E`: turn camera as a keyboard fallback
- Esc: release mouse

## iPhone / Xogot controls

- `W`, `A`, `S`, `D` buttons: move
- `<` and `>` buttons: turn
- `Break`: break the block under the crosshair
- `Place`: place a grass block beside the targeted block

## First test checklist

1. Open the project from the repository.
2. Run `scenes/main.tscn`.
3. Confirm the player spawns above a small block world.
4. Move around and verify collision with blocks.
5. Aim the crosshair at a block and press Break.
6. Aim at an existing block and press Place.
