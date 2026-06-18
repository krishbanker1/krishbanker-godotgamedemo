extends Node3D
class_name VoxelWorld

const BLOCK_SIZE := 1.0
const CHUNK_SIZE := 8
const MAX_HEIGHT := 10
const WORLD_FLOOR := 0
const LOAD_RADIUS_CHUNKS := 3
const UNLOAD_RADIUS_CHUNKS := 4
const CHUNK_CHECK_INTERVAL := 0.5

var blocks: Dictionary = {}
var block_ids: Dictionary = {}
var materials: Dictionary = {}
var height_map: Dictionary = {}

var loaded_chunks: Dictionary = {}
var chunk_nodes: Dictionary = {}
var player_ref: Node3D = null
var chunk_check_timer := 0.0
var current_center_chunk := Vector2i(999999, 999999)

func _ready() -> void:
	add_to_group("voxel_world")
	_create_materials()
	player_ref = get_node_or_null("../Player") as Node3D
	_update_chunks(true)

func _process(delta: float) -> void:
	chunk_check_timer -= delta
	if chunk_check_timer <= 0.0:
		chunk_check_timer = CHUNK_CHECK_INTERVAL
		_update_chunks(false)

func _create_materials() -> void:
	for block_id in GameRegistry.BLOCKS.keys():
		if block_id == GameRegistry.AIR:
			continue
		materials[block_id] = _make_material(GameRegistry.block_color(str(block_id)))

func _make_material(color: Color) -> StandardMaterial3D:
	var material := StandardMaterial3D.new()
	material.albedo_color = color
	material.roughness = 0.9
	return material

func _player_chunk_coord() -> Vector2i:
	if player_ref == null:
		return Vector2i.ZERO
	var bx := floori(player_ref.global_position.x / BLOCK_SIZE)
	var bz := floori(player_ref.global_position.z / BLOCK_SIZE)
	return Vector2i(floori(float(bx) / float(CHUNK_SIZE)), floori(float(bz) / float(CHUNK_SIZE)))

func _update_chunks(force: bool) -> void:
	if player_ref == null:
		player_ref = get_node_or_null("../Player") as Node3D
	var center := _player_chunk_coord()
	if not force and center == current_center_chunk:
		return
	current_center_chunk = center

	for cx in range(center.x - LOAD_RADIUS_CHUNKS, center.x + LOAD_RADIUS_CHUNKS + 1):
		for cz in range(center.y - LOAD_RADIUS_CHUNKS, center.y + LOAD_RADIUS_CHUNKS + 1):
			var coord := Vector2i(cx, cz)
			if not loaded_chunks.has(coord):
				_generate_chunk(coord)

	var to_unload: Array[Vector2i] = []
	for coord in loaded_chunks.keys():
		var dist := max(abs(coord.x - center.x), abs(coord.y - center.y))
		if dist > UNLOAD_RADIUS_CHUNKS:
			to_unload.append(coord)
	for coord in to_unload:
		_unload_chunk(coord)

func _generate_chunk(coord: Vector2i) -> void:
	loaded_chunks[coord] = true
	var block_list: Array[Vector3i] = []
	var origin_x := coord.x * CHUNK_SIZE
	var origin_z := coord.y * CHUNK_SIZE

	for lx in range(CHUNK_SIZE):
		for lz in range(CHUNK_SIZE):
			var x := origin_x + lx
			var z := origin_z + lz
			var biome_id := GameRegistry.biome_at(x, z)
			var height := _height_for_column(x, z, biome_id)
			height_map[Vector2i(x, z)] = height
			for y in range(height):
				var placed := set_block(Vector3i(x, y, z), _block_for_depth(x, y, z, height, biome_id))
				if placed:
					block_list.append(Vector3i(x, y, z))

	var tree_blocks := _generate_trees_in_chunk(coord, origin_x, origin_z)
	block_list.append_array(tree_blocks)

	if coord == Vector2i.ZERO:
		var marker_blocks := _spawn_marker_blocks()
		block_list.append_array(marker_blocks)
		_spawn_bonus_items()

	chunk_nodes[coord] = block_list

func _unload_chunk(coord: Vector2i) -> void:
	if not chunk_nodes.has(coord):
		loaded_chunks.erase(coord)
		return
	var block_list: Array = chunk_nodes[coord]
	for block_position in block_list:
		remove_block(block_position)
	chunk_nodes.erase(coord)
	loaded_chunks.erase(coord)

func _height_for_column(x: int, z: int, biome_id: String) -> int:
	var wave := sin(float(x) * 0.31) + cos(float(z) * 0.27) + sin(float(x + z) * 0.14) + cos(float(x - z) * 0.10)
	var base_height := 4 + int(round(wave * 1.35))
	if biome_id == "dunes":
		base_height -= 1
	elif biome_id == "frostvale":
		base_height += 1
	elif biome_id == "craglands":
		base_height += 2
	return clamp(base_height, 2, MAX_HEIGHT)

func _block_for_depth(x: int, y: int, z: int, height: int, biome_id: String) -> String:
	if y == height - 1:
		return GameRegistry.biome_surface(biome_id)
	if y >= height - 3:
		return GameRegistry.biome_subsoil(biome_id)
	var ore := _ore_for_depth(x, y, z)
	if ore != "":
		return ore
	if y <= 1:
		return "deepstone"
	return "stone"

