extends RefCounted
class_name GameRegistry

# TerraForge content registry.
# Original voxel survival sandbox data: blocks, items, recipes, tools, mobs, biomes, loot.

const AIR := "air"

const BLOCKS := {
	"air": {"name": "Air", "item": "", "drop": "", "hardness": 0.0, "solid": false, "color": [0.0, 0.0, 0.0]},
	"grass_turf": {"name": "Turfgrass", "item": "grass_turf", "drop": "grass_turf", "hardness": 0.55, "solid": true, "color": [0.30, 0.72, 0.25]},
	"soil": {"name": "Soft Soil", "item": "soil", "drop": "soil", "hardness": 0.45, "solid": true, "color": [0.42, 0.27, 0.15]},
	"stone": {"name": "Fieldstone", "item": "stone", "drop": "stone", "hardness": 1.2, "solid": true, "color": [0.50, 0.50, 0.54]},
	"deepstone": {"name": "Deepstone", "item": "deepstone", "drop": "deepstone", "hardness": 1.8, "solid": true, "color": [0.24, 0.24, 0.30]},
	"sand": {"name": "Sun Sand", "item": "sand", "drop": "sand", "hardness": 0.35, "solid": true, "color": [0.88, 0.76, 0.45]},
	"clay": {"name": "River Clay", "item": "clay", "drop": "clay", "hardness": 0.65, "solid": true, "color": [0.48, 0.42, 0.37]},
	"frost_moss": {"name": "Frostmoss", "item": "frost_moss", "drop": "frost_moss", "hardness": 0.6, "solid": true, "color": [0.58, 0.82, 0.78]},
	"ash_soil": {"name": "Ashen Soil", "item": "ash_soil", "drop": "ash_soil", "hardness": 0.55, "solid": true, "color": [0.24, 0.22, 0.22]},
	"crag_grass": {"name": "Craggrass", "item": "crag_grass", "drop": "crag_grass", "hardness": 0.7, "solid": true, "color": [0.34, 0.52, 0.32]},
	"oak_log": {"name": "Ridgewood Log", "item": "oak_log", "drop": "oak_log", "hardness": 0.9, "solid": true, "color": [0.50, 0.30, 0.14]},
	"leaf_block": {"name": "Ridgeleaf", "item": "leaf_block", "drop": "fiber_leaf", "hardness": 0.25, "solid": true, "color": [0.18, 0.55, 0.20]},
	"plank_block": {"name": "Ridgewood Planks", "item": "plank_block", "drop": "plank_block", "hardness": 0.8, "solid": true, "color": [0.63, 0.42, 0.20]},
	"glass_block": {"name": "Clearstone Glass", "item": "glass_block", "drop": "glass_block", "hardness": 0.3, "solid": true, "color": [0.70, 0.90, 0.95]},
	"charshard_ore": {"name": "Charshard Ore", "item": "charshard_ore", "drop": "charshard", "hardness": 1.1, "solid": true, "color": [0.10, 0.09, 0.08]},
	"ferrite_ore": {"name": "Ferrite Ore", "item": "ferrite_ore", "drop": "ferrite_ore", "hardness": 1.4, "solid": true, "color": [0.58, 0.44, 0.35]},
	"aurum_ore": {"name": "Aurum Ore", "item": "aurum_ore", "drop": "aurum_ore", "hardness": 1.7, "solid": true, "color": [0.92, 0.68, 0.22]},
	"aether_crystal_ore": {"name": "Aether Crystal Ore", "item": "aether_crystal_ore", "drop": "aether_crystal", "hardness": 2.1, "solid": true, "color": [0.45, 0.80, 1.00]},
	"embercore_ore": {"name": "Embercore Ore", "item": "embercore_ore", "drop": "embercore", "hardness": 2.4, "solid": true, "color": [1.00, 0.32, 0.12]},
	"voidstone_ore": {"name": "Voidstone Ore", "item": "voidstone_ore", "drop": "void_shard", "hardness": 3.0, "solid": true, "color": [0.20, 0.08, 0.32]},
	"charshard_torch": {"name": "Charshard Torch", "item": "charshard_torch", "drop": "charshard_torch", "hardness": 0.2, "solid": true, "color": [1.00, 0.70, 0.20]},
	"workbench": {"name": "Maker Bench", "item": "workbench", "drop": "workbench", "hardness": 0.9, "solid": true, "color": [0.52, 0.32, 0.18]},
	"kiln": {"name": "Stone Kiln", "item": "kiln", "drop": "kiln", "hardness": 1.3, "solid": true, "color": [0.36, 0.35, 0.34]},
	"chest": {"name": "Supply Crate", "item": "chest", "drop": "chest", "hardness": 0.9, "solid": true, "color": [0.57, 0.36, 0.16]},
	"farm_plot": {"name": "Tilled Plot", "item": "farm_plot", "drop": "soil", "hardness": 0.45, "solid": true, "color": [0.30, 0.18, 0.10]},
	"glow_core": {"name": "Glow Core", "item": "glow_core", "drop": "glow_core", "hardness": 1.0, "solid": true, "color": [0.90, 0.90, 0.28]},
	"beacon_core": {"name": "Aether Beacon", "item": "beacon_core", "drop": "beacon_core", "hardness": 2.2, "solid": true, "color": [0.35, 0.95, 1.0]}
}

