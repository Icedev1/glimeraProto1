extends "res://Combat/scripts/battle/battle_Scene.gd"

const TutorialOverlayScene := preload("res://Combat/scenes/tutorial_overlay.tscn")

var _tutorial_overlay
var _damage_tutorial_done: bool = false
var _consumable_tutorial_done: bool = false
var _graft_tutorial_done: bool = false

var _saved_arm_idx: int = 0
var _saved_leg_idx: int = 0

# Input gates
var _attacks_enabled: bool = true
var _consumables_enabled: bool = false
var _graft_enabled: bool = false

# State
var _waiting_for_consumable_use: bool = false
var _graft_menu_tutorial_active: bool = false

@onready var _consumables_section: VBoxContainer = $Battle_UI/options_menu/Consumables
@onready var _graft_section: VBoxContainer = $Battle_UI/options_menu/Graft
@onready var attack_timer_card: PanelContainer = %AttackTimerCard


# ── Lifecycle ─────────────────────────────────────────────────────────────────
func _ready() -> void:
	# Force default limbs for this tutorial battle 
	_saved_arm_idx = GraftGlobals.right_arm_graft_index
	_saved_leg_idx = GraftGlobals.left_leg_graft_index
	GraftGlobals.right_arm_graft_index = 0
	GraftGlobals.left_leg_graft_index = 0

	super._ready()

	# change player model to have the default attacks
	BattleManager.equipped_weapon_changed.emit(0, PlayerManager.data.equipped[0])
	BattleManager.equipped_weapon_changed.emit(1, PlayerManager.data.equipped[1])

	# Consumables + graft are hidden until the tutorial reveals them
	_consumables_section.visible = false
	_graft_section.visible = false
	_set_consumables_enabled(false)
	_set_graft_enabled(false)

	_tutorial_overlay = TutorialOverlayScene.instantiate()
	add_child(_tutorial_overlay)

	BattleManager.player_hit.connect(_on_player_hit_tutorial)
	BattleManager.battle_ended.connect(_on_battle_ended_tutorial)
	consumable_card.use_pressed.connect(_on_consumable_used)

	if BattleManager.graft_requested.is_connected(_on_graft_requested):
		BattleManager.graft_requested.disconnect(_on_graft_requested)
	BattleManager.graft_requested.connect(_on_graft_requested_tutorial)

	_run_intro()

func _input(event: InputEvent) -> void:
	# Block keyboard / joypad during the graft menu tutorial popups
	if _graft_menu_tutorial_active:
		if event is InputEventKey or event is InputEventJoypadButton:
			get_viewport().set_input_as_handled()

func _unhandled_input(event: InputEvent) -> void:
	if result_screen.visible:
		if event.is_action_pressed("graft_select"):
			_on_continue_pressed()
		return
	if graft_menu.visible:
		return
	if _attacks_enabled:
		if event.is_action_pressed("attack1"): BattleManager.player_attack(0)
		if event.is_action_pressed("attack2"): BattleManager.player_attack(1)
		if event.is_action_pressed("block"):   BattleManager.player_block()
	if _consumables_enabled:
		if event.is_action_pressed("use_consumable"):
			BattleManager.player_use_consumable()
			_on_consumable_used()
		if event.is_action_pressed("next_consumable"):     BattleManager.player_next_consumable()
		if event.is_action_pressed("previous_consumable"): BattleManager.player_prev_consumable()
	if _graft_enabled:
		if event.is_action_pressed("graft"): BattleManager.player_graft()

# ── Intro  ───────────────────────────────────────
func _run_intro() -> void:
	_set_attacks_enabled(false)
	BattleManager.set_paused(true)
	await get_tree().process_frame
	_tutorial_overlay.show_step(
		"Tutorial loadout",
		"For this tutorial, you're starting with your default limbs equipped.",
		true, [weapon_cards[0], weapon_cards[1]])
	await _tutorial_overlay.next_pressed
	_tutorial_overlay.hide() 
	BattleManager.set_paused(false)
	_set_attacks_enabled(true)

