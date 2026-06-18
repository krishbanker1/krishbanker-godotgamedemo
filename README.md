# TerraForge — Godot/Xogot Voxel Survival Prototype

TerraForge is an original Godot 4.x / GDScript-only voxel survival crafting prototype designed to open directly from this repository in Godot or Xogot.

The project is being built in three phases. Phase 1 is now a data-driven foundation instead of a tiny block demo.

## Current Phase 1 systems

- `project.godot` at the repo root
- Main scene: `scenes/main.tscn`
- First-person player: `scripts/player.gd`
- Runtime voxel world generator: `scripts/world.gd`
- Original block/item/recipe/biome/mob registry: `scripts/game_registry.gd`
- Inventory data model: `scripts/inventory_data.gd`
- Crafting and smelting system: `scripts/crafting_system.gd`
- Runtime HUD: `scripts/hud.gd`
- iPhone-friendly on-screen controls: `scripts/mobile_controls.gd`
- Multiple original terrain zones: Greenreach Meadow, Frostvale, Sunglass Dunes, Ashen Flats
- Original resources: Charshard, Ferrite, Aurum, Aether Crystal, Embercore
- Mining drops, placing from inventory, hotbar selection, starter crafting, starter smelting

## Desktop controls

- `WASD` or arrow keys: move
- Mouse: look
- Left click: break block
- Right click: place selected block
- Space: jump
- `1` to `8`: select hotbar slot
- `Tab`: next hotbar slot
- `C`: craft the first available starter recipe
- `F`: smelt the first available smeltable resource
- `Q` / `E`: turn camera as a keyboard fallback
- Esc: release mouse

## iPhone / Xogot controls

- `W`, `A`, `S`, `D` buttons: move
- `<` and `>` buttons: turn
- `Jump`: jump
- `Break`: break the block under the crosshair
- `Place`: place the selected hotbar block beside the targeted block
- `Prev` / `Next`: switch hotbar slot
- `Craft`: craft the first available starter recipe
- `Smelt`: smelt the first available resource if fuel exists

## First test checklist

1. Open the project from the repository in Xogot/Godot.
2. Run `scenes/main.tscn`.
3. Confirm the player spawns above the terrain.
4. Move around and verify collision with blocks.
5. Switch hotbar using `Prev` / `Next` or number keys.
6. Aim at a block and press `Break`.
7. Confirm the HUD inventory text updates.
8. Press `Place` with a block selected.
9. Press `Craft` after collecting logs/stone/charshard.
10. Press `Smelt` after collecting raw Ferrite/Aurum or sand and Charshard.

## Roadmap

See `docs/THREE_PHASE_PLAN.md` for the full three-phase build plan.