const ITEMS := {
	"grass_turf": {"name": "Turfgrass Block", "stack": 99, "place_block": "grass_turf"},
	"soil": {"name": "Soft Soil Block", "stack": 99, "place_block": "soil"},
	"stone": {"name": "Fieldstone Block", "stack": 99, "place_block": "stone"},
	"deepstone": {"name": "Deepstone Block", "stack": 99, "place_block": "deepstone"},
	"sand": {"name": "Sun Sand Block", "stack": 99, "place_block": "sand"},
	"clay": {"name": "River Clay", "stack": 99, "place_block": "clay"},
	"frost_moss": {"name": "Frostmoss Block", "stack": 99, "place_block": "frost_moss"},
	"ash_soil": {"name": "Ashen Soil Block", "stack": 99, "place_block": "ash_soil"},
	"crag_grass": {"name": "Craggrass Block", "stack": 99, "place_block": "crag_grass"},
	"oak_log": {"name": "Ridgewood Log", "stack": 99, "place_block": "oak_log"},
	"leaf_block": {"name": "Ridgeleaf Block", "stack": 99, "place_block": "leaf_block"},
	"fiber_leaf": {"name": "Leaf Fiber", "stack": 99},
	"plank_block": {"name": "Ridgewood Planks", "stack": 99, "place_block": "plank_block"},
	"glass_block": {"name": "Clearstone Glass", "stack": 99, "place_block": "glass_block"},
	"charshard": {"name": "Charshard", "stack": 99},
	"ferrite_ore": {"name": "Raw Ferrite", "stack": 99},
	"ferrite_ingot": {"name": "Ferrite Ingot", "stack": 99},
	"aurum_ore": {"name": "Raw Aurum", "stack": 99},
	"aurum_ingot": {"name": "Aurum Ingot", "stack": 99},
	"aether_crystal": {"name": "Aether Crystal", "stack": 99},
	"embercore": {"name": "Embercore", "stack": 99},
	"void_shard": {"name": "Void Shard", "stack": 99},
	"stick_bundle": {"name": "Stick Bundle", "stack": 99},
	"wild_seed": {"name": "Wild Seed", "stack": 99},
	"berry": {"name": "Glowberry", "stack": 99, "food": 14},
	"mush_meat": {"name": "Mush Meat", "stack": 99, "food": 22},
	"wood_pick": {"name": "Ridgewood Pick", "stack": 1, "tool": 1},
	"stone_pick": {"name": "Fieldstone Pick", "stack": 1, "tool": 2},
	"ferrite_pick": {"name": "Ferrite Pick", "stack": 1, "tool": 3},
	"aether_pick": {"name": "Aether Pick", "stack": 1, "tool": 4},
	"wood_sword": {"name": "Ridgewood Blade", "stack": 1, "weapon": 4},
	"ferrite_sword": {"name": "Ferrite Blade", "stack": 1, "weapon": 8},
	"aether_blade": {"name": "Aether Blade", "stack": 1, "weapon": 14},
	"ferrite_helm": {"name": "Ferrite Helm", "stack": 1, "armor": 2},
	"ferrite_chest": {"name": "Ferrite Guard", "stack": 1, "armor": 4},
	"charshard_torch": {"name": "Charshard Torch", "stack": 99, "place_block": "charshard_torch"},
	"workbench": {"name": "Maker Bench", "stack": 8, "place_block": "workbench"},
	"kiln": {"name": "Stone Kiln", "stack": 8, "place_block": "kiln"},
	"chest": {"name": "Supply Crate", "stack": 8, "place_block": "chest"},
	"farm_plot": {"name": "Tilled Plot", "stack": 32, "place_block": "farm_plot"},
	"glow_core": {"name": "Glow Core", "stack": 16, "place_block": "glow_core"},
	"beacon_core": {"name": "Aether Beacon", "stack": 1, "place_block": "beacon_core"}
}

