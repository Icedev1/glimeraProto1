# GraftMenu.gd
extends Control

signal graft_finished(swaps: Array[Dictionary])
signal graft_cancelled

@onready var equipped_cards: Array[WeaponCard] = [
	%equipped_card_1, %equipped_card_2
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

var _selected_slot: int = -1  # -1 = nothing is selected

# ── Controller navigation state ──────────────────────────────────────────────
enum GraftFocus { EQUIPPED, INVENTORY }
var _focus_mode: GraftFocus = GraftFocus.EQUIPPED
var _equipped_focus: int = 0     # Which equipped slot is highlighted (0 or 1)
var _inventory_focus: int = 0    # Which inventory card is highlighted

func _ready() -> void:
	graft_btn.pressed.connect(_on_done)
	cancel_btn.pressed.connect(_on_cancel)
	# Disable Godot's focus system so it doesn't steal D-pad input
	graft_btn.focus_mode = Control.FOCUS_NONE
	cancel_btn.focus_mode = Control.FOCUS_NONE
	for i in range(equipped_cards.size()):
		var slot := i
		equipped_cards[i].pressed.connect(_on_equipped_slot_pressed.bind(slot))
		equipped_cards[i].focus_mode = Control.FOCUS_NONE
		equipped_cards[i].click_area.focus_mode = Control.FOCUS_NONE

func open() -> void:
	_original_equipped = BattleManager._equipped.duplicate()
	_working_equipped = BattleManager._equipped.duplicate()
	_working_inventory = BattleManager._inventory.duplicate()
	_selected_slot = -1
	_focus_mode = GraftFocus.EQUIPPED
	_equipped_focus = 0
	_inventory_focus = 0
	_refresh()
	show()

func _refresh() -> void:
	_refresh_equipped()
	_refresh_inventory()
	_refresh_hp_cost()
	_refresh_focus_visuals()

# ── Controller input ──────────────────────────────────────────────────────────
func _unhandled_input(event: InputEvent) -> void:
	if not visible:
		return

	# Y = confirm graft
	if event.is_action_pressed("graft_confirm"):
		_on_done()
		get_viewport().set_input_as_handled()
		return

	# X = cancel graft
	if event.is_action_pressed("graft_cancel"):
		_on_cancel()
		get_viewport().set_input_as_handled()
		return

	if _focus_mode == GraftFocus.EQUIPPED:
		_handle_equipped_input(event)
	elif _focus_mode == GraftFocus.INVENTORY:
		_handle_inventory_input(event)

const GRID_COLUMNS: int = 6
const NAV_COOLDOWN: float = 0.15  # Seconds between analog navigation inputs
var _nav_timer: float = 0.0

func _process(delta: float) -> void:
	if not visible:
		return
	if _nav_timer > 0.0:
		_nav_timer -= delta

func _can_navigate(event: InputEvent) -> bool:
	# Only apply cooldown to analog stick — D-pad and keyboard fire once per press
	if event is InputEventJoypadMotion:
		if _nav_timer > 0.0:
			return false
		_nav_timer = NAV_COOLDOWN
	return true

func _handle_equipped_input(event: InputEvent) -> void:
	# Navigate between equipped slots
	if event.is_action_pressed("ui_left") and _can_navigate(event):
		_equipped_focus = 0
		_refresh_focus_visuals()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_right") and _can_navigate(event):
		_equipped_focus = 1
		_refresh_focus_visuals()
		get_viewport().set_input_as_handled()
	# A = select this equipped slot (enter inventory browsing)
	elif event.is_action_pressed("graft_select"):
		_on_equipped_slot_pressed(_equipped_focus)
		get_viewport().set_input_as_handled()

func _handle_inventory_input(event: InputEvent) -> void:
	var card_count := inventory_list.get_child_count()
	if card_count == 0:
		if event.is_action_pressed("graft_back"):
			_focus_mode = GraftFocus.EQUIPPED
			_selected_slot = -1
			_refresh()
			get_viewport().set_input_as_handled()
		return

	# Navigate inventory — left/right move by 1, up/down move by row (clamped)
	if event.is_action_pressed("ui_left") and _can_navigate(event):
		var new_focus := _inventory_focus - 1
		if new_focus >= 0:
			_inventory_focus = new_focus
			_refresh_focus_visuals()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_right") and _can_navigate(event):
		var new_focus := _inventory_focus + 1
		if new_focus < card_count:
			_inventory_focus = new_focus
			_refresh_focus_visuals()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_up") and _can_navigate(event):
		var new_focus := _inventory_focus - GRID_COLUMNS
		if new_focus >= 0:
			_inventory_focus = new_focus
			_refresh_focus_visuals()
		get_viewport().set_input_as_handled()
	elif event.is_action_pressed("ui_down") and _can_navigate(event):
		var new_focus := _inventory_focus + GRID_COLUMNS
		if new_focus < card_count:
			_inventory_focus = new_focus
			_refresh_focus_visuals()
		get_viewport().set_input_as_handled()
	# A = pick this inventory weapon
	elif event.is_action_pressed("graft_select"):
		var card: WeaponCard = inventory_list.get_child(_inventory_focus)
		if card and card.weapon:
			_on_inventory_weapon_pressed(card.weapon)
			_focus_mode = GraftFocus.EQUIPPED
			_refresh_focus_visuals()
		get_viewport().set_input_as_handled()
	# B = go back to equipped slots
	elif event.is_action_pressed("graft_back"):
		_focus_mode = GraftFocus.EQUIPPED
		_selected_slot = -1
		_refresh()
		get_viewport().set_input_as_handled()

# ── Focus visuals ─────────────────────────────────────────────────────────────
const BORDER_NODE_NAME := "_focus_border"
const BORDER_WIDTH: int = 3
const BORDER_COLOR: Color = Color.BLACK

func _add_focus_border(card: PanelContainer) -> void:
	if card.has_node(BORDER_NODE_NAME):
		return
	var border := ReferenceRect.new()
	border.name = BORDER_NODE_NAME
	border.editor_only = false
	border.border_color = BORDER_COLOR
	border.border_width = BORDER_WIDTH
	border.mouse_filter = Control.MOUSE_FILTER_IGNORE
	border.set_anchors_preset(Control.PRESET_FULL_RECT)
	card.add_child(border)

func _remove_focus_border(card: PanelContainer) -> void:
	var border := card.get_node_or_null(BORDER_NODE_NAME)
	if border:
		border.queue_free()

func _refresh_focus_visuals() -> void:
	# Equipped cards
	for i in range(equipped_cards.size()):
		var card := equipped_cards[i]
		var is_focused := _focus_mode == GraftFocus.EQUIPPED and i == _equipped_focus
		if is_focused:
			_add_focus_border(card)
		else:
			_remove_focus_border(card)
		if i == _selected_slot:
			card.modulate = Color.YELLOW
		elif _working_equipped[i] != _original_equipped[i]:
			card.modulate = Color.CYAN
		elif is_focused:
			card.modulate = Color(1.0, 1.0, 0.6)
		else:
			card.modulate = Color.WHITE

	# Inventory cards
	for i in range(inventory_list.get_child_count()):
		var card: WeaponCard = inventory_list.get_child(i)
		var is_focused := _focus_mode == GraftFocus.INVENTORY and i == _inventory_focus
		if is_focused:
			_add_focus_border(card)
		else:
			_remove_focus_border(card)
		if _selected_slot == -1:
			card.modulate = Color(0.5, 0.5, 0.5)
		elif is_focused:
			card.modulate = Color(1.0, 1.0, 0.6)
		else:
			card.modulate = Color.WHITE

# ── Equipped cards ────────────────────────────────────────────────────────────
func _refresh_equipped() -> void:
	for i in range(equipped_cards.size()):
		var card := equipped_cards[i]
		card.weapon = _working_equipped[i]
		card.show_hp_cost = true

func _on_equipped_slot_pressed(slot: int) -> void:
	if _selected_slot == slot:
		_selected_slot = -1
		_focus_mode = GraftFocus.EQUIPPED
	else:
		_selected_slot = slot
		_focus_mode = GraftFocus.INVENTORY
		_inventory_focus = 0
	_refresh()

# ── Inventory list (filtered by limb type) ────────────────────────────────────
func _refresh_inventory() -> void:
	for child in inventory_list.get_children():
		child.free()

	for w in _working_inventory:
		var card: WeaponCard = weapon_card_scene.instantiate()
		card.weapon = w
		card.show_hp_cost = true
		card.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		card.focus_mode = Control.FOCUS_NONE

		if _selected_slot == -1:
			# No slot selected — show all greyed out
			card.modulate = Color(0.5, 0.5, 0.5)
			inventory_list.add_child(card)
			card.click_area.focus_mode = Control.FOCUS_NONE
			card.pressed.connect(_on_inventory_weapon_pressed.bind(w))
		else:
			# A slot is selected — only show weapons matching the slot's limb type
			var slot_is_arm: bool = _selected_slot == BattleManager.SLOT_ARM
			if w.is_arm == slot_is_arm:
				card.modulate = Color.WHITE
				inventory_list.add_child(card)
				card.click_area.focus_mode = Control.FOCUS_NONE
				card.pressed.connect(_on_inventory_weapon_pressed.bind(w))
			else:
				# Don't show weapons of wrong limb type at all
				card.queue_free()

func _on_inventory_weapon_pressed(w: Weapon) -> void:
	if _selected_slot == -1:
		return
	var slot_is_arm: bool = _selected_slot == BattleManager.SLOT_ARM
	if w.is_arm != slot_is_arm:
		return

	var old_weapon: Weapon = _working_equipped[_selected_slot]
	_working_equipped[_selected_slot] = w
	_working_inventory.erase(w)
	if old_weapon:
		_working_inventory.append(old_weapon)
	_selected_slot = -1
	_refresh.call_deferred()  

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
