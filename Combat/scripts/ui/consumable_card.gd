# ConsumableCard.gd
class_name ConsumableCard
extends PanelContainer

signal use_pressed
signal next_pressed
signal prev_pressed

@onready var consumable_name_label: Label = %consumable_name_label
@onready var cooldown_label: Label = %cooldown_label
@onready var description_label: Label = %description_label
@onready var use_btn: Button = %use_btn
@onready var next_btn: Button = %next_btn
@onready var prev_btn: Button = %prev_btn
@onready var cooldown_bar: ProgressBar = %cooldown_bar

@export var cooldown_duration: float = 7.0

func _ready() -> void:
	cooldown_bar.value = 0.0
	use_btn.pressed.connect(func(): use_pressed.emit())
	next_btn.pressed.connect(func(): next_pressed.emit())
	prev_btn.pressed.connect(func(): prev_pressed.emit())

func display(consumable: Consumable) -> void:
	if consumable == null:
		consumable_name_label.text = "empty"
		cooldown_label.text = ""
		description_label.text = ""
		description_label.visible = false
		return
	consumable_name_label.text = "%s (%d)" % [consumable.consumable_name, consumable.quantity]
	cooldown_label.text = "⏱  CD:  %.1fs" % cooldown_duration
	description_label.text = consumable.battle_description
	description_label.visible = consumable.battle_description != ""

func set_on_cooldown(is_cooling: bool, remaining: float, total: float) -> void:
	modulate = Color(0.5, 0.5, 0.5) if is_cooling else Color.WHITE
	cooldown_bar.max_value = total
	cooldown_bar.value = remaining

func set_empty() -> void:
	modulate = Color(0.5, 0.5, 0.5)
	consumable_name_label.text = "(empty)"
	cooldown_label.text = ""
	description_label.text = ""
	description_label.visible = false
