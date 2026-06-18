extends Area3D
class_name PickupItem

var item_id := "soil"
var amount := 1
var bob_seed := 0.0
var mesh_instance: MeshInstance3D

func setup(new_item_id: String, new_amount: int = 1) -> void:
	item_id = new_item_id
	amount = max(1, new_amount)

func _ready() -> void:
	bob_seed = randf() * 10.0
	monitoring = true
	monitorable = true
	add_to_group("pickups")
	_build_visual()
	body_entered.connect(_on_body_entered)

func _process(delta: float) -> void:
	rotation.y += delta * 1.8
	if mesh_instance != null:
		mesh_instance.position.y = 0.18 + sin(Time.get_ticks_msec() / 260.0 + bob_seed) * 0.08

func _build_visual() -> void:
	var shape := CollisionShape3D.new()
	var sphere := SphereShape3D.new()
	sphere.radius = 0.45
	shape.shape = sphere
	add_child(shape)

	mesh_instance = MeshInstance3D.new()
	var box := BoxMesh.new()
	box.size = Vector3(0.42, 0.42, 0.42)
	mesh_instance.mesh = box
	var mat := StandardMaterial3D.new()
	mat.albedo_color = GameRegistry.item_color(item_id)
	mat.roughness = 0.75
	mesh_instance.material_override = mat
	add_child(mesh_instance)

func _on_body_entered(body: Node) -> void:
	if body != null and body.has_method("collect_pickup"):
		body.call("collect_pickup", item_id, amount)
		queue_free()