# ── Damage tutorial, first enemy hit ────────────────────────────────────────
func _on_player_hit_tutorial(damage: int, was_blocked: bool) -> void:
	if _damage_tutorial_done:
		return
	_damage_tutorial_done = true
	_set_attacks_enabled(false)
	BattleManager.set_paused(true)
	await get_tree().process_frame
	_run_damage_tutorial(damage, was_blocked)

func _run_damage_tutorial(damage: int, was_blocked: bool) -> void:
	var enemy_name := BattleManager.enemy.unit_name
	var enemy_element_name := Weapon.element_name(BattleManager.enemy.element)
	var attack_highlights: Array = [weapon_cards[0], weapon_cards[1]]
	var attack_elements: Array = [weapon_cards[0].description_label, weapon_cards[1].description_label]

	
	# 1. "You took damage" adapt text if the player blocked
	var step1_title: String
	var step1_body: String
	if was_blocked:
		var original := int(round(float(damage) / (1.0 - BattleManager.BLOCK_REDUCTION)))
		step1_title = "Nice block!"
		step1_body = "You blocked the hit, took %d damage instead of %d. Still a heavy hit, let's see why this enemy is so dangerous." % [damage, original]
	else:
		step1_title = "Ouch!"
		step1_body = "The %s hit you for %d damage. That's a lot, let's see why." % [enemy_name, damage]
	_tutorial_overlay.show_step(step1_title, step1_body, true, player_hp_bar)
	await _tutorial_overlay.next_pressed

	# 2. Enemy info, type vs attack-type 
	_tutorial_overlay.show_step(
		"Know your enemy",
		"Meet %s a %s type enemy that uses %s attacks.\n(An enemy's type and its attacks can have different elements, but here they match.)" % [enemy_name, enemy_element_name, enemy_element_name],
		true, enemy_name_label)
	await _tutorial_overlay.next_pressed

	# 2b. Enemy attack timer
	_tutorial_overlay.show_step(
		"Next attack",
		"This shows the enemy's next attack, its name, its element, and how long until it lands.",
		true, attack_timer_card)
	await _tutorial_overlay.next_pressed

	

	# 3. Defensive matchup, both limbs affect it
	_tutorial_overlay.show_step(
		"Defensive matchup 1",
		"When an enemy attacks, the damage you take is decided by the combination of your equipped limbs' elements. 
		Since both of your limbs are rock and you're getting attacked by paper, you take more damage." % enemy_element_name,
		true)
	await _tutorial_overlay.next_pressed

	_tutorial_overlay.show_step(
		"Defensive matchup 2",
		"To make it easier to see how much damage you take you can look at the outline around the block button. The colour of the outline shows you if you take more, less, or neutral damage." % enemy_element_name,
		true,block_card)
	await _tutorial_overlay.next_pressed

	# 4. Offensive matchup, your attacking limb vs enemy type
	_tutorial_overlay.show_step(
		"Offensive matchup 1",
		"When you attack, the damage you do is decided by each individual equipped limb's element." % enemy_element_name,
		true)
	await _tutorial_overlay.next_pressed

	_tutorial_overlay.show_step(
		"Offensive matchup 2",
		"Right now you have two rock limbs equipped and you're attacking a paper type enemy, this means that both limbs individually do less damage." % enemy_element_name,
		true,attack_elements)
	await _tutorial_overlay.next_pressed

	_tutorial_overlay.show_step(
		"Offensive matchup 3",
		"If you had one rock limb and one scissors limb, the rock limb would still do less damage while the scissors limb would do more damage." % enemy_element_name,
		true)
	await _tutorial_overlay.next_pressed

	_tutorial_overlay.show_step(
		"Offensive matchup 4",
		"Again, to make it easier to see how much damage you do you can look at the outlines around the attack buttons. The colour of the outline shows you if you do more, less, or neutral damage." % enemy_element_name,
		true, attack_highlights)
	await _tutorial_overlay.next_pressed


	# 5. Heal up
	_consumables_section.visible = true
	_set_consumables_enabled(true)
	_waiting_for_consumable_use = true
	# Wait two frames so consumable_card has a settled global rect before highlighting
	await get_tree().process_frame
	await get_tree().process_frame
	_tutorial_overlay.show_step(
		"Heal up!",
		"Click here to use a consumable or use the shortcut shown above it. The card shows the heal amount and how many you have left",
		false, consumable_card)