func _ore_for_depth(x: int, y: int, z: int) -> String:
	var roll := int(abs(sin(float(x * 19 + z * 31 + y * 47)) * 10000.0)) % 100
	if y <= 3 and roll < 9:
		return "charshard_ore"
	if y <= 3 and roll >= 9 and roll < 15:
		return "ferrite_ore"
	if y <= 2 and roll >= 15 and roll < 19:
		return "aurum_ore"
	if y <= 1 and roll >= 19 and roll < 22:
		return "aether_crystal_ore"
	if y <= 1 and roll == 42:
		return "embercore_ore"
	if y == 0 and roll == 66:
		return "voidstone_ore"
	return ""

func _generate_trees_in_chunk(coord: Vector2i, origin_x: int, origin_z: int) -> Array[Vector3i]:
	var placed: Array[Vector3i] = []
	for lx in range(CHUNK_SIZE):
		for lz in range(CHUNK_SIZE):
			var x := origin_x + lx
			var z := origin_z + lz
			var column := Vector2i(x, z)
			if not height_map.has(column):
				continue
			var biome_id := GameRegistry.biome_at(x, z)
			if not GameRegistry.biome_allows_trees(biome_id):
				continue
			if int(abs(sin(float(x * 71 + z * 97)) * 1000.0)) % 15 != 0:
				continue
			var ground_y := int(height_map[column])
			for trunk_y in range(ground_y, ground_y + 4):
				var pos := Vector3i(x, trunk_y, z)
				if set_block(pos, "oak_log"):
					placed.append(pos)
			for tlx in range(-2, 3):
				for tlz in range(-2, 3):
					if abs(tlx) + abs(tlz) <= 3:
						var leaf_pos := Vector3i(x + tlx, ground_y + 4, z + tlz)
						if set_block(leaf_pos, "leaf_block"):
							placed.append(leaf_pos)
			var top_pos := Vector3i(x, ground_y + 5, z)
			if set_block(top_pos, "leaf_block"):
				placed.append(top_pos)
	return placed

func _spawn_marker_blocks() -> Array[Vector3i]:
	var placed: Array[Vector3i] = []
	var markers := [
		[Vector3i(9, 7, 8), "workbench"],
		[Vector3i(10, 7, 8), "kiln"],
		[Vector3i(11, 7, 8), "chest"],
		[Vector3i(12, 7, 8), "glow_core"]
	]
	for entry in markers:
		var pos: Vector3i = entry[0]
		var block_id: String = entry[1]
		if set_block(pos, block_id):
			placed.append(pos)
	return placed

func _spawn_bonus_items() -> void:
	spawn_pickup("wood_pick", 1, Vector3(8.5, 8.5, 9.5))
	spawn_pickup("berry", 4, Vector3(9.5, 8.5, 9.5))
	spawn_pickup("charshard", 5, Vector3(10.5, 8.5, 9.5))
	spawn_pickup("wild_seed", 6, Vector3(11.5, 8.5, 9.5))

func world_to_block(world_position: Vector3) -> Vector3i:
	return Vector3i(floori(world_position.x / BLOCK_SIZE), floori(world_position.y / BLOCK_SIZE), floori(world_position.z / BLOCK_SIZE))

func has_block(block_position: Vector3i) -> bool:
	return blocks.has(block_position)

func get_block_id(block_position: Vector3i) -> String:
	return str(block_ids.get(block_position, GameRegistry.AIR))

func set_block(block_position: Vector3i, block_id: String) -> bool:
	if block_id == GameRegistry.AIR or block_id == "":
		remove_block(block_position)
		return false
	if blocks.has(block_position):
		remove_block(block_position)
	var block_data := GameRegistry.get_block(block_id)
	if not bool(block_data.get("solid", true)):
		return false
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
	block_ids[block_position] = block_id
	return true

func remove_block(block_position: Vector3i) -> void:
	if not blocks.has(block_position):
		return
	var body: Node = blocks[block_position]
	blocks.erase(block_position)
	block_ids.erase(block_position)
	body.queue_free()

func break_block_from_collider(collider: Object) -> Dictionary:
	if collider == null or not collider.has_meta("block_position"):
		return {}
	var block_position: Vector3i = collider.get_meta("block_position")
	var block_id := str(collider.get_meta("block_id"))
	remove_block(block_position)
	var coord := Vector2i(floori(float(block_position.x) / float(CHUNK_SIZE)), floori(float(block_position.z) / float(CHUNK_SIZE)))
	if chunk_nodes.has(coord):
		var list: Array = chunk_nodes[coord]
		list.erase(block_position)
	return {"drop": GameRegistry.block_drop(block_id), "block_id": block_id, "position": Vector3(block_position) + Vector3.ONE * 0.5}

func place_block_from_hit(hit_position: Vector3, hit_normal: Vector3, block_id: String) -> bool:
	if block_id == "" or not GameRegistry.BLOCKS.has(block_id):
		return false
	var target := world_to_block(hit_position + hit_normal * 0.51)
	if target.y < WORLD_FLOOR or target.y > 80:
		return false
	if has_block(target):
		return false
	var placed := set_block(target, block_id)
	if placed:
		var coord := Vector2i(floori(float(target.x) / float(CHUNK_SIZE)), floori(float(target.z) / float(CHUNK_SIZE)))
		if chunk_nodes.has(coord):
			var list: Array = chunk_nodes[coord]
			list.append(target)
	return placed

func spawn_pickup(item_id: String, amount: int, pos: Vector3) -> void:
	var pickup := PickupItem.new()
	pickup.setup(item_id, amount)
	pickup.global_position = pos
	get_parent().add_child(pickup)
