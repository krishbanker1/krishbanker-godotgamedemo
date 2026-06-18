# TerraForge — Godot/Xogot Voxel Survival Game

TerraForge is an original Godot 4.x / GDScript-only voxel survival crafting game designed to open directly from this repository in Godot or Xogot.

This repo now contains a one-download vertical slice: world, mining, placing, inventory, hotbar, crafting, smelting, food, health, stamina, day/night, mobs, drops, pickups, save/load, mobile controls, and a cleaner UI.

## Main files

- `project.godot` at the repo root
- Main scene: `scenes/main.tscn`
- Player/survival systems: `scripts/player.gd`
- Voxel world generation: `scripts/world.gd`
- Content registry: `scripts/game_registry.gd`
- Inventory model: `scripts/inventory_data.gd`
- Crafting/smelting: `scripts/crafting_system.gd`
- HUD, hotbar, inventory, crafting panels: `scripts/hud.gd`
- Mobile controls: `scripts/mobile_controls.gd`
- Mobs: `scripts/mob.gd`
- Pickups: `scripts/pickup.gd`
- Day/night and spawning: `scripts/game_manager.gd`

## Included gameplay

- Four terrain zones: Greenreach Meadow, Frostvale, Sunglass Dunes, Ashen Flats, plus Craglands variation
- Blocks: turf, soil, stone, deepstone, sand, clay, frostmoss, ash soil, logs, leaves, planks, glass, workbench, kiln, crate, farm plot, glow core, beacon core
- Ores/resources: Charshard, Ferrite, Aurum, Aether Crystal, Embercore, Void Shard
- Tools/weapons/armor: wood/stone/ferrite/aether picks, blades, basic ferrite armor
- Crafting recipes and smelting recipes
- Mining drops spawn as pickup cubes
- Passive and hostile mobs with simple AI
- Health, hunger, stamina, food, damage, collapse state
- Day/night lighting and mob spawning
- Save/load using `user://terraforge_save.json`
- Touch-first HUD: cleaner buttons, hotbar, inventory panel, crafting panel, smelting panel

## Desktop controls

- `WASD` or arrow keys: move
- Mouse: look
- Left click: mine/hit
- Right click: place selected block
- Space: jump
- `1` to `9`: select hotbar slot
- `Tab`: next hotbar slot
- `I`: inventory
- `E`: interact with targeted workbench/kiln/crate/beacon
- `C`: craft first available recipe
- `F`: smelt first available item
- `R`: eat selected food
- `P`: save
- `L`: load
- Esc: release mouse

## iPhone / Xogot controls

- Left cluster: move and jump
- Right cluster: look, mine/hit, place, previous/next hotbar, bag, craft, eat, save, load
- Center bottom: 9-slot hotbar with selected slot highlight
- Inventory and crafting panels open over the world

## First test checklist

1. Delete the old Xogot import if needed.
2. Download/import the latest GitHub repo again.
3. Open the folder that contains `project.godot`.
4. Run `scenes/main.tscn`.
5. Move, jump, turn, mine a block, collect pickup, place a block.
6. Open Bag, switch hotbar, craft, eat, save, load.
7. Find mobs and test combat.
8. Try to craft the Aether Beacon as the current vertical-slice goal.

## Important

This is a one-go playable vertical slice, not a finished commercial game. If Xogot shows a red script error, send the screenshot and the next patch can be a single bugfix download.