const RECIPES := {
	"plank_block_from_log": {"name": "Saw Ridgewood Planks", "cost": {"oak_log": 1}, "output": {"plank_block": 4}},
	"stick_bundle": {"name": "Bind Stick Bundle", "cost": {"plank_block": 2}, "output": {"stick_bundle": 4}},
	"workbench": {"name": "Maker Bench", "cost": {"plank_block": 4}, "output": {"workbench": 1}},
	"charshard_torch": {"name": "Charshard Torch", "cost": {"stick_bundle": 1, "charshard": 1}, "output": {"charshard_torch": 4}},
	"kiln": {"name": "Stone Kiln", "cost": {"stone": 8}, "output": {"kiln": 1}},
	"chest": {"name": "Supply Crate", "cost": {"plank_block": 8}, "output": {"chest": 1}},
	"farm_plot": {"name": "Tilled Plot", "cost": {"soil": 2, "fiber_leaf": 1}, "output": {"farm_plot": 2}},
	"wood_pick": {"name": "Ridgewood Pick", "cost": {"stick_bundle": 2, "plank_block": 3}, "output": {"wood_pick": 1}},
	"stone_pick": {"name": "Fieldstone Pick", "cost": {"stick_bundle": 2, "stone": 3}, "output": {"stone_pick": 1}},
	"ferrite_pick": {"name": "Ferrite Pick", "cost": {"stick_bundle": 2, "ferrite_ingot": 3}, "output": {"ferrite_pick": 1}},
	"aether_pick": {"name": "Aether Pick", "cost": {"stick_bundle": 2, "aether_crystal": 2, "ferrite_ingot": 2}, "output": {"aether_pick": 1}},
	"wood_sword": {"name": "Ridgewood Blade", "cost": {"stick_bundle": 1, "plank_block": 2}, "output": {"wood_sword": 1}},
	"ferrite_sword": {"name": "Ferrite Blade", "cost": {"stick_bundle": 1, "ferrite_ingot": 2}, "output": {"ferrite_sword": 1}},
	"aether_blade": {"name": "Aether Blade", "cost": {"stick_bundle": 1, "aether_crystal": 2, "aurum_ingot": 1}, "output": {"aether_blade": 1}},
	"ferrite_helm": {"name": "Ferrite Helm", "cost": {"ferrite_ingot": 4}, "output": {"ferrite_helm": 1}},
	"ferrite_chest": {"name": "Ferrite Guard", "cost": {"ferrite_ingot": 7}, "output": {"ferrite_chest": 1}},
	"glow_core": {"name": "Glow Core", "cost": {"aether_crystal": 1, "charshard": 4, "glass_block": 2}, "output": {"glow_core": 1}},
	"beacon_core": {"name": "Aether Beacon", "cost": {"glow_core": 2, "embercore": 2, "void_shard": 1, "aurum_ingot": 2}, "output": {"beacon_core": 1}}
}

const SMELTING := {
	"ferrite_ore": {"fuel": "charshard", "output": {"ferrite_ingot": 1}},
	"aurum_ore": {"fuel": "charshard", "output": {"aurum_ingot": 1}},
	"sand": {"fuel": "charshard", "output": {"glass_block": 1}},
	"clay": {"fuel": "charshard", "output": {"stone": 1}}
}

const BIOMES := {
	"meadow": {"name": "Greenreach Meadow", "surface": "grass_turf", "subsoil": "soil", "tree": true, "color": [0.32, 0.76, 0.28]},
	"frostvale": {"name": "Frostvale", "surface": "frost_moss", "subsoil": "soil", "tree": true, "color": [0.62, 0.88, 0.85]},
	"dunes": {"name": "Sunglass Dunes", "surface": "sand", "subsoil": "sand", "tree": false, "color": [0.90, 0.78, 0.48]},
	"ashland": {"name": "Ashen Flats", "surface": "ash_soil", "subsoil": "ash_soil", "tree": false, "color": [0.29, 0.27, 0.27]},
	"craglands": {"name": "Craglands", "surface": "crag_grass", "subsoil": "stone", "tree": false, "color": [0.42, 0.55, 0.38]}
}

