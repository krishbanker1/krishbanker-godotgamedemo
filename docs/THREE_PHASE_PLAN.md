# TerraForge three-phase build plan

TerraForge is an original voxel survival crafting game for Godot 4.x / Xogot. It uses original block, item, mob, ore, biome, recipe, and progression names.

## Phase 1 — Core survival foundation

Status: implemented in code.

Goal: make the current demo into a data-driven playable survival base.

Included:

- Original block registry
- Original item registry
- Original crafting recipe registry
- Original smelting registry
- Original biome registry
- Original mob-data registry placeholder
- Inventory data model
- Crafting/smelting system
- Expanded world generation with biomes, ore distribution, trees, and utility blocks
- Hotbar selection
- Starter inventory
- Mining drops
- Placing blocks from inventory
- On-screen HUD
- Mobile buttons for movement, turning, jumping, breaking, placing, crafting, smelting, and hotbar switching

## Phase 2 — Real gameplay loop

Goal: make survival systems feel like a real playable game.

Planned:

- Health and stamina
- Tool tiers and mining speed
- Block hardness enforcement
- Workbench UI foundation
- Kiln UI foundation
- Chest/storage block
- Pickups instead of instant collection only
- Save/load for world and inventory
- Better terrain layering
- Cave pockets
- Custom liquid-style block
- More recipes and smelting paths
- First passive mob implementation
- First hostile mob implementation

## Phase 3 — Complete playable vertical slice

Goal: all major systems needed for a complete original voxel survival prototype should work together.

Planned:

- Multiple working biomes
- More ore progression
- Tool, weapon, and armor progression
- Farming loop
- Tree regrowth/resources
- Mob spawning by biome/time
- Passive and hostile AI
- Combat and drops
- Structure/ruin generation
- Day/night cycle
- Save/load polish
- Mobile UI polish
- In-game guide/help screen
- Basic progression goal using Aether Crystal and Embercore systems

## Acceptance rule for Phase 3

By the end of Phase 3, the project should open in Godot/Xogot, run `scenes/main.tscn`, allow the player to survive, mine, craft, smelt, fight mobs, gather resources, progress tools, explore biomes, and save/load a playable world without needing desktop-only tooling.
