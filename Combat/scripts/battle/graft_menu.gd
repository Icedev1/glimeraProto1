# GraftMenu.gd
# Click an equipped slot → inventory weapons become clickable → click one to swap
extends Control

signal graft_finished(swaps: Array[Dictionary])
signal graft_cancelled

@onready var equipped_cards: Array[WeaponCard] = [
	%equipped_card_1, %equipped_card_2, %equipped_card_3, %equipped_card_4
]
@onready var inventory_list: Container = %inventory_list
@onready var hp_cost_label: Label = %hp_cost_label
@onready var graft_btn: Button = %graft_btn
@onready var cancel_btn: Button = %cancel_btn

@export var weapon_card_scene: PackedScene

# ── State ─────────────────────────────────────────────────────────────────────
var _working_equipped: Array[Weapon] = []
var _working_inventory: Array[Weapon] = []
var _original_equipped: Array[Weapon] = []

var _selected_slot: int = -1 # -1 = nothing is selected

func _ready() -> void:
	graft_btn.pressed.connect(_on_done)
	cancel_btn.pressed.connect(_on_cancel)
	for i in range(equipped_cards.size()):
		var slot := i
		equipped_cards[i].pressed.connect(_on_equipped_slot_pressed.bind(slot))

func open() -> void:
	_original_equipped = BattleManager._equipped.duplicate()
	_working_equipped = BattleManager._equipped.duplicate()
	_working_inventory = BattleManager._inventory.duplicate()
	_selected_slot = -1
	_refresh()
	show()

func _refresh() -> void:
	_refresh_equipped()
	_refresh_inventory()
	_refresh_hp_cost()

# ── Equipped cards ────────────────────────────────────────────────────────────
func _refresh_equipped() -> void:
	for i in range(equipped_cards.size()):
		var card := equipped_cards[i]
		card.weapon = _working_equipped[i]
		card.show_hp_cost = true
		if i == _selected_slot:
			card.modulate = Color.YELLOW
		elif _working_equipped[i] != _original_equipped[i]:
			card.modulate = Color.CYAN
		else:
			card.modulate = Color.WHITE

func _on_equipped_slot_pressed(slot: int) -> void:
	if _selected_slot == slot:
		_selected_slot = -1
	else:
		_selected_slot = slot
	_refresh()

# ── Inventory list ────────────────────────────────────────────────────────────
func _refresh_inventory() -> void:
	for child in inventory_list.get_children():
		child.queue_free()
	for w in _working_inventory:
		var card: WeaponCard = weapon_card_scene.instantiate()
		card.weapon = w
		card.show_hp_cost = true
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if _selected_slot == -1:
			card.modulate = Color(0.5, 0.5, 0.5)
		inventory_list.add_child(card)
		card.pressed.connect(_on_inventory_weapon_pressed.bind(w))

func _on_inventory_weapon_pressed(w: Weapon) -> void:
	if _selected_slot == -1:
		return
	var old_weapon: Weapon = _working_equipped[_selected_slot]
	_working_equipped[_selected_slot] = w
	_working_inventory.erase(w)
	if old_weapon:
		_working_inventory.append(old_weapon)
	_selected_slot = -1
	_refresh()

# ── HP cost ───────────────────────────────────────────────────────────────────
func _refresh_hp_cost() -> void:
	var total_cost := _calculate_total_hp_cost()
	hp_cost_label.text = "HP Cost: %d" % total_cost
	if total_cost >= PlayerManager.data.current_hp:
		hp_cost_label.modulate = Color.RED
	else:
		hp_cost_label.modulate = Color.WHITE

func _calculate_total_hp_cost() -> int:
	var cost := 0
	for i in range(_working_equipped.size()):
		var new_weapon: Weapon = _working_equipped[i]
		var old_weapon: Weapon = _original_equipped[i]
		if new_weapon != old_weapon and new_weapon != null:
			cost += new_weapon.hp_cost
	return cost

# ── Confirm / Cancel ──────────────────────────────────────────────────────────
func _on_done() -> void:
	var swaps: Array[Dictionary] = []
	for i in range(_working_equipped.size()):
		if _working_equipped[i] != _original_equipped[i]:
			swaps.append({ "slot": i, "new_weapon": _working_equipped[i] })
	hide()
	graft_finished.emit(swaps)

func _on_cancel() -> void:
	_selected_slot = -1
	hide()
	graft_cancelled.emit()
