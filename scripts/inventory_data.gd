extends RefCounted
class_name InventoryData

const MAX_DISPLAY_ITEMS := 7

var items: Dictionary = {}

func add_item(item_id: String, amount: int = 1) -> int:
	if item_id == "" or amount <= 0:
		return 0
	var limit := GameRegistry.item_stack_limit(item_id)
	var current := get_count(item_id)
	var new_total := current + amount
	items[item_id] = new_total
	return min(amount, max(0, limit * 99 - current))

func remove_item(item_id: String, amount: int = 1) -> bool:
	if amount <= 0:
		return true
	if get_count(item_id) < amount:
		return false
	items[item_id] = get_count(item_id) - amount
	if int(items[item_id]) <= 0:
		items.erase(item_id)
	return true

func has_item(item_id: String, amount: int = 1) -> bool:
	return get_count(item_id) >= amount

func get_count(item_id: String) -> int:
	return int(items.get(item_id, 0))

func has_items(cost: Dictionary) -> bool:
	for item_id in cost.keys():
		if get_count(str(item_id)) < int(cost[item_id]):
			return false
	return true

func remove_items(cost: Dictionary) -> bool:
	if not has_items(cost):
		return false
	for item_id in cost.keys():
		remove_item(str(item_id), int(cost[item_id]))
	return true

func add_items(output: Dictionary) -> void:
	for item_id in output.keys():
		add_item(str(item_id), int(output[item_id]))

func first_available_from(list: Array) -> String:
	for item_id in list:
		if get_count(str(item_id)) > 0:
			return str(item_id)
	return ""

func summary(max_items: int = MAX_DISPLAY_ITEMS) -> String:
	if items.is_empty():
		return "Inventory empty"
	var parts: Array[String] = []
	var shown := 0
	for item_id in items.keys():
		parts.append("%s x%s" % [GameRegistry.item_name(str(item_id)), get_count(str(item_id))])
		shown += 1
		if shown >= max_items:
			break
	if items.size() > max_items:
		parts.append("+%s more" % [items.size() - max_items])
	return ", ".join(parts)