# ── Consumable use detection ─────────────────────────────────────────────────
func _on_consumable_used() -> void:
	if not _waiting_for_consumable_use or _consumable_tutorial_done:
		return
	_consumable_tutorial_done = true
	_waiting_for_consumable_use = false
	_run_graft_prompt()

func _run_graft_prompt() -> void:
	_graft_section.visible = true
	_set_graft_enabled(true)
	# Wait two frames so graft_card has a settled global rect before highlighting
	await get_tree().process_frame
	await get_tree().process_frame
	_tutorial_overlay.show_step(
		"Now swap limbs",
		"Rock limbs aren't great against a Paper enemy. Click Graft to change your loadout or use the shortcut shown above it.",
		false, graft_card)

# ── Graft tutorial — opens the menu first, then walks through it ─────────────
func _on_graft_requested_tutorial() -> void:
	if _graft_tutorial_done:
		graft_menu.open()
		return
	_graft_tutorial_done = true
	BattleManager.set_paused(false)
	graft_menu.open()
	await get_tree().process_frame
	_run_graft_menu_tutorial()

func _run_graft_menu_tutorial() -> void:
	_graft_menu_tutorial_active = true
	var root: Control = _tutorial_overlay.get_node("Root")
	root.mouse_filter = Control.MOUSE_FILTER_STOP

	var arm_slot: Control = graft_menu.equipped_cards[0]
	var leg_slot: Control = graft_menu.equipped_cards[1]

	_tutorial_overlay.show_step(
		"The Graft menu",
		"This is where you swap your equipped limbs.",
		true)
	await _tutorial_overlay.next_pressed

	_tutorial_overlay.show_step(
		"Arm slot",
		"Your arm slot holds the limb used for Attack 1.",
		true, arm_slot)
	await _tutorial_overlay.next_pressed

	_tutorial_overlay.show_step(
		"Leg slot",
		"Your leg slot holds the limb used for Attack 2.",
		true, leg_slot)
	await _tutorial_overlay.next_pressed

	_tutorial_overlay.show_step(
		"Limb stats",
		"Each limb shows Attack, Cooldown, Element, and HP Cost. Grafting always costs a little HP.",
		true, arm_slot)
	await _tutorial_overlay.next_pressed

	_tutorial_overlay.show_step(
		"Pick a counter",
		"Scissor beats Paper. Find a Scissor limb in your inventory and swap it in.",
		true)
	await _tutorial_overlay.next_pressed

	_tutorial_overlay.hide()
	root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	_graft_menu_tutorial_active = false
	_set_attacks_enabled(true)

# ── End ──────────────────────────────────────────────────────────────────────
func _on_battle_ended_tutorial(_won: bool, _w: Array, _c: Array) -> void:
	GraftGlobals.right_arm_graft_index = _saved_arm_idx
	GraftGlobals.left_leg_graft_index = _saved_leg_idx
	if _tutorial_overlay:
		_tutorial_overlay.hide()
	if _graft_menu_tutorial_active:
		if _tutorial_overlay:
			var root: Control = _tutorial_overlay.get_node_or_null("Root")
			if root:
				root.mouse_filter = Control.MOUSE_FILTER_IGNORE
		_graft_menu_tutorial_active = false

# ── Input gates ──────────────────────────────────────────────────────────────
func _set_attacks_enabled(enabled: bool) -> void:
	_attacks_enabled = enabled
	for card in weapon_cards:
		if card and card.click_area:
			card.click_area.disabled = not enabled
	if block_card and block_card.click_area:
		block_card.click_area.disabled = not enabled

func _set_consumables_enabled(enabled: bool) -> void:
	_consumables_enabled = enabled
	if consumable_card:
		if consumable_card.use_btn: consumable_card.use_btn.disabled = not enabled
		if consumable_card.next_btn: consumable_card.next_btn.disabled = not enabled
		if consumable_card.prev_btn: consumable_card.prev_btn.disabled = not enabled

func _set_graft_enabled(enabled: bool) -> void:
	_graft_enabled = enabled
	if graft_card and graft_card.click_area:
		graft_card.click_area.disabled = not enabled
