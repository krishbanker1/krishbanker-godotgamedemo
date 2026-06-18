extends RefCounted
class_name GameRegistry

# TerraForge is an original voxel survival sandbox registry.
# Every block/item/recipe is data-driven so later phases can add content without rewriting core code.

const AIR := "air"

const BLOCKS := {
	"air": {"name": "Air", "item": "", "drop": "", "hardness": 0.0, "solid": false, "color": [0.0, 0.0, 0.0]},
	"grass_turf": {"name": "Turfgrass", "item": "grass_turf", "drop": "grass_turf", "hardness": 0.55, "solid": true, "color": [0.28, 0.74, 0.24]},
	"soil": {"name": "Soft Soil", "item": "soil", "drop": "soil", "hardness": 0.45, "solid": true, "color": [0.45, 0.30, 0.16]},
	"stone": {"name": "Fieldstone", "item": "stone", "drop": "stone", "hardness": 1.2, "solid": true, "color": [0.48, 0.48, 0.52]},
	"sand": {"name": "Sun Sand", "item": "sand", "drop": "sand", "hardness": 0.35, "solid": true, "color": [0.88, 0.76, 0.45]},
	"frost_moss": {"name": "Frostmoss", "item": "frost_moss", "drop": "frost_moss", "hardness": 0.6, "solid": true, "color": [0.55, 0.78, 0.76]},
	"ash_soil": {"name": "Ashen Soil", "item": "ash_soil", "drop": "ash_soil", "hardness": 0.55, "solid": true, "color": [0.25, 0.23, 0.23]},
	"oak_log": {"name": "Ridgewood Log", "item": "oak_log", "drop": "oak_log", "hardness": 0.9, "solid": true, "color": [0.50, 0.30, 0.14]},
	"leaf_block": {"name": "Ridgeleaf", "item": "leaf_block", "drop": "leaf_block", "hardness": 0.25, "solid": true, "color": [0.20, 0.56, 0.20]},
	"plank_block": {"name": "Ridgewood Planks", "item": "plank_block", "drop": "plank_block", "hardness": 0.8, "solid": true, "color": [0.63, 0.42, 0.20]},
	"glass_block": {"name": "Clearstone Glass", "item": "glass_block", "drop": "glass_block", "hardness": 0.3, "solid": true, "color": [0.70, 0.90, 0.95]},
	"charshard_ore": {"name": "Charshard Ore", "item": "charshard_ore", "drop": "charshard", "hardness": 1.1, "solid": true, "color": [0.12, 0.10, 0.09]},
	"ferrite_ore": {"name": "Ferrite Ore", "item": "ferrite_ore", "drop": "ferrite_ore", "hardness": 1.4, "solid": true, "color": [0.58, 0.44, 0.35]},
	"aurum_ore": {"name": "Aurum Ore", "item": "aurum_ore", "drop": "aurum_ore", "hardness": 1.7, "solid": true, "color": [0.92, 0.68, 0.22]},
	"aether_crystal_ore": {"name": "Aether Crystal Ore", "item": "aether_crystal_ore", "drop": "aether_crystal", "hardness": 2.1, "solid": true, "color": [0.45, 0.80, 1.00]},
	"embercore_ore": {"name": "Embercore Ore", "item": "embercore_ore", "drop": "embercore", "hardness": 2.4, "solid": true, "color": [1.00, 0.32, 0.12]},
	"charshard_torch": {"name": "Charshard Torch", "item": "charshard_torch", "drop": "charshard_torch", "hardness": 0.2, "solid": true, "color": [1.00, 0.70, 0.20]},
	"workbench": {"name": "Maker Bench", "item": "workbench", "drop": "workbench", "hardness": 0.9, "solid": true, "color": [0.52, 0.32, 0.18]},
	"kiln": {"name": "Stone Kiln", "item": "kiln", "drop": "kiln", "hardness": 1.3, "solid": true, "color": [0.36, 0.35, 0.34]}
}

const ITEMS := {
	"grass_turf": {"name": "Turfgrass Block", "stack": 99, "place_block": "grass_turf"},
	"soil": {"name": "Soft Soil Block", "stack": 99, "place_block": "soil"},
	"stone": {"name": "Fieldstone Block", "stack": 99, "place_block": "stone"},
	"sand": {"name": "Sun Sand Block", "stack": 99, "place_block": "sand"},
	"frost_moss": {"name": "Frostmoss Block", "stack": 99, "place_block": "frost_moss"},
	"ash_soil": {"name": "Ashen Soil Block", "stack": 99, "place_block": "ash_soil"},
	"oak_log": {"name": "Ridgewood Log", "stack": 99, "place_block": "oak_log"},
	"leaf_block": {"name": "Ridgeleaf Block", "stack": 99, "place_block": "leaf_block"},
	"plank_block": {"name": "Ridgewood Planks", "stack": 99, "place_block": "plank_block"},
	"glass_block": {"name": "Clearstone Glass", "stack": 99, "place_block": "glass_block"},
	"charshard": {"name": "Charshard", "stack": 99},
	"ferrite_ore": {"name": "Raw Ferrite", "stack": 99},
	"ferrite_ingot": {"name": "Ferrite Ingot", "stack": 99},
	"aurum_ore": {"name": "Raw Aurum", "stack": 99},
	"aurum_ingot": {"name": "Aurum Ingot", "stack": 99},
	"aether_crystal": {"name": "Aether Crystal", "stack": 99},
	"embercore": {"name": "Embercore", "stack": 99},
	"stick_bundle": {"name": "Stick Bundle", "stack": 99},
	"wood_pick": {"name": "Ridgewood Pick", "stack": 1},
	"stone_pick": {"name": "Fieldstone Pick", "stack": 1},
	"ferrite_pick": {"name": "Ferrite Pick", "stack": 1},
	"aether_blade": {"name": "Aether Blade", "stack": 1},
	"charshard_torch": {"name": "Charshard Torch", "stack": 99, "place_block": "charshard_torch"},
	"workbench": {"name": "Maker Bench", "stack": 8, "place_block": "workbench"},
	"kiln": {"name": "Stone Kiln", "stack": 8, "place_block": "kiln"}
}

