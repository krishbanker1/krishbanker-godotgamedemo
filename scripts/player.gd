extends CharacterBody3D

@export var move_speed := 5.4
@export var sprint_speed := 7.2
@export var jump_velocity := 5.0
@export var mouse_sensitivity := 0.0025
@export var touch_look_sensitivity := 0.006

const GRAVITY := 15.0
const SAVE_PATH := "user://terraforge_save.json"

@onready var camera: Camera3D = $Camera3D
@onready var block_ray: RayCast3D = $Camera3D/BlockRay
@onready var world: VoxelWorld = get_node_or_null("../World") as VoxelWorld
@onready var hud: Node = get_node_or_null("../Hud")

var yaw := 0.0
var pitch := 0.0
var mobile_move := Vector2.ZERO
var mobile_look_delta := Vector2.ZERO
var break_requested := false
var place_requested := false
var jump_requested := false
var attack_requested := false
var interact_requested := false

var inventory := InventoryData.new()
var selected_hotbar := 0
var hotbar: Array[String] = ["grass_turf", "soil", "stone", "oak_log", "plank_block", "charshard_torch", "workbench", "kiln", "berry"]

var health := 100
var max_health := 100
var stamina := 100.0
var max_stamina := 100.0
var hunger := 100.0
var max_hunger := 100.0
var world_time := 0.25
var alive := true
var message_cooldown := 0.0

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_seed_starting_inventory()
	_update_hud()
	_toast("TerraForge ready. Explore, mine, craft, survive.")

func _seed_starting_inventory() -> void:
	inventory.add_item("grass_turf", 20)
	inventory.add_item("soil", 16)
	inventory.add_item("stone", 14)
	inventory.add_item("oak_log", 8)
	inventory.add_item("charshard", 5)
	inventory.add_item("sand", 6)
	inventory.add_item("berry", 3)
	inventory.add_item("wood_sword", 1)

func _unhandled_input(event: InputEvent) -> void:
	if not alive:
		return
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_rotate_view(event.relative * mouse_sensitivity)
	elif event is InputEventScreenDrag:
		_rotate_view(event.relative * touch_look_sensitivity)
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			break_requested = true
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			place_requested = true
	elif event is InputEventKey and event.pressed:
		_handle_key(event.keycode)

func _handle_key(keycode: int) -> void:
	match keycode:
		KEY_ESCAPE:
			Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
		KEY_SPACE:
			jump_requested = true
		KEY_TAB:
			select_next_hotbar()
		KEY_C:
			request_craft_basic()
		KEY_F:
			request_smelting_basic()
		KEY_I:
			toggle_inventory()
		KEY_E:
			request_interact()
		KEY_R:
			eat_selected_food()
		KEY_P:
			save_game()
		KEY_L:
			load_game()
		KEY_1:
			set_hotbar_index(0)
		KEY_2:
			set_hotbar_index(1)
		KEY_3:
			set_hotbar_index(2)
		KEY_4:
			set_hotbar_index(3)
		KEY_5:
			set_hotbar_index(4)
		KEY_6:
			set_hotbar_index(5)
		KEY_7:
			set_hotbar_index(6)
		KEY_8:
			set_hotbar_index(7)
		KEY_9:
			set_hotbar_index(8)

func _physics_process(delta: float) -> void:
	if not alive:
		return
	message_cooldown = max(0.0, message_cooldown - delta)
	_apply_mobile_look()
	_move_player(delta)
	_update_survival(delta)
	_handle_actions()

func _move_player(delta: float) -> void:
	var input_vector := Vector2.ZERO
	if Input.is_key_pressed(KEY_W) or Input.is_key_pressed(KEY_UP):
		input_vector.y -= 1.0
	if Input.is_key_pressed(KEY_S) or Input.is_key_pressed(KEY_DOWN):
		input_vector.y += 1.0
	if Input.is_key_pressed(KEY_A) or Input.is_key_pressed(KEY_LEFT):
		input_vector.x -= 1.0
	if Input.is_key_pressed(KEY_D) or Input.is_key_pressed(KEY_RIGHT):
		input_vector.x += 1.0
	if mobile_move.length() > 0.05:
		input_vector += mobile_move
	input_vector = input_vector.limit_length(1.0)

	var sprinting := Input.is_key_pressed(KEY_SHIFT) and stamina > 5.0 and input_vector.length() > 0.1
	var speed := sprint_speed if sprinting else move_speed
	if sprinting:
		stamina = max(0.0, stamina - delta * 16.0)
	else:
		stamina = min(max_stamina, stamina + delta * 9.0)

	var basis := global_transform.basis
	var direction := (basis.x * input_vector.x + basis.z * input_vector.y).normalized()
	velocity.x = direction.x * speed
	velocity.z = direction.z * speed

	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	elif jump_requested or Input.is_key_pressed(KEY_SPACE):
		velocity.y = jump_velocity
		stamina = max(0.0, stamina - 5.0)
	jump_requested = false
	move_and_slide()

