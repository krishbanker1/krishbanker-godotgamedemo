extends Node
class_name GameManager

@onready var world: VoxelWorld = get_node_or_null("../World") as VoxelWorld
@onready var player: Node3D = get_node_or_null("../Player") as Node3D
@onready var sun: DirectionalLight3D = get_node_or_null("../Sun") as DirectionalLight3D
@onready var environment: WorldEnvironment = get_node_or_null("../WorldEnvironment") as WorldEnvironment

var day_time := 0.25
var day_length_seconds := 360.0
var spawn_timer := 3.0
var mob_cap := 16

func _ready() -> void:
	_setup_environment()
	_spawn_starting_mobs()

func _process(delta: float) -> void:
	_update_day_night(delta)
	_spawn_timer -= delta
	if spawn_timer <= 0.0:
		spawn_timer = 7.0
		_try_spawn_mob()

func _setup_environment() -> void:
	if environment != null:
		var env := Environment.new()
		env.background_mode = Environment.BG_COLOR
		env.background_color = Color(0.54, 0.72, 0.96)
		env.ambient_light_source = Environment.AMBIENT_SOURCE_COLOR
		env.ambient_light_color = Color(0.55, 0.62, 0.72)
		env.ambient_light_energy = 0.8
		environment.environment = env

func _update_day_night(delta: float) -> void:
	day_time = fmod(day_time + delta / day_length_seconds, 1.0)
	var sun_angle := day_time * TAU
	if sun != null:
		sun.rotation_degrees.x = -35.0 + sin(sun_angle) * 50.0
		sun.rotation_degrees.y = 35.0 + day_time * 360.0
		sun.light_energy = clamp(0.35 + sin(day_time * PI) * 1.85, 0.18, 2.0)
	if environment != null and environment.environment != null:
		var daylight := clamp(0.25 + sin(day_time * PI) * 0.75, 0.12, 1.0)
		environment.environment.background_color = Color(0.12 + daylight * 0.42, 0.17 + daylight * 0.55, 0.26 + daylight * 0.70)
		environment.environment.ambient_light_energy = 0.25 + daylight * 0.75
	if player != null and player.has_method("set_world_time"):
		player.call("set_world_time", day_time)

func _spawn_starting_mobs() -> void:
	for data in [
		["grazer", Vector3(12, 8, 12)],
		["mudsnout", Vector3(16, 8, 17)],
		["ashling", Vector3(26, 8, 18)],
		["boneguard", Vector3(20, 8, 28)]
	]:
		_spawn_mob(str(data[0]), data[1])

func _try_spawn_mob() -> void:
	if get_tree().get_nodes_in_group("mobs").size() >= mob_cap or player == null:
		return
	var hostile := day_time < 0.22 or day_time > 0.78
	var pool := ["grazer", "mudsnout"]
	if hostile:
		pool = ["ashling", "boneguard", "voidstalker"]
	var mob_id := str(pool[randi() % pool.size()])
	var angle := randf() * TAU
	var radius := randf_range(10.0, 20.0)
	var pos := player.global_position + Vector3(cos(angle) * radius, 8.0, sin(angle) * radius)
	_spawn_mob(mob_id, pos)

func _spawn_mob(mob_id: String, pos: Vector3) -> void:
	var mob := TerraMob.new()
	mob.setup(mob_id, player)
	mob.global_position = pos
	get_parent().add_child(mob)
