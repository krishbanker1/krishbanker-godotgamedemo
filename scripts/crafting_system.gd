extends RefCounted
class_name CraftingSystem

static func try_craft(inventory: InventoryData, recipe_id: String) -> String:
	var recipe := GameRegistry.get_recipe(recipe_id)
	if recipe.is_empty():
		return ""
	var cost: Dictionary = recipe.get("cost", {})
	var output: Dictionary = recipe.get("output", {})
	if output.is_empty():
		return ""
	if not inventory.has_items(cost):
		return ""
	inventory.remove_items(cost)
	inventory.add_items(output)
	var names: Array[String] = []
	for item_id in output.keys():
		names.append("%s x%s" % [GameRegistry.item_name(str(item_id)), int(output[item_id])])
	return ", ".join(names)

static func try_smelting(inventory: InventoryData, input_id: String) -> String:
	var smelting := GameRegistry.get_smelting(input_id)
	if smelting.is_empty():
		return ""
	var fuel_id := str(smelting.get("fuel", "charshard"))
	if not inventory.has_item(input_id, 1):
		return ""
	if not inventory.has_item(fuel_id, 1):
		return ""
	inventory.remove_item(input_id, 1)
	inventory.remove_item(fuel_id, 1)
	var output: Dictionary = smelting.get("output", {})
	inventory.add_items(output)
	var names: Array[String] = []
	for item_id in output.keys():
		names.append("%s x%s" % [GameRegistry.item_name(str(item_id)), int(output[item_id])])
	return ", ".join(names)

static func first_craftable_recipe(inventory: InventoryData, recipe_ids: Array[String]) -> String:
	for recipe_id in recipe_ids:
		var recipe := GameRegistry.get_recipe(recipe_id)
		if not recipe.is_empty() and inventory.has_items(recipe.get("cost", {})):
			return recipe_id
	return ""