const MOBS := {
	"grazer": {"name": "Grazer", "role": "passive", "health": 12, "speed": 1.5, "damage": 0, "drop": "berry", "color": [0.65, 0.90, 0.45]},
	"mudsnout": {"name": "Mudsnout", "role": "passive", "health": 16, "speed": 1.2, "damage": 0, "drop": "mush_meat", "color": [0.50, 0.34, 0.20]},
	"ashling": {"name": "Ashling", "role": "hostile", "health": 16, "speed": 2.2, "damage": 9, "drop": "charshard", "color": [0.95, 0.30, 0.12]},
	"boneguard": {"name": "Boneguard", "role": "hostile", "health": 24, "speed": 1.8, "damage": 12, "drop": "ferrite_ore", "color": [0.80, 0.78, 0.66]},
	"voidstalker": {"name": "Voidstalker", "role": "elite", "health": 40, "speed": 2.6, "damage": 18, "drop": "void_shard", "color": [0.20, 0.06, 0.32]}
}

static func get_block(block_id: String) -> Dictionary:
	return BLOCKS.get(block_id, BLOCKS["air"])

static func get_item(item_id: String) -> Dictionary:
	return ITEMS.get(item_id, {})

static func get_recipe(recipe_id: String) -> Dictionary:
	return RECIPES.get(recipe_id, {})

static func get_smelting(input_id: String) -> Dictionary:
	return SMELTING.get(input_id, {})

static func get_mob(mob_id: String) -> Dictionary:
	return MOBS.get(mob_id, MOBS["grazer"])

static func block_name(block_id: String) -> String:
	return str(get_block(block_id).get("name", block_id))

static func item_name(item_id: String) -> String:
	return str(get_item(item_id).get("name", item_id))

static func mob_name(mob_id: String) -> String:
	return str(get_mob(mob_id).get("name", mob_id))

static func block_drop(block_id: String) -> String:
	return str(get_block(block_id).get("drop", ""))

static func block_hardness(block_id: String) -> float:
	return float(get_block(block_id).get("hardness", 1.0))

static func block_color(block_id: String) -> Color:
	var color_array: Array = get_block(block_id).get("color", [1.0, 0.0, 1.0])
	return Color(float(color_array[0]), float(color_array[1]), float(color_array[2]))

static func item_color(item_id: String) -> Color:
	var place := item_place_block(item_id)
	if place != "":
		return block_color(place)
	if item_id.find("ferrite") >= 0:
		return Color(0.75, 0.62, 0.50)
	if item_id.find("aurum") >= 0:
		return Color(1.0, 0.78, 0.20)
	if item_id.find("aether") >= 0:
		return Color(0.40, 0.85, 1.0)
	if item_id.find("ember") >= 0:
		return Color(1.0, 0.30, 0.12)
	if item_id.find("void") >= 0:
		return Color(0.25, 0.08, 0.35)
	return Color(0.86, 0.86, 0.78)

static func is_placeable_item(item_id: String) -> bool:
	return get_item(item_id).has("place_block")

static func item_place_block(item_id: String) -> String:
	return str(get_item(item_id).get("place_block", ""))

static func item_stack_limit(item_id: String) -> int:
	return int(get_item(item_id).get("stack", 99))

static func item_tool_tier(item_id: String) -> int:
	return int(get_item(item_id).get("tool", 0))

static func item_weapon_damage(item_id: String) -> int:
	return int(get_item(item_id).get("weapon", 2))

static func item_food_value(item_id: String) -> int:
	return int(get_item(item_id).get("food", 0))

static func recipe_ids() -> Array[String]:
	var output: Array[String] = []
	for key in RECIPES.keys():
		output.append(str(key))
	return output

static func smelting_ids() -> Array[String]:
	var output: Array[String] = []
	for key in SMELTING.keys():
		output.append(str(key))
	return output

static func biome_at(world_x: int, world_z: int) -> String:
	var ridge := int(abs(sin(float(world_x * 13 + world_z * 7)) * 100.0)) % 5
	if world_z < 9:
		return "frostvale"
	if world_x > 24:
		return "ashland"
	if world_z > 25:
		return "dunes"
	if ridge == 0:
		return "craglands"
	return "meadow"

static func biome_surface(biome_id: String) -> String:
	return str(BIOMES.get(biome_id, BIOMES["meadow"]).get("surface", "grass_turf"))

static func biome_subsoil(biome_id: String) -> String:
	return str(BIOMES.get(biome_id, BIOMES["meadow"]).get("subsoil", "soil"))

static func biome_allows_trees(biome_id: String) -> bool:
	return bool(BIOMES.get(biome_id, BIOMES["meadow"]).get("tree", false))

static func biome_name(biome_id: String) -> String:
	return str(BIOMES.get(biome_id, BIOMES["meadow"]).get("name", biome_id))
