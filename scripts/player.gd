extends CharacterBody3D

@export var move_speed := 5.0
@export var jump_velocity := 5.0
@export var mouse_sensitivity := 0.0025
@export var touch_look_sensitivity := 0.006

const GRAVITY := 14.0

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
var inventory := InventoryData.new()
var selected_hotbar := 0
var hotbar: Array[String] = [
	"grass_turf",
	"soil",
	"stone",
	"oak_log",
	"plank_block",
	"charshard_torch",
	"workbench",
	"kiln"
]

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	_seed_starting_inventory()
	_update_hud()

func _seed_starting_inventory() -> void:
	inventory.add_item("grass_turf", 16)
	inventory.add_item("soil", 12)
	inventory.add_item("stone", 10)
	inventory.add_item("oak_log", 4)
	inventory.add_item("charshard", 3)
	inventory.add_item("sand", 4)

func _unhandled_input(event: InputEvent) -> void:
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

func _physics_process(delta: float) -> void:
	_apply_mobile_look()
	_move_player(delta)
	_handle_block_actions()

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

	var basis := global_transform.basis
	var direction := (basis.x * input_vector.x + basis.z * input_vector.y).normalized()
	velocity.x = direction.x * move_speed
	velocity.z = direction.z * move_speed

	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	elif jump_requested or Input.is_key_pressed(KEY_SPACE):
		velocity.y = jump_velocity
	jump_requested = false

	move_and_slide()

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

func _handle_block_actions() -> void:
	if world == null:
		break_requested = false
		place_requested = false
		return
	block_ray.force_raycast_update()
	if break_requested and block_ray.is_colliding():
		var dropped_item := world.break_block_from_collider(block_ray.get_collider())
		if dropped_item != "":
			inventory.add_item(dropped_item, 1)
			_toast("Collected %s" % GameRegistry.item_name(dropped_item))
			_update_hud()
	if place_requested and block_ray.is_colliding():
		_try_place_selected_block()
	break_requested = false
	place_requested = false

func _try_place_selected_block() -> void:
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

func request_craft_basic() -> void:
	var recipe_order: Array[String] = [
		"plank_block_from_log",
		"stick_bundle",
		"workbench",
		"charshard_torch",
		"kiln",
		"wood_pick",
		"stone_pick"
	]
	var recipe_id := CraftingSystem.first_craftable_recipe(inventory, recipe_order)
	if recipe_id == "":
		_toast("No starter recipe available")
		return
	var result := CraftingSystem.try_craft(inventory, recipe_id)
	if result != "":
		_toast("Crafted %s" % result)
		_update_hud()

func request_smelting_basic() -> void:
	for input_id in ["ferrite_ore", "aurum_ore", "sand"]:
		var result := CraftingSystem.try_smelting(inventory, str(input_id))
		if result != "":
			_toast("Smelted %s" % result)
			_update_hud()
			return
	_toast("Need ore/sand + Charshard fuel")

func _update_hud() -> void:
	if hud != null and hud.has_method("update_status"):
		hud.call("update_status", get_selected_item(), selected_hotbar + 1, inventory.summary())

func _toast(message: String) -> void:
	if hud != null and hud.has_method("show_toast"):
		hud.call("show_toast", message)