const RECIPES := {
	"plank_block_from_log": {"name": "Saw Ridgewood Planks", "cost": {"oak_log": 1}, "output": {"plank_block": 4}},
	"stick_bundle": {"name": "Bind Stick Bundle", "cost": {"plank_block": 2}, "output": {"stick_bundle": 4}},
	"workbench": {"name": "Maker Bench", "cost": {"plank_block": 4}, "output": {"workbench": 1}},
	"charshard_torch": {"name": "Charshard Torch", "cost": {"stick_bundle": 1, "charshard": 1}, "output": {"charshard_torch": 4}},
	"kiln": {"name": "Stone Kiln", "cost": {"stone": 8}, "output": {"kiln": 1}},
	"wood_pick": {"name": "Ridgewood Pick", "cost": {"stick_bundle": 2, "plank_block": 3}, "output": {"wood_pick": 1}},
	"stone_pick": {"name": "Fieldstone Pick", "cost": {"stick_bundle": 2, "stone": 3}, "output": {"stone_pick": 1}}
}

const SMELTING := {
	"ferrite_ore": {"fuel": "charshard", "output": {"ferrite_ingot": 1}},
	"aurum_ore": {"fuel": "charshard", "output": {"aurum_ingot": 1}},
	"sand": {"fuel": "charshard", "output": {"glass_block": 1}}
}

const BIOMES := {
	"meadow": {"name": "Greenreach Meadow", "surface": "grass_turf", "subsoil": "soil", "tree": true},
	"frostvale": {"name": "Frostvale", "surface": "frost_moss", "subsoil": "soil", "tree": true},
	"dunes": {"name": "Sunglass Dunes", "surface": "sand", "subsoil": "sand", "tree": false},
	"ashland": {"name": "Ashen Flats", "surface": "ash_soil", "subsoil": "ash_soil", "tree": false}
}

const MOBS := {
	"grazer": {"name": "Grazer", "role": "passive", "health": 8, "drop": "soil"},
	"mudsnout": {"name": "Mudsnout", "role": "passive", "health": 10, "drop": "oak_log"},
	"ashling": {"name": "Ashling", "role": "hostile", "health": 12, "drop": "charshard"},
	"boneguard": {"name": "Boneguard", "role": "hostile", "health": 16, "drop": "ferrite_ore"},
	"voidstalker": {"name": "Voidstalker", "role": "elite", "health": 26, "drop": "aether_crystal"}
}

static func get_block(block_id: String) -> Dictionary:
	return BLOCKS.get(block_id, BLOCKS["air"])

static func get_item(item_id: String) -> Dictionary:
	return ITEMS.get(item_id, {})

static func get_recipe(recipe_id: String) -> Dictionary:
	return RECIPES.get(recipe_id, {})

static func get_smelting(input_id: String) -> Dictionary:
	return SMELTING.get(input_id, {})

static func block_name(block_id: String) -> String:
	return str(get_block(block_id).get("name", block_id))

static func item_name(item_id: String) -> String:
	return str(get_item(item_id).get("name", item_id))

static func block_drop(block_id: String) -> String:
	return str(get_block(block_id).get("drop", ""))

static func block_color(block_id: String) -> Color:
	var color_array: Array = get_block(block_id).get("color", [1.0, 0.0, 1.0])
	return Color(float(color_array[0]), float(color_array[1]), float(color_array[2]))

static func is_placeable_item(item_id: String) -> bool:
	return get_item(item_id).has("place_block")

static func item_place_block(item_id: String) -> String:
	return str(get_item(item_id).get("place_block", ""))

static func item_stack_limit(item_id: String) -> int:
	return int(get_item(item_id).get("stack", 99))

static func biome_at(world_x: int, world_z: int) -> String:
	if world_z < 7:
		return "frostvale"
	if world_x > 17:
		return "ashland"
	if world_z > 18:
		return "dunes"
	return "meadow"

static func biome_surface(biome_id: String) -> String:
	return str(BIOMES.get(biome_id, BIOMES["meadow"]).get("surface", "grass_turf"))

static func biome_subsoil(biome_id: String) -> String:
	return str(BIOMES.get(biome_id, BIOMES["meadow"]).get("subsoil", "soil"))

static func biome_allows_trees(biome_id: String) -> bool:
	return bool(BIOMES.get(biome_id, BIOMES["meadow"]).get("tree", false))
