extends Node3D
class_name VoxelWorld

const BLOCK_SIZE := 1.0
const WORLD_X := 26
const WORLD_Z := 26
const MAX_HEIGHT := 7
const WORLD_FLOOR := 0

var blocks: Dictionary = {}
var materials: Dictionary = {}
var height_map: Dictionary = {}

func _ready() -> void:
	add_to_group("voxel_world")
	_create_materials()
	_generate_world()

func _create_materials() -> void:
	for block_id in GameRegistry.BLOCKS.keys():
		if block_id == GameRegistry.AIR:
			continue
		materials[block_id] = _make_material(GameRegistry.block_color(str(block_id)))

func _make_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.88
	return material

func _generate_world() -> void:
	for x in range(WORLD_X):
		for z in range(WORLD_Z):
			var biome_id := GameRegistry.biome_at(x, z)
			var height := _height_for_column(x, z, biome_id)
			height_map[Vector2i(x, z)] = height
			for y in range(height):
				var block_id := _block_for_depth(x, y, z, height, biome_id)
				set_block(Vector3i(x, y, z), block_id)
	_generate_trees()
	_spawn_marker_blocks()

func _height_for_column(x: int, z: int, biome_id: String) -> int:
	var wave := sin(float(x) * 0.43) + cos(float(z) * 0.37) + sin(float(x + z) * 0.18)
	var base_height := 3 + int(round(wave))
	if biome_id == "dunes":
		base_height -= 1
	elif biome_id == "frostvale":
		base_height += 1
	return clamp(base_height, 2, MAX_HEIGHT)

func _block_for_depth(x: int, y: int, z: int, height: int, biome_id: String) -> String:
	if y == height - 1:
		return GameRegistry.biome_surface(biome_id)
	if y >= height - 3:
		return GameRegistry.biome_subsoil(biome_id)
	var ore := _ore_for_depth(x, y, z)
	if ore != "":
		return ore
	return "stone"

func _ore_for_depth(x: int, y: int, z: int) -> String:
	var roll := int(abs(sin(float(x * 19 + z * 31 + y * 47)) * 10000.0)) % 100
	if y <= 1 and roll < 7:
		return "charshard_ore"
	if y <= 2 and roll >= 7 and roll < 12:
		return "ferrite_ore"
	if y <= 1 and roll >= 12 and roll < 15:
		return "aurum_ore"
	if y == 0 and roll == 42:
		return "aether_crystal_ore"
	if y == 0 and roll == 66:
		return "embercore_ore"
	return ""

func _generate_trees() -> void:
	for key in height_map.keys():
		var column: Vector2i = key
		var biome_id := GameRegistry.biome_at(column.x, column.y)
		if not GameRegistry.biome_allows_trees(biome_id):
			continue
		if column.x < 2 or column.y < 2 or column.x > WORLD_X - 3 or column.y > WORLD_Z - 3:
			continue
		if int(abs(sin(float(column.x * 71 + column.y * 97)) * 1000.0)) % 19 != 0:
			continue
		var ground_y := int(height_map[column])
		for trunk_y in range(ground_y, ground_y + 3):
			set_block(Vector3i(column.x, trunk_y, column.y), "oak_log")
		for lx in range(-1, 2):
			for lz in range(-1, 2):
				set_block(Vector3i(column.x + lx, ground_y + 3, column.y + lz), "leaf_block")
		set_block(Vector3i(column.x, ground_y + 4, column.y), "leaf_block")

func _spawn_marker_blocks() -> void:
	# A few craftable utility blocks near spawn so testing works even before UI menus exist.
	set_block(Vector3i(9, 5, 8), "workbench")
	set_block(Vector3i(10, 5, 8), "kiln")
	set_block(Vector3i(11, 5, 8), "charshard_torch")

func world_to_block(world_position: Vector3) -> Vector3i:
	return Vector3i(floori(world_position.x / BLOCK_SIZE), floori(world_position.y / BLOCK_SIZE), floori(world_position.z / BLOCK_SIZE))

func has_block(block_position: Vector3i) -> bool:
	return blocks.has(block_position)

func set_block(block_position: Vector3i, block_id: String) -> void:
	if block_id == GameRegistry.AIR or block_id == "":
		remove_block(block_position)
		return
	if blocks.has(block_position):
		remove_block(block_position)

	var block_data := GameRegistry.get_block(block_id)
	if not bool(block_data.get("solid", true)):
		return

	var body := StaticBody3D.new()
	body.name = "Block_%s_%s_%s" % [block_position.x, block_position.y, block_position.z]
	body.position = Vector3(block_position) * BLOCK_SIZE + Vector3.ONE * (BLOCK_SIZE * 0.5)
	body.set_meta("block_position", block_position)
	body.set_meta("block_id", block_id)
	body.add_to_group("voxel_blocks")

	var mesh_instance := MeshInstance3D.new()
	var mesh := BoxMesh.new()
	mesh.size = Vector3.ONE * BLOCK_SIZE
	mesh_instance.mesh = mesh
	mesh_instance.material_override = materials.get(block_id, materials.get("stone"))
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

func break_block_from_collider(collider: Object) -> String:
	if collider == null or not collider.has_meta("block_position"):
		return ""
	var block_position: Vector3i = collider.get_meta("block_position")
	var block_id := str(collider.get_meta("block_id"))
	remove_block(block_position)
	return GameRegistry.block_drop(block_id)

func place_block_from_hit(hit_position: Vector3, hit_normal: Vector3, block_id: String) -> bool:
	if block_id == "" or not GameRegistry.BLOCKS.has(block_id):
		return false
	var target := world_to_block(hit_position + hit_normal * 0.51)
	if target.y < WORLD_FLOOR or target.y > 64:
		return false
	if has_block(target):
		return false
	set_block(target, block_id)
	return true
