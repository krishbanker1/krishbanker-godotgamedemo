extends CanvasLayer

var player: Node
var move_value := Vector2.ZERO
var turn_value := 0.0

func _ready() -> void:
	player = get_node_or_null("../Player")
	_add_move_button("Forward", "W", Vector2(96, -224), Vector2(0, -1))
	_add_move_button("Back", "S", Vector2(96, -80), Vector2(0, 1))
	_add_move_button("Left", "A", Vector2(24, -152), Vector2(-1, 0))
	_add_move_button("Right", "D", Vector2(168, -152), Vector2(1, 0))
	_add_turn_button("TurnLeft", "<", Vector2(-300, -232), -1.0)
	_add_turn_button("TurnRight", ">", Vector2(-156, -232), 1.0)
	_add_action_button("Break", "Break", Vector2(-300, -160), "request_break")
	_add_action_button("Place", "Place", Vector2(-156, -160), "request_place")
	_add_action_button("Prev", "Prev", Vector2(-300, -88), "select_previous_hotbar")
	_add_action_button("Next", "Next", Vector2(-156, -88), "select_next_hotbar")
	_add_action_button("Jump", "Jump", Vector2(24, -296), "request_jump")
	_add_action_button("Craft", "Craft", Vector2(-300, -304), "request_craft_basic")
	_add_action_button("Smelt", "Smelt", Vector2(-156, -304), "request_smelting_basic")

func _add_move_button(node_name: String, text: String, pos: Vector2, direction: Vector2) -> void:
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

func _add_turn_button(node_name: String, text: String, pos: Vector2, direction: float) -> void:
	var button := Button.new()
	button.name = node_name
	button.text = text
	button.custom_minimum_size = Vector2(128, 64)
	button.anchor_left = 1.0
	button.anchor_top = 1.0
	button.anchor_right = 1.0
	button.anchor_bottom = 1.0
	button.offset_left = pos.x
	button.offset_top = pos.y
	button.offset_right = pos.x + 128
	button.offset_bottom = pos.y + 64
	button.button_down.connect(func(): _set_turn(direction))
	button.button_up.connect(func(): _set_turn(0.0))
	add_child(button)

func _add_action_button(node_name: String, text: String, pos: Vector2, method_name: String) -> void:
	var button := Button.new()
	button.name = node_name
	button.text = text
	button.custom_minimum_size = Vector2(128, 64)
	if pos.x < 0.0:
		button.anchor_left = 1.0
		button.anchor_right = 1.0
	button.anchor_top = 1.0
	button.anchor_bottom = 1.0
	button.offset_left = pos.x
	button.offset_top = pos.y
	button.offset_right = pos.x + 128
	button.offset_bottom = pos.y + 64
	button.pressed.connect(func(): _call_player(method_name))
	add_child(button)

func _process(_delta: float) -> void:
	if turn_value != 0.0:
		_call_player("add_mobile_look", Vector2(turn_value * 5.0, 0))
	elif Input.is_key_pressed(KEY_Q):
		_call_player("add_mobile_look", Vector2(-4, 0))
	elif Input.is_key_pressed(KEY_E):
		_call_player("add_mobile_look", Vector2(4, 0))

func _set_move(direction: Vector2) -> void:
	move_value = direction
	_call_player("set_mobile_move", move_value)

func _set_turn(direction: float) -> void:
	turn_value = direction

func _call_player(method_name: String, value = null) -> void:
	if player == null or not player.has_method(method_name):
		return
	if value == null:
		player.call(method_name)
	else:
		player.call(method_name, value)
