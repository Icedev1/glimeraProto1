# WeaponCard.gd
class_name WeaponCard
extends PanelContainer

signal pressed

@onready var weapon_name_label: Label = %weapon_name_label
@onready var attack_label: Label = %attack_label
@onready var cooldown_label: Label = %cooldown_label
@onready var hp_cost_label: Label = %hp_cost_label
@onready var description_label: Label = %description_label
@onready var click_area: Button = %click_area
@onready var cooldown_bar: ProgressBar = %cooldown_bar

@export var weapon: Weapon:
	set(w):
		weapon = w
		if is_node_ready(): _refresh()

@export var show_hp_cost: bool = false:
	set(v):
		show_hp_cost = v
		if is_node_ready(): _refresh()

func _ready() -> void:
	cooldown_bar.value = 0.0
	click_area.pressed.connect(func(): pressed.emit())
	_refresh()

func _refresh() -> void:
	if weapon == null:
		weapon_name_label.text = "(empty)"
		attack_label.text = ""
		cooldown_label.text = ""
		hp_cost_label.text = ""
		hp_cost_label.visible = false
		description_label.text = ""
		description_label.visible = false
		return
	weapon_name_label.text = weapon.weapon_name
	attack_label.text = "⚔  ATK:  %d" % weapon.attack_damage
	cooldown_label.text = "⏱  CD:    %.1fs" % weapon.cooldown
	hp_cost_label.text = "❤  Cost:  %d HP" % weapon.hp_cost
	hp_cost_label.visible = show_hp_cost
	var desc := weapon.get_description()
	description_label.text = desc
	description_label.visible = desc != ""

func set_on_cooldown(is_cooling: bool, remaining: float, total: float) -> void:
	modulate = Color(0.5, 0.5, 0.5) if is_cooling else Color.WHITE
	cooldown_bar.max_value = total
	cooldown_bar.value = remaining