func _update_survival(delta: float) -> void:
	hunger = max(0.0, hunger - delta * 0.35)
	if hunger <= 0.0:
		take_damage(4, "starvation")
	elif hunger > 70.0 and health < max_health:
		health = min(max_health, health + 1)
	_update_hud()

func _rotate_view(delta_pixels: Vector2) -> void:
	yaw -= delta_pixels.x
	pitch = clamp(pitch - delta_pixels.y, deg_to_rad(-85), deg_to_rad(85))
	rotation.y = yaw
	camera.rotation.x = pitch

func _apply_mobile_look() -> void:
	if mobile_look_delta != Vector2.ZERO:
		_rotate_view(mobile_look_delta * touch_look_sensitivity)
		mobile_look_delta = Vector2.ZERO

func set_mobile_move(value: Vector2) -> void:
	mobile_move = value.limit_length(1.0)

func add_mobile_look(relative_delta: Vector2) -> void:
	mobile_look_delta += relative_delta

func request_break() -> void:
	break_requested = true

func request_place() -> void:
	place_requested = true

func request_jump() -> void:
	jump_requested = true

func request_attack() -> void:
	attack_requested = true

func request_interact() -> void:
	interact_requested = true

func select_next_hotbar() -> void:
	set_hotbar_index((selected_hotbar + 1) % hotbar.size())

func select_previous_hotbar() -> void:
	set_hotbar_index((selected_hotbar - 1 + hotbar.size()) % hotbar.size())

func set_hotbar_index(index: int) -> void:
	selected_hotbar = clampi(index, 0, hotbar.size() - 1)
	_toast("Selected %s" % GameRegistry.item_name(get_selected_item()))
	_update_hud()

func get_selected_item() -> String:
	if selected_hotbar < 0 or selected_hotbar >= hotbar.size():
		return ""
	return hotbar[selected_hotbar]

func _handle_actions() -> void:
	block_ray.force_raycast_update()
	if attack_requested or break_requested:
		if block_ray.is_colliding() and block_ray.get_collider() is TerraMob:
			_attack_mob(block_ray.get_collider())
		elif break_requested:
			_break_target_block()
	if place_requested:
		_try_place_selected_block()
	if interact_requested:
		_interact_target()
	break_requested = false
	place_requested = false
	attack_requested = false
	interact_requested = false

func _break_target_block() -> void:
	if world == null or not block_ray.is_colliding():
		return
	var collider := block_ray.get_collider()
	if collider == null or collider is TerraMob:
		return
	var block_id := str(collider.get_meta("block_id", "stone"))
	var needed := int(ceil(GameRegistry.block_hardness(block_id)))
	var tool_tier := GameRegistry.item_tool_tier(get_selected_item())
	if GameRegistry.block_hardness(block_id) > 1.0 and tool_tier == 0:
		_toast("Need a pick tool for %s" % GameRegistry.block_name(block_id))
		return
	if tool_tier + 1 < needed and GameRegistry.block_hardness(block_id) > 2.0:
		_toast("Tool too weak")
		return
	var result := world.break_block_from_collider(collider)
	if result.is_empty():
		return
	var dropped_item := str(result.get("drop", ""))
	if dropped_item != "":
		var pos: Vector3 = result.get("position", global_position)
		world.spawn_pickup(dropped_item, 1, pos)
		_toast("Broke %s" % GameRegistry.block_name(block_id))
	_update_hud()

func _try_place_selected_block() -> void:
	if world == null or not block_ray.is_colliding():
		return
	var item_id := get_selected_item()
	if item_id == "" or not GameRegistry.is_placeable_item(item_id):
		_toast("Selected item cannot be placed")
		return
	if not inventory.has_item(item_id, 1):
		_toast("Need %s" % GameRegistry.item_name(item_id))
		return
	var block_id := GameRegistry.item_place_block(item_id)
	var placed := world.place_block_from_hit(block_ray.get_collision_point(), block_ray.get_collision_normal(), block_id)
	if placed:
		inventory.remove_item(item_id, 1)
		_toast("Placed %s" % GameRegistry.item_name(item_id))
		_update_hud()
	else:
		_toast("Cannot place there")

func _attack_mob(mob: TerraMob) -> void:
	var damage := GameRegistry.item_weapon_damage(get_selected_item())
	mob.take_damage(damage)
	_toast("Hit %s for %s" % [GameRegistry.mob_name(mob.mob_id), damage])

