extends CanvasLayer
class_name GameHud

var root: Control
var top_panel: Panel
var bars_label: Label
var status_label: Label
var toast_label: Label
var hotbar_panel: HBoxContainer
var hotbar_slots: Array[Panel] = []
var inventory_panel: Panel
var inventory_grid: GridContainer
var crafting_panel: Panel
var crafting_grid: GridContainer
var smelting_panel: Panel
var smelting_grid: GridContainer
var toast_time: float = 0.0

const SLOT_SIZE := Vector2(56, 54)
const SLOT_GAP := 4

func _ready() -> void:
	_build_ui()
	show_toast("TerraForge loaded")

func _process(delta: float) -> void:
	if toast_time > 0.0:
		toast_time -= delta
		if toast_time <= 0.0 and toast_label != null:
			toast_label.text = ""

func _build_ui() -> void:
	root = Control.new()
	root.name = "HudRoot"
	root.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(root)
	_build_top_status()
	_build_hotbar()
	_build_toast()
	_build_inventory_panel()
	_build_crafting_panel()
	_build_smelting_panel()

func _style_panel(panel: Panel, bg: Color, border: Color = Color(1, 1, 1, 0.18), radius: int = 3) -> void:
	var style: StyleBoxFlat = StyleBoxFlat.new()
	style.bg_color = bg
	style.border_color = border
	style.border_width_left = 2
	style.border_width_right = 2
	style.border_width_top = 2
	style.border_width_bottom = 2
	style.corner_radius_top_left = radius
	style.corner_radius_top_right = radius
	style.corner_radius_bottom_left = radius
	style.corner_radius_bottom_right = radius
	panel.add_theme_stylebox_override("panel", style)

func _style_button(button: Button, bg: Color = Color(0.035, 0.04, 0.045, 0.62), active: bool = false) -> void:
	var normal: StyleBoxFlat = StyleBoxFlat.new()
	normal.bg_color = bg
	normal.border_color = Color(1.0, 0.82, 0.28, 0.58) if active else Color(1, 1, 1, 0.20)
	normal.border_width_left = 2
	normal.border_width_right = 2
	normal.border_width_top = 2
	normal.border_width_bottom = 2
	normal.corner_radius_top_left = 6
	normal.corner_radius_top_right = 6
	normal.corner_radius_bottom_left = 6
	normal.corner_radius_bottom_right = 6
	var pressed: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.20, 0.20, 0.20, 0.88)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("hover", pressed)
	button.add_theme_color_override("font_color", Color(0.96, 0.96, 0.90))
	button.add_theme_font_size_override("font_size", 13)

func _build_top_status() -> void:
	top_panel = Panel.new()
	top_panel.name = "TopStatus"
	top_panel.anchor_left = 0.0
	top_panel.anchor_top = 0.0
	top_panel.anchor_right = 0.0
	top_panel.anchor_bottom = 0.0
	top_panel.offset_left = 16
	top_panel.offset_top = 14
	top_panel.offset_right = 490
	top_panel.offset_bottom = 82
	_style_panel(top_panel, Color(0.01, 0.012, 0.016, 0.48), Color(1, 1, 1, 0.20), 6)
	root.add_child(top_panel)

	bars_label = Label.new()
	bars_label.offset_left = 14
	bars_label.offset_top = 6
	bars_label.offset_right = 470
	bars_label.offset_bottom = 30
	bars_label.text = "HP 100/100   STA 100   HUNGER 100"
	bars_label.add_theme_font_size_override("font_size", 14)
	top_panel.add_child(bars_label)

	status_label = Label.new()
	status_label.offset_left = 14
	status_label.offset_top = 34
	status_label.offset_right = 470
	status_label.offset_bottom = 60
	status_label.text = "Selected: Empty"
	status_label.add_theme_font_size_override("font_size", 12)
	top_panel.add_child(status_label)

func _build_hotbar() -> void:
	hotbar_panel = HBoxContainer.new()
	hotbar_panel.name = "Hotbar"
	hotbar_panel.anchor_left = 0.5
	hotbar_panel.anchor_top = 1.0
	hotbar_panel.anchor_right = 0.5
	hotbar_panel.anchor_bottom = 1.0
	hotbar_panel.offset_left = -290
	hotbar_panel.offset_top = -70
	hotbar_panel.offset_right = 290
	hotbar_panel.offset_bottom = -12
	hotbar_panel.add_theme_constant_override("separation", SLOT_GAP)
	root.add_child(hotbar_panel)

	for i: int in range(9):
		var slot: Panel = Panel.new()
		slot.custom_minimum_size = SLOT_SIZE
		_style_panel(slot, Color(0.015, 0.017, 0.02, 0.78), Color(1, 1, 1, 0.24), 2)
		var item_label: Label = Label.new()
		item_label.name = "ItemLabel"
		item_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		item_label.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		item_label.set_anchors_preset(Control.PRESET_FULL_RECT)
		item_label.add_theme_font_size_override("font_size", 10)
		item_label.text = str(i + 1)
		slot.add_child(item_label)
		hotbar_panel.add_child(slot)
		hotbar_slots.append(slot)

