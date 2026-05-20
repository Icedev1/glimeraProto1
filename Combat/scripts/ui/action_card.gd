# ActionCard.gd
class_name ActionCard
extends PanelContainer

signal pressed

@onready var action_name_label: Label = %action_name_label
@onready var cooldown_label: Label = %cooldown_label
@onready var description_label: Label = %description_label
@onready var click_area: Button = %click_area
@onready var cooldown_bar: ProgressBar = %cooldown_bar
@onready var action_icon: TextureRect = %action_icon

@export var icon: Texture2D:
	set(v):
		icon = v
		if is_node_ready(): _refresh()

@export var action_name: String = "Action":
	set(v):
		action_name = v
		if is_node_ready(): _refresh()

@export var cooldown_duration: float = 1.0:
	set(v):
		cooldown_duration = v
		if is_node_ready(): _refresh()

@export var description: String = "":
	set(v):
		description = v
		if is_node_ready(): _refresh()

func _ready() -> void:
	cooldown_bar.value = 0.0
	click_area.pressed.connect(func(): pressed.emit())
	if action_icon:
		action_icon.expand_mode = TextureRect.EXPAND_IGNORE_SIZE
		action_icon.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		action_icon.custom_minimum_size = Vector2(80, 80)
	_refresh()

func _refresh() -> void:
	action_name_label.text = action_name
	if action_icon:
		action_icon.texture = icon
	cooldown_label.text = "⏱  CD:  %.1fs" % cooldown_duration
	description_label.text = description
	description_label.visible = description != ""

func set_on_cooldown(is_cooling: bool, remaining: float, total: float) -> void:
	modulate = Color(0.5, 0.5, 0.5) if is_cooling else Color.WHITE
	cooldown_bar.max_value = total
	cooldown_bar.value = remaining
