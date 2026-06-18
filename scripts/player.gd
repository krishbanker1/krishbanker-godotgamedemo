extends CharacterBody3D

@export var move_speed := 5.0
@export var jump_velocity := 5.0
@export var mouse_sensitivity := 0.0025
@export var touch_look_sensitivity := 0.006

const GRAVITY := 14.0

@onready var camera: Camera3D = $Camera3D
@onready var block_ray: RayCast3D = $Camera3D/BlockRay
@onready var world: VoxelWorld = get_tree().get_first_node_in_group("voxel_world") as VoxelWorld

var yaw := 0.0
var pitch := 0.0
var mobile_move := Vector2.ZERO
var mobile_look_delta := Vector2.ZERO
var break_requested := false
var place_requested := false

func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_CAPTURED)
	world = get_node_or_null("../World") as VoxelWorld

func _unhandled_input(event: InputEvent) -> void:
	if event is InputEventMouseMotion and Input.get_mouse_mode() == Input.MOUSE_MODE_CAPTURED:
		_rotate_view(event.relative * mouse_sensitivity)
	elif event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			break_requested = true
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			place_requested = true
	elif event is InputEventKey and event.pressed and event.keycode == KEY_ESCAPE:
		Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

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
	elif Input.is_key_pressed(KEY_SPACE):
		velocity.y = jump_velocity

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

func _handle_block_actions() -> void:
	if world == null:
		break_requested = false
		place_requested = false
		return
	block_ray.force_raycast_update()
	if break_requested and block_ray.is_colliding():
		world.break_block_from_collider(block_ray.get_collider())
	if place_requested and block_ray.is_colliding():
		world.place_block_from_hit(block_ray.get_collision_point(), block_ray.get_collision_normal(), VoxelWorld.GRASS)
	break_requested = false
	place_requested = false
