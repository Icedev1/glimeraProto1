extends "res://Combat/scripts/battle/battle_Scene.gd"

const TutorialOverlayScene := preload("res://Combat/scenes/tutorial_overlay.tscn")
const BLOCK_TUTORIAL_LEAD: float = 0.3  ## Pause before the enemy attacks

var _tutorial_overlay
var _block_tutorial_done: bool = false


# control which inputs are allowed in which phase
var _attacks_enabled: bool = false  
var _block_enabled: bool = false     
var _waiting_for_attack: bool = false  ## True only on the final intro step; the first attack ends the intro

@onready var _block_section: VBoxContainer = %Block
@onready var attack_timer_card: PanelContainer = %AttackTimerCard

func _ready() -> void:
	super._ready()

	# Hide block UI and disable attack clicks for the intro
	_block_section.visible = false
	_set_attacks_enabled(false)

	_tutorial_overlay = TutorialOverlayScene.instantiate()
	add_child(_tutorial_overlay)

	BattleManager.enemy_attack_timer_updated.connect(_on_enemy_timer_tutorial)
	BattleManager.player_attacked.connect(_on_player_attacked_tutorial)
	BattleManager.block_state_changed.connect(_on_block_state_tutorial)
	BattleManager.battle_ended.connect(_on_battle_ended_tutorial)

	BattleManager.set_paused(true)
	await get_tree().process_frame
	_run_intro_tutorial()

func _unhandled_input(event: InputEvent) -> void:
	# no consumable/graft input. attacks and block are gated by tutorial flags
	if result_screen.visible:
		if event.is_action_pressed("graft_select"):
			_on_continue_pressed()
		return
	if _attacks_enabled:
		if event.is_action_pressed("attack1"): BattleManager.player_attack(0)
		if event.is_action_pressed("attack2"): BattleManager.player_attack(1)
	if _block_enabled and event.is_action_pressed("block"):
		BattleManager.player_block()

func _set_attacks_enabled(enabled: bool) -> void:
	_attacks_enabled = enabled
	for card in weapon_cards:
		if card and card.click_area:
			card.click_area.disabled = not enabled

# ── Intro tutorial ─────────────────────
func _run_intro_tutorial() -> void:
	_tutorial_overlay.show_step(
		"Welcome",
		"This is a quick combat tutorial. Click Next to continue.",
		true)
	await _tutorial_overlay.next_pressed

	_tutorial_overlay.show_step(
		"Your Health",
		"This is your HP bar. If it reaches 0, you lose the fight.",
		true, player_hp_bar)
	await _tutorial_overlay.next_pressed

	_tutorial_overlay.show_step(
		"Enemy Health",
		"This is the enemy's HP bar. Reduce it to 0 to win.",
		true, enemy_hp_bar)
	await _tutorial_overlay.next_pressed

	_tutorial_overlay.show_step(
		"Enemy Attack Timer",
		"This bar drains down to show when the enemy will strike.",
		true, attack_timer_card)
	await _tutorial_overlay.next_pressed

# Final intro step, highlight both attack cards and enable attacks
	_tutorial_overlay.show_step(
		"Your Attacks",
		"These are your two Limbs attack. Each has its own cooldown. Click it to attack or use the shortcut shown above it.",
		false, [weapon_cards[0], weapon_cards[1]])
	_waiting_for_attack = true
	_set_attacks_enabled(true)

func _on_player_attacked_tutorial() -> void:
	# the FINAL intro step ends on player attack
	if not _waiting_for_attack:
		return
	_waiting_for_attack = false
	_tutorial_overlay.hide()
	BattleManager.set_paused(false)

# ── Block tutorial (fires once, just before the first enemy attack) ──────────
func _on_enemy_timer_tutorial(remaining: float, _total: float, _wn: String, _en: String,w : Weapon) -> void:
	if _block_tutorial_done:
		return
	if remaining > BLOCK_TUTORIAL_LEAD:
		return
	_block_tutorial_done = true
	BattleManager.set_paused(true)
	# Lock attacks during the block lesson so the player focuses on blocking
	_set_attacks_enabled(false)
	_block_section.visible = true
	_block_enabled = true
	await get_tree().process_frame
	await get_tree().process_frame
	_tutorial_overlay.show_step(
		"Block!",
		"The enemy is about to strike! Click Block now or use the shortcut shown above it.\nBlock reduces incoming damage by %d%% for %.1fs, then needs %.1fs to recharge." % [
			int(BattleManager.BLOCK_REDUCTION * 100),
			BattleManager.BLOCK_DURATION,
			block_card.cooldown_duration,
		],
		false, block_card)

func _on_block_state_tutorial(is_blocking: bool, _remaining: float) -> void:
	if not _block_tutorial_done:
		return
	if not is_blocking:
		return  
	if not _tutorial_overlay.visible:
		return
	_tutorial_overlay.hide()
	# Hand control back to the player for the rest of the fight
	_set_attacks_enabled(true)
	BattleManager.set_paused(false)

func _on_battle_ended_tutorial(_won: bool, _w: Array, _c: Array) -> void:
	if _tutorial_overlay:
		_tutorial_overlay.hide()
