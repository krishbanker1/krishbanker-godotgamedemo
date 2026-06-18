extends CanvasLayer
class_name GameHud

var status_label: Label
var help_label: Label
var toast_label: Label
var toast_time := 0.0

func _ready() -> void:
	_build_labels()
	show_toast("TerraForge Phase 1 loaded")

func _process(delta: float) -> void:
	if toast_time > 0.0:
		toast_time -= delta
		if toast_time <= 0.0 and toast_label != null:
			toast_label.text = ""

func _build_labels() -> void:
	status_label = Label.new()
	status_label.name = "StatusLabel"
	status_label.anchor_left = 0.0
	status_label.anchor_top = 0.0
	status_label.anchor_right = 1.0
	status_label.anchor_bottom = 0.0
	status_label.offset_left = 16.0
	status_label.offset_top = 16.0
	status_label.offset_right = -16.0
	status_label.offset_bottom = 76.0
	status_label.text = "Loading..."
	add_child(status_label)

	help_label = Label.new()
	help_label.name = "HelpLabel"
	help_label.anchor_left = 0.0
	help_label.anchor_top = 0.0
	help_label.anchor_right = 1.0
	help_label.anchor_bottom = 0.0
	help_label.offset_left = 16.0
	help_label.offset_top = 80.0
	help_label.offset_right = -16.0
	help_label.offset_bottom = 136.0
	help_label.text = "Move: WASD/buttons | Break/Place | Next/Prev selects hotbar | Craft tries starter recipes"
	add_child(help_label)

	toast_label = Label.new()
	toast_label.name = "ToastLabel"
	toast_label.anchor_left = 0.5
	toast_label.anchor_top = 0.0
	toast_label.anchor_right = 0.5
	toast_label.anchor_bottom = 0.0
	toast_label.offset_left = -320.0
	toast_label.offset_top = 150.0
	toast_label.offset_right = 320.0
	toast_label.offset_bottom = 200.0
	toast_label.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_label.text = ""
	add_child(toast_label)

func update_status(selected_item: String, selected_number: int, inventory_text: String) -> void:
	if status_label == null:
		return
	var selected_name := GameRegistry.item_name(selected_item) if selected_item != "" else "Empty"
	status_label.text = "Selected %s: %s\n%s" % [selected_number, selected_name, inventory_text]

func show_toast(message: String, seconds: float = 2.25) -> void:
	if toast_label == null:
		return
	toast_label.text = message
	toast_time = seconds
