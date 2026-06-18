extends CharacterBody3D
class_name TerraMob

const GRAVITY := 18.0

var mob_id := "grazer"
var mob_data := {}
var health := 10
var max_health := 10
var speed := 1.4
var damage := 0
var drop_item := "berry"
var role := "passive"
var target: Node3D
var wander_dir := Vector3.ZERO
var change_dir_time := 0.0
var attack_cooldown := 0.0
var mesh_instance: MeshInstance3D

func setup(new_mob_id: String, new_target: Node3D) -> void:
	mob_id = new_mob_id
	target = new_target
	mob_data = GameRegistry.get_mob(mob_id)
	max_health = int(mob_data.get("health", 10))
	health = max_health
	speed = float(mob_data.get("speed", 1.4))
	damage = int(mob_data.get("damage", 0))
	drop_item = str(mob_data.get("drop", "berry"))
	role = str(mob_data.get("role", "passive"))

func _ready() -> void:
	if mob_data.is_empty():
		setup(mob_id, target)
	add_to_group("mobs")
	_build_body()
	_pick_new_direction()

func _physics_process(delta: float) -> void:
	attack_cooldown = max(0.0, attack_cooldown - delta)
	change_dir_time -= delta
	if change_dir_time <= 0.0:
		_pick_new_direction()
	var desired := _desired_direction()
	velocity.x = desired.x * speed
	velocity.z = desired.z * speed
	if not is_on_floor():
		velocity.y -= GRAVITY * delta
	else:
		velocity.y = -0.1
	move_and_slide()
	_try_attack()

func _build_body() -> void:
	var collision := CollisionShape3D.new()
	var capsule := CapsuleShape3D.new()
	capsule.radius = 0.35
	capsule.height = 1.15
	collision.position.y = 0.6
	collision.shape = capsule
	add_child(collision)

	mesh_instance = MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.75, 1.0, 0.75)
	mesh_instance.position.y = 0.55
	mesh_instance.mesh = box
	var mat := StandardMaterial3D.new()
	var colors: Array = mob_data.get("color", [0.8, 0.8, 0.8])
	mat.albedo_color = Color(float(colors[0]), float(colors[1]), float(colors[2]))
	mat.roughness = 0.65
	mesh_instance.material_override = mat
	add_child(mesh_instance)

func _desired_direction() -> Vector3:
	if target == null:
		return wander_dir
	var distance := global_position.distance_to(target.global_position)
	if role == "hostile" or role == "elite":
		if distance < 16.0:
			return (target.global_position - global_position).normalized()
	elif distance < 5.0:
		return (global_position - target.global_position).normalized()
	return wander_dir

func _pick_new_direction() -> void:
	change_dir_time = randf_range(1.5, 4.0)
	var angle := randf() * TAU
	wander_dir = Vector3(cos(angle), 0.0, sin(angle)).normalized()

func _try_attack() -> void:
	if damage <= 0 or target == null or attack_cooldown > 0.0:
		return
	if global_position.distance_to(target.global_position) <= 1.35 and target.has_method("take_damage"):
		target.call("take_damage", damage, GameRegistry.mob_name(mob_id))
		attack_cooldown = 1.25

func take_damage(amount: int) -> void:
	health -= amount
	if mesh_instance != null:
		mesh_instance.scale = Vector3.ONE * 1.08
		await get_tree().create_timer(0.08).timeout
		if mesh_instance != null:
			mesh_instance.scale = Vector3.ONE
	if health <= 0:
		_die()

func _die() -> void:
	var world := get_tree().get_first_node_in_group("voxel_world")
	if world != null and world.has_method("spawn_pickup"):
		world.call("spawn_pickup", drop_item, 1, global_position + Vector3.UP * 0.6)
	queue_free()