func _build_toast() -> void:
	toast_label = Label.new()
	toast_label.name = "Toast"
	toast_label.anchor_left = 0.5
	toast_label.anchor_top = 0.0
	toast_label.anchor_right = 0.5
	toast_label.anchor_bottom = 0.0
	toast_label.offset_left = -320
	toast_label.offset_top = 96
	toast_label.offset_right = 320
	toast_label.offset_bottom = 134
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.add_theme_color_override("font_color", Color(1.0, 0.92, 0.55))	
	toast_label.add_theme_font_size_override("font_size", 14)
	root.add_child(toast_label)

func _build_inventory_panel() -> void:
	inventory_panel = _make_window("Inventory", Vector2(18, 98), Vector2(390, 380))
	inventory_grid = GridContainer.new()
	inventory_grid.columns = 2
	inventory_grid.offset_left = 16
	inventory_grid.offset_top = 52
	inventory_grid.offset_right = 372
	inventory_grid.offset_bottom = 354
	inventory_grid.add_theme_constant_override("h_separation", 8)
	inventory_grid.add_theme_constant_override("v_separation", 8)
	inventory_panel.add_child(inventory_grid)
	inventory_panel.visible = false

func _build_crafting_panel() -> void:
	crafting_panel = _make_window("Crafting", Vector2(-420, 98), Vector2(400, 380), true)
	crafting_grid = GridContainer.new()
	crafting_grid.columns = 1
	crafting_grid.offset_left = 14
	crafting_grid.offset_top = 52
	crafting_grid.offset_right = 386
	crafting_grid.offset_bottom = 354
	crafting_grid.add_theme_constant_override("v_separation", 7)
	crafting_panel.add_child(crafting_grid)
	crafting_panel.visible = false

func _build_smelting_panel() -> void:
	smelting_panel = _make_window("Smelting", Vector2(-420, 98), Vector2(400, 300), true)
	smelting_grid = GridContainer.new()
	smelting_grid.columns = 1
	smelting_grid.offset_left = 14
	smelting_grid.offset_top = 52
	smelting_grid.offset_right = 386
	smelting_grid.offset_bottom = 274
	smelting_grid.add_theme_constant_override("v_separation", 7)
	smelting_panel.add_child(smelting_grid)
	smelting_panel.visible = false

func _make_window(title: String, pos: Vector2, size: Vector2, from_right: bool = false) -> Panel:
	var panel: Panel = Panel.new()
	panel.name = title
	if from_right:
		panel.anchor_left = 1.0
		panel.anchor_right = 1.0
	else:
		panel.anchor_left = 0.0
		panel.anchor_right = 0.0
	panel.anchor_top = 0.0
	panel.anchor_bottom = 0.0
	panel.offset_left = pos.x
	panel.offset_top = pos.y
	panel.offset_right = pos.x + size.x
	panel.offset_bottom = pos.y + size.y
	_style_panel(panel, Color(0.015, 0.018, 0.023, 0.90), Color(1, 1, 1, 0.25), 6)
	root.add_child(panel)

	var label: Label = Label.new()
	label.text = title
	label.offset_left = 16
	label.offset_top = 12
	label.offset_right = size.x - 56
	label.offset_bottom = 40
	label.add_theme_color_override("font_color", Color(1.0, 0.91, 0.55))
	label.add_theme_font_size_override("font_size", 16)
	panel.add_child(label)

	var close: Button = Button.new()
	close.text = "X"
	close.offset_left = size.x - 46
	close.offset_top = 10
	close.offset_right = size.x - 14
	close.offset_bottom = 42
	_style_button(close)
	close.pressed.connect(func() -> void: panel.visible = false)
	panel.add_child(close)
	return panel

func update_all(player: Node) -> void:
	if player == null:
		return
	var hp: int = int(player.health)
	var st: int = int(player.stamina)
	var hu: int = int(player.hunger)
	var time_pct: int = int(player.world_time * 100.0)
	bars_label.text = "HP %s/%s   STA %s   HUNGER %s   DAY %s%%" % [hp, player.max_health, st, hu, time_pct]
	var selected: String = str(player.get_selected_item())
	status_label.text = "Selected: %s   |   %s" % [_short_name(selected, 18), _compact_inventory(player.inventory)]
	_update_hotbar(player)
	if inventory_panel.visible:
		_populate_inventory(player)
	if crafting_panel.visible:
		_populate_crafting(player)
	if smelting_panel.visible:
		_populate_smelting(player)

