extends Node3D
class_name VoxelWorld

const BLOCK_SIZE := 1.0
const WORLD_X := 16
const WORLD_Z := 16
const MAX_HEIGHT := 5

const AIR := 0
const GRASS := 1
const DIRT := 2
const STONE := 3

var blocks: Dictionary = {}
var materials: Dictionary = {}

func _ready() -> void:
	_create_materials()
	_generate_world()

func _create_materials() -> void:
	materials[GRASS] = _make_material(Color(0.24, 0.72, 0.22))
	materials[DIRT] = _make_material(Color(0.45, 0.28, 0.12))
	materials[STONE] = _make_material(Color(0.45, 0.45, 0.48))

func _make_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.85
	return material

func _generate_world() -> void:
	for x in range(WORLD_X):
		for z in range(WORLD_Z):
			var height := 2 + int(round(sin(float(x) * 0.55) + cos(float(z) * 0.45)))
			height = clamp(height, 1, MAX_HEIGHT)
			for y in range(height):
				var block_type := STONE if y == 0 else DIRT
				if y == height - 1:
					block_type = GRASS
				set_block(Vector3i(x, y, z), block_type)

func world_to_block(world_position: Vector3) -> Vector3i:
	return Vector3i(floori(world_position.x / BLOCK_SIZE), floori(world_position.y / BLOCK_SIZE), floori(world_position.z / BLOCK_SIZE))

func has_block(block_position: Vector3i) -> bool:
	return blocks.has(block_position)

func set_block(block_position: Vector3i, block_type: int) -> void:
	if block_type == AIR:
		remove_block(block_position)
		return
	if blocks.has(block_position):
		remove_block(block_position)

	var body := StaticBody3D.new()
	body.name = "Block_%s_%s_%s" % [block_position.x, block_position.y, block_position.z]
	body.position = Vector3(block_position) * BLOCK_SIZE + Vector3.ONE * (BLOCK_SIZE * 0.5)
	body.set_meta("block_position", block_position)
	body.set_meta("block_type", block_type)

	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3.ONE * BLOCK_SIZE
	mesh_instance.mesh = mesh
	mesh_instance.material_override = materials.get(block_type)
	body.add_child(mesh_instance)

	var collision := CollisionShape3D.new()
	var shape := BoxShape3D.new()
	shape.size = Vector3.ONE * BLOCK_SIZE
	collision.shape = shape
	body.add_child(collision)

	add_child(body)
	blocks[block_position] = body

func remove_block(block_position: Vector3i) -> void:
	if not blocks.has(block_position):
		return
	var body: Node = blocks[block_position]
	blocks.erase(block_position)
	body.queue_free()

func break_block_from_collider(collider: Object) -> bool:
	if collider == null or not collider.has_meta("block_position"):
		return false
	var block_position: Vector3i = collider.get_meta("block_position")
	remove_block(block_position)
	return true

func place_block_from_hit(hit_position: Vector3, hit_normal: Vector3, block_type: int = GRASS) -> bool:
	var target := world_to_block(hit_position + hit_normal * 0.51)
	if has_block(target):
		return false
	set_block(target, block_type)
	return true