func _interact_target() -> void:
	if not block_ray.is_colliding():
		return
	var collider := block_ray.get_collider()
	if collider == null or not collider.has_meta("block_id"):
		return
	var block_id := str(collider.get_meta("block_id"))
	if block_id == "workbench":
		toggle_crafting()
	elif block_id == "kiln":
		toggle_smelting()
	elif block_id == "chest":
		inventory.add_item("berry", 3)
		inventory.add_item("charshard", 2)
		_toast("Supply crate opened")
		_update_hud()
	elif block_id == "beacon_core":
		_toast("Aether Beacon activated. Vertical slice goal reached.", 4.0)
	else:
		_toast(GameRegistry.block_name(block_id))

func request_craft_basic() -> void:
	var recipe_id := CraftingSystem.first_craftable_recipe(inventory, GameRegistry.recipe_ids())
	if recipe_id == "":
		_toast("No craftable recipe")
		return
	craft_recipe(recipe_id)

func craft_recipe(recipe_id: String) -> void:
	var result := CraftingSystem.try_craft(inventory, recipe_id)
	if result != "":
		_toast("Crafted %s" % result)
		_update_hud()
	else:
		_toast("Missing ingredients")

func request_smelting_basic() -> void:
	for input_id in GameRegistry.smelting_ids():
		var result := CraftingSystem.try_smelting(inventory, str(input_id))
		if result != "":
			_toast("Smelted %s" % result)
			_update_hud()
			return
	_toast("Need smeltable item + Charshard fuel")

func smelt_item(input_id: String) -> void:
	var result := CraftingSystem.try_smelting(inventory, input_id)
	if result != "":
		_toast("Smelted %s" % result)
		_update_hud()
	else:
		_toast("Need item + fuel")

func eat_selected_food() -> void:
	var item_id := get_selected_item()
	var food := GameRegistry.item_food_value(item_id)
	if food <= 0:
		_toast("Selected item is not food")
		return
	if inventory.remove_item(item_id, 1):
		hunger = min(max_hunger, hunger + food)
		_toast("Ate %s" % GameRegistry.item_name(item_id))
		_update_hud()

func collect_pickup(item_id: String, amount: int) -> void:
	inventory.add_item(item_id, amount)
	_toast("Collected %s x%s" % [GameRegistry.item_name(item_id), amount])
	_update_hud()

func take_damage(amount: int, source: String = "danger") -> void:
	if not alive or message_cooldown > 0.0 and source == "starvation":
		return
	message_cooldown = 0.7
	health -= amount
	_toast("%s damage from %s" % [amount, source])
	if health <= 0:
		_die()
	_update_hud()

func _die() -> void:
	alive = false
	health = 0
	_toast("You collapsed. Press Load or restart.", 10.0)
	_update_hud()

func set_world_time(value: float) -> void:
	world_time = value
	_update_hud()

func toggle_inventory() -> void:
	if hud != null and hud.has_method("toggle_inventory"):
		hud.call("toggle_inventory", self)

func toggle_crafting() -> void:
	if hud != null and hud.has_method("toggle_crafting"):
		hud.call("toggle_crafting", self)

func toggle_smelting() -> void:
	if hud != null and hud.has_method("toggle_smelting"):
		hud.call("toggle_smelting", self)

func save_game() -> void:
	var data := {
		"position": [global_position.x, global_position.y, global_position.z],
		"yaw": yaw,
		"pitch": pitch,
		"health": health,
		"stamina": stamina,
		"hunger": hunger,
		"selected_hotbar": selected_hotbar,
		"inventory": inventory.to_dictionary()
	}
	var file := FileAccess.open(SAVE_PATH, FileAccess.WRITE)
	if file == null:
		_toast("Save failed")
		return
	file.store_string(JSON.stringify(data))
	_toast("Game saved")

func load_game() -> void:
	if not FileAccess.file_exists(SAVE_PATH):
		_toast("No save found")
		return
	var file := FileAccess.open(SAVE_PATH, FileAccess.READ)
	if file == null:
		_toast("Load failed")
		return
	var parsed = JSON.parse_string(file.get_as_text())
	if typeof(parsed) != TYPE_DICTIONARY:
		_toast("Save file corrupted")
		return
	var data: Dictionary = parsed
	var pos: Array = data.get("position", [8.0, 8.0, 8.0])
	global_position = Vector3(float(pos[0]), float(pos[1]), float(pos[2]))
	yaw = float(data.get("yaw", 0.0))
	pitch = float(data.get("pitch", 0.0))
	rotation.y = yaw
	camera.rotation.x = pitch
	health = int(data.get("health", max_health))
	stamina = float(data.get("stamina", max_stamina))
	hunger = float(data.get("hunger", max_hunger))
	selected_hotbar = int(data.get("selected_hotbar", 0))
	inventory.from_dictionary(data.get("inventory", {}))
	alive = health > 0
	_toast("Game loaded")
	_update_hud()

func _update_hud() -> void:
	if hud != null and hud.has_method("update_all"):
		hud.call("update_all", self)

func _toast(message: String, seconds: float = 2.25) -> void:
	if hud != null and hud.has_method("show_toast"):
		hud.call("show_toast", message, seconds)