func _update_hotbar(player: Node) -> void:
	for i: int in range(hotbar_slots.size()):
		var slot: Panel = hotbar_slots[i]
		var item_id: String = ""
		if i < player.hotbar.size():
			item_id = str(player.hotbar[i])
		var label: Label = slot.get_node("ItemLabel") as Label
		var count: int = 0
		if item_id != "":
			count = int(player.inventory.get_count(item_id))
		label.text = "%s\n%s\nx%s" % [i + 1, _short_name(item_id, 7), count]
		var border: Color = Color(1, 1, 1, 0.24)
		var bg: Color = Color(0.015, 0.017, 0.02, 0.78)
		if i == int(player.selected_hotbar):
			border = Color(1.0, 0.82, 0.25, 0.95)
			bg = Color(0.10, 0.085, 0.035, 0.86)
		_style_panel(slot, bg, border, 2)

func _short_name(item_id: String, max_len: int = 10) -> String:
	if item_id == "":
		return "Empty"
	var item_name_text: String = GameRegistry.item_name(item_id)
	var compact: String = item_name_text.replace(" Block", "").replace("Ridgewood", "Ridge").replace("Fieldstone", "Field").replace("Charshard", "Char")
	if compact.length() > max_len:
		return compact.substr(0, max_len)
	return compact

func _compact_inventory(inv: InventoryData) -> String:
	var ids: Array[String] = inv.all_item_ids()
	var parts: Array[String] = []
	for i: int in range(min(3, ids.size())):
		parts.append("%s x%s" % [_short_name(ids[i], 9), inv.get_count(ids[i])])
	if ids.size() > 3:
		parts.append("+%s" % [ids.size() - 3])
	return ", ".join(parts)

func show_toast(message: String, seconds: float = 2.25) -> void:
	toast_label.text = message
	toast_time = seconds

func toggle_inventory(player: Node) -> void:
	inventory_panel.visible = not inventory_panel.visible
	if inventory_panel.visible:
		_populate_inventory(player)

func toggle_crafting(player: Node) -> void:
	crafting_panel.visible = not crafting_panel.visible
	smelting_panel.visible = false
	if crafting_panel.visible:
		_populate_crafting(player)

func toggle_smelting(player: Node) -> void:
	smelting_panel.visible = not smelting_panel.visible
	crafting_panel.visible = false
	if smelting_panel.visible:
		_populate_smelting(player)

func _clear_grid(grid: GridContainer) -> void:
	for child: Node in grid.get_children():
		child.queue_free()

func _populate_inventory(player: Node) -> void:
	_clear_grid(inventory_grid)
	var ids: Array[String] = player.inventory.all_item_ids()
	for item_id: String in ids:
		var label: Label = Label.new()
		label.text = "%s\nx%s" % [GameRegistry.item_name(item_id), player.inventory.get_count(item_id)]
		label.custom_minimum_size = Vector2(170, 48)
		label.add_theme_font_size_override("font_size", 11)
		inventory_grid.add_child(label)

func _populate_crafting(player: Node) -> void:
	_clear_grid(crafting_grid)
	var recipe_ids: Array[String] = GameRegistry.recipe_ids()
	for recipe_id: String in recipe_ids:
		var recipe: Dictionary = GameRegistry.get_recipe(recipe_id)
		var button: Button = Button.new()
		button.text = "%s | %s" % [str(recipe.get("name", recipe_id)), _cost_text(recipe.get("cost", {}))]
		button.custom_minimum_size = Vector2(360, 40)
		_style_button(button)
		button.disabled = not player.inventory.has_items(recipe.get("cost", {}))
		var rid: String = recipe_id
		button.pressed.connect(func() -> void: player.craft_recipe(rid))
		crafting_grid.add_child(button)

func _populate_smelting(player: Node) -> void:
	_clear_grid(smelting_grid)
	var item_ids: Array[String] = GameRegistry.smelting_ids()
	for item_id: String in item_ids:
		var smelt: Dictionary = GameRegistry.get_smelting(item_id)
		var fuel_id: String = str(smelt.get("fuel", "charshard"))
		var button: Button = Button.new()
		button.text = "%s + %s" % [GameRegistry.item_name(item_id), GameRegistry.item_name(fuel_id)]
		button.custom_minimum_size = Vector2(360, 40)
		_style_button(button)
		button.disabled = not player.inventory.has_item(item_id, 1) or not player.inventory.has_item(fuel_id, 1)
		var sid: String = item_id
		button.pressed.connect(func() -> void: player.smelt_item(sid))
		smelting_grid.add_child(button)

func _cost_text(cost: Dictionary) -> String:
	var parts: Array[String] = []
	for raw_id in cost.keys():
		var item_id: String = str(raw_id)
		parts.append("%s x%s" % [_short_name(item_id, 7), int(cost[raw_id])])
	return ", ".join(parts)
