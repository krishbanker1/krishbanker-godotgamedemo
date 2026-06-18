extends CanvasLayer

var player: Node
var move_value: Vector2 = Vector2.ZERO
var turn_value: float = 0.0

func _ready() -> void:
	player = get_node_or_null("../Player")
	_build_controls()

func _build_controls() -> void:
	# Left movement cluster. Kept away from the hotbar so the bottom center stays readable.
	_add_move_button("Forward", "▲", Vector2(92, -245), Vector2(0, -1), Vector2(62, 62))
	_add_move_button("Back", "▼", Vector2(92, -105), Vector2(0, 1), Vector2(62, 62))
	_add_move_button("Left", "◀", Vector2(24, -175), Vector2(-1, 0), Vector2(62, 62))
	_add_move_button("Right", "▶", Vector2(160, -175), Vector2(1, 0), Vector2(62, 62))
	_add_action_button("Jump", "Jump", Vector2(42, -318), "request_jump", false, Vector2(130, 54), false)

	# Right action cluster. Similar functional placement to mobile voxel games, but original styling.
	_add_turn_button("TurnLeft", "Look ◀", Vector2(-330, -318), -1.0, Vector2(142, 54))
	_add_turn_button("TurnRight", "Look ▶", Vector2(-176, -318), 1.0, Vector2(142, 54))
	_add_action_button("Break", "Mine", Vector2(-330, -252), "request_break", true, Vector2(142, 58), true)
	_add_action_button("Place", "Place", Vector2(-176, -252), "request_place", true, Vector2(142, 58), true)
	_add_action_button("Bag", "Bag", Vector2(-330, -186), "toggle_inventory", true, Vector2(90, 52), false)
	_add_action_button("Craft", "Craft", Vector2(-232, -186), "toggle_crafting", true, Vector2(90, 52), false)
	_add_action_button("Eat", "Eat", Vector2(-134, -186), "eat_selected_food", true, Vector2(90, 52), false)
	_add_action_button("Prev", "Prev", Vector2(-330, -122), "select_previous_hotbar", true, Vector2(142, 52), false)
	_add_action_button("Next", "Next", Vector2(-176, -122), "select_next_hotbar", true, Vector2(142, 52), false)

	# Small utility buttons, not on top of hotbar.
	_add_action_button("Save", "Save", Vector2(-330, -382), "save_game", true, Vector2(142, 46), false)
	_add_action_button("Load", "Load", Vector2(-176, -382), "load_game", true, Vector2(142, 46), false)

func _button_style(button: Button, active: bool = false) -> void:
	var normal: StyleBoxFlat = StyleBoxFlat.new()
	normal.bg_color = Color(0.02, 0.024, 0.028, 0.50) if not active else Color(0.11, 0.09, 0.035, 0.64)
	normal.border_color = Color(1, 1, 1, 0.18) if not active else Color(1.0, 0.78, 0.22, 0.68)
	normal.border_width_left = 2
	normal.border_width_right = 2
	normal.border_width_top = 2
	normal.border_width_bottom = 2
	normal.corner_radius_top_left = 6
	normal.corner_radius_top_right = 6
	normal.corner_radius_bottom_left = 6
	normal.corner_radius_bottom_right = 6
	var pressed: StyleBoxFlat = normal.duplicate() as StyleBoxFlat
	pressed.bg_color = Color(0.25, 0.25, 0.25, 0.82)
	button.add_theme_stylebox_override("normal", normal)
	button.add_theme_stylebox_override("pressed", pressed)
	button.add_theme_stylebox_override("hover", pressed)
	button.add_theme_color_override("font_color", Color(0.96, 0.96, 0.90))
	button.add_theme_font_size_override("font_size", 13)

func _add_move_button(node_name: String, text: String, pos: Vector2, direction: Vector2, size: Vector2) -> void:
	var button: Button = Button.new()
	button.name = node_name
	button.text = text
	button.custom_minimum_size = size
	button.anchor_top = 1.0
	button.anchor_bottom = 1.0
	button.offset_left = pos.x
	button.offset_top = pos.y
	button.offset_right = pos.x + size.x
	button.offset_bottom = pos.y + size.y
	_button_style(button)
	button.button_down.connect(func() -> void: _set_move(direction))
	button.button_up.connect(func() -> void: _set_move(Vector2.ZERO))
	add_child(button)

func _add_turn_button(node_name: String, text: String, pos: Vector2, direction: float, size: Vector2) -> void:
	var button: Button = Button.new()
	button.name = node_name
	button.text = text
	button.custom_minimum_size = size
	button.anchor_left = 1.0
	button.anchor_top = 1.0
	button.anchor_right = 1.0
	button.anchor_bottom = 1.0
	button.offset_left = pos.x
	button.offset_top = pos.y
	button.offset_right = pos.x + size.x
	button.offset_bottom = pos.y + size.y
	_button_style(button)
	button.button_down.connect(func() -> void: _set_turn(direction))
	button.button_up.connect(func() -> void: _set_turn(0.0))
	add_child(button)

func _add_action_button(node_name: String, text: String, pos: Vector2, method_name: String, right_side: bool, size: Vector2, active: bool) -> void:
	var button: Button = Button.new()
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
	_button_style(button, active)
	button.pressed.connect(func() -> void: _call_player(method_name))
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
