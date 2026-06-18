extends CanvasLayer

var player: Node
var move_value := Vector2.ZERO
var turn_value := 0.0

func _ready() -> void:
	player = get_node_or_null("../Player")
	_build_controls()

func _build_controls() -> void:
	_add_move_button("Forward", "▲", Vector2(110, -235), Vector2(0, -1))
	_add_move_button("Back", "▼", Vector2(110, -83), Vector2(0, 1))
	_add_move_button("Left", "◀", Vector2(34, -159), Vector2(-1, 0))
	_add_move_button("Right", "▶", Vector2(186, -159), Vector2(1, 0))
	_add_action_button("Jump", "Jump", Vector2(34, -315), "request_jump", false, Vector2(140, 64))

	_add_turn_button("TurnLeft", "Look ◀", Vector2(-320, -235), -1.0)
	_add_turn_button("TurnRight", "Look ▶", Vector2(-164, -235), 1.0)
	_add_action_button("Break", "Mine / Hit", Vector2(-320, -160), "request_break", true, Vector2(144, 64))
	_add_action_button("Place", "Place", Vector2(-164, -160), "request_place", true, Vector2(144, 64))
	_add_action_button("Prev", "Prev", Vector2(-320, -86), "select_previous_hotbar", true, Vector2(144, 58))
	_add_action_button("Next", "Next", Vector2(-164, -86), "select_next_hotbar", true, Vector2(144, 58))
	_add_action_button("Bag", "Bag", Vector2(-476, -86), "toggle_inventory", true, Vector2(144, 58))
	_add_action_button("Craft", "Craft", Vector2(-476, -160), "toggle_crafting", true, Vector2(144, 64))
	_add_action_button("Eat", "Eat", Vector2(-476, -235), "eat_selected_food", true, Vector2(144, 64))
	_add_action_button("Save", "Save", Vector2(-632, -86), "save_game", true, Vector2(144, 58))
	_add_action_button("Load", "Load", Vector2(-632, -160), "load_game", true, Vector2(144, 64))

func _button_style(button: Button, active: bool = false) -> void:
	var normal := StyleBoxFlat.new()
	normal.bg_color = Color(0.02, 0.025, 0.03, 0.52) if not active else Color(0.12, 0.10, 0.04, 0.70)
	normal.border_color = Color(1, 1, 1, 0.16) if not active else Color(1.0, 0.78, 0.22, 0.55)
	normal.border_width_left = 2
	normal.border_width_right = 2
	normal.border_width_top = 2
	normal.border_width_bottom = 2
	normal.corner_radius_top_left = 12
	normal.corner_radius_top_right = 12
	normal.corner_radius_bottom_left = 12
	normal.corner_radius_bottom_right = 12
	var pressed := normal.duplicate()
	pressed.bg_color = Color(0.25, 0.25, 0.25, 0.82)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("hover", pressed)
	button.add_theme_color_override("font_color", Color(0.96, 0.96, 0.90))

func _add_move_button(node_name: String, text: String, pos: Vector2, direction: Vector2) -> void:
	var button := Button.new()
	button.name = node_name
	button.text = text
	button.custom_minimum_size = Vector2(70, 70)
	button.anchor_top = 1.0
	button.anchor_bottom = 1.0
	button.offset_left = pos.x
	button.offset_top = pos.y
	button.offset_right = pos.x + 70
	button.offset_bottom = pos.y + 70
	_button_style(button)
	button.button_down.connect(func(): _set_move(direction))
	button.button_up.connect(func(): _set_move(Vector2.ZERO))
	add_child(button)

func _add_turn_button(node_name: String, text: String, pos: Vector2, direction: float) -> void:
	var button := Button.new()
	button.name = node_name
	button.text = text
	button.custom_minimum_size = Vector2(144, 64)
	button.anchor_left = 1.0
	button.anchor_top = 1.0
	button.anchor_right = 1.0
	button.anchor_bottom = 1.0
	button.offset_left = pos.x
	button.offset_top = pos.y
	button.offset_right = pos.x + 144
	button.offset_bottom = pos.y + 64
	_button_style(button)
	button.button_down.connect(func(): _set_turn(direction))
	button.button_up.connect(func(): _set_turn(0.0))
	add_child(button)

func _add_action_button(node_name: String, text: String, pos: Vector2, method_name: String, right_side: bool, size: Vector2) -> void:
	var button := Button.new()
	button.name = node_name
	button.text = text
	button.custom_minimum_size = size
	if right_side:
		button.anchor_left = 1.0
		button.anchor_right = 1.0
	button.anchor_top = 1.0
	button.anchor_bottom = 1.0
	button.offset_left = pos.x
	button.offset_top = pos.y
	button.offset_right = pos.x + size.x
	button.offset_bottom = pos.y + size.y
	_button_style(button, method_name == "request_break" or method_name == "request_place")
	button.pressed.connect(func(): _call_player(method_name))
	add_child(button)

func _process(_delta: float) -> void:
	if turn_value != 0.0:
		_call_player("add_mobile_look", Vector2(turn_value * 5.0, 0))

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
