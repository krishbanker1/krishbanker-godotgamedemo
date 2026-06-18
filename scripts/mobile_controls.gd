extends CanvasLayer

var player: Node
var move_value := Vector2.ZERO

func _ready() -> void:
	player = get_node_or_null("../Player")
	_add_button("Forward", "W", Vector2(96, -152), Vector2(0, -1))
	_add_button("Back", "S", Vector2(96, -72), Vector2(0, 1))
	_add_button("Left", "A", Vector2(24, -72), Vector2(-1, 0))
	_add_button("Right", "D", Vector2(168, -72), Vector2(1, 0))
	_add_action_button("Break", "Break", Vector2(-280, -96), "request_break")
	_add_action_button("Place", "Place", Vector2(-144, -96), "request_place")

func _add_button(node_name: String, text: String, pos: Vector2, direction: Vector2) -> void:
	var button := Button.new()
	button.name = node_name
	button.text = text
	button.custom_minimum_size = Vector2(64, 64)
	button.anchor_top = 1.0
	button.anchor_bottom = 1.0
	button.offset_left = pos.x
	button.offset_top = pos.y
	button.offset_right = pos.x + 64
	button.offset_bottom = pos.y + 64
	button.button_down.connect(func(): _set_move(direction))
	button.button_up.connect(func(): _set_move(Vector2.ZERO))
	add_child(button)

func _add_action_button(node_name: String, text: String, pos: Vector2, method_name: StringName) -> void:
	var button := Button.new()
	button.name = node_name
	button.text = text
	button.custom_minimum_size = Vector2(120, 64)
	button.anchor_left = 1.0
	button.anchor_top = 1.0
	button.anchor_right = 1.0
	button.anchor_bottom = 1.0
	button.offset_left = pos.x
	button.offset_top = pos.y
	button.offset_right = pos.x + 120
	button.offset_bottom = pos.y + 64
	button.pressed.connect(func(): _call_player(method_name))
	add_child(button)

func _process(_delta: float) -> void:
	if Input.is_key_pressed(KEY_Q):
		_call_player("add_mobile_look", Vector2(-4, 0))
	elif Input.is_key_pressed(KEY_E):
		_call_player("add_mobile_look", Vector2(4, 0))

func _set_move(direction: Vector2) -> void:
	move_value = direction
	_call_player("set_mobile_move", move_value)

func _call_player(method_name: StringName, value = null) -> void:
	if player == null or not player.has_method(method_name):
		return
	if value == null:
		player.call(method_name)
	else:
		player.call(method_name, value)
