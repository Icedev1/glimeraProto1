extends Node3D

@export var enemy_resource: EnemyData = null

@onready var timer_label: Label = %TimerLabel
@onready var timer_bar: ProgressBar = %TimerBar
@onready var enemy_name_label: Label = %EnemyNameLabel
@onready var enemy_hp_bar: ProgressBar = %EnemyHPBar
@onready var enemy_hp_label: Label = %enemy_hp_label

@onready var player_hp_bar: ProgressBar = %PlayerHPBar
@onready var player_hp_label: Label = %player_hp_label

@onready var weapon_cards: Array[WeaponCard] = []

@onready var block_card: ActionCard = %BlockCard
@onready var graft_card: ActionCard = %GraftCard


@onready var battle_log: RichTextLabel = %battle_log

@onready var result_screen: CanvasLayer = %ResultScreen
@onready var result_label: Label = %result_label
@onready var continue_btn: Button = %continue_btn

@onready var graft_menu: Control = %GraftMenu

@onready var player_effects_label: RichTextLabel = %player_effects_label
@onready var enemy_effects_label: RichTextLabel = %enemy_effects_label

# ── Lifecycle ─────────────────────────────────────────────────────────────────
func _ready() -> void:
	#assert(enemy_resource != null, "BattleScene.enemy_resource must be set in the inspector")
	BattleManager.enemy = enemy_resource
	result_screen.hide()
	graft_menu.hide()

	weapon_cards = [%weaponCard1, %weaponCard2, %weaponCard3, %weaponCard4]

	_connect_signals()
	BattleManager.start_battle()
	_setup_buttons()
	enemy_name_label.text = BattleManager.enemy.unit_name
	# Set initial HP bars
	_on_player_hp(PlayerManager.data.current_hp, PlayerManager.data.max_hp)
	_on_enemy_hp(BattleManager.enemy.current_hp, BattleManager.enemy.max_hp)

func _process(_delta: float) -> void:
	if player_effects_label:
		player_effects_label.text = PlayerManager.data.get_effects_text()
	if enemy_effects_label:
		enemy_effects_label.text = BattleManager.enemy.get_effects_text()

func _unhandled_input(event: InputEvent) -> void:
	if graft_menu.visible:
		return
	if event.is_action_pressed("attack1"): BattleManager.player_attack(0)
	if event.is_action_pressed("attack2"): BattleManager.player_attack(1)
	if event.is_action_pressed("attack3"): BattleManager.player_attack(2)
	if event.is_action_pressed("attack4"): BattleManager.player_attack(3)
	if event.is_action_pressed("block"):   BattleManager.player_block()
	if event.is_action_pressed("graft"):   BattleManager.player_graft()

# ── Connections ───────────────────────────────────────────────────────────────
func _connect_signals() -> void:
	# BattleManager signals
	BattleManager.battle_log_updated.connect(_on_log)
	BattleManager.weapon_cooldown_updated.connect(_on_cooldown)
	BattleManager.block_state_changed.connect(_on_block)
	BattleManager.action_cooldown_updated.connect(_on_action_cooldown)
	BattleManager.enemy_attack_timer_updated.connect(_on_enemy_timer)
	BattleManager.battle_ended.connect(_on_battle_ended)
	# HP directly from UnitData
	PlayerManager.data.hp_changed.connect(_on_player_hp)
	BattleManager.enemy.hp_changed.connect(_on_enemy_hp)
	
	# Weapon card buttons
	for i in range(weapon_cards.size()):
		var slot := i
		weapon_cards[i].pressed.connect(func(): BattleManager.player_attack(slot))
	# Action cards
	block_card.pressed.connect(BattleManager.player_block)
	graft_card.pressed.connect(BattleManager.player_graft)
	# Graft menu
	BattleManager.graft_requested.connect(_on_graft_requested)
	graft_menu.graft_finished.connect(_on_graft_finished)
	graft_menu.graft_cancelled.connect(_on_graft_cancelled)
	# Result screen
	continue_btn.pressed.connect(_on_continue_pressed)

func _setup_buttons() -> void:
	for i in range(weapon_cards.size()):
		weapon_cards[i].weapon = BattleManager._equipped[i]

	block_card.action_name = "Block"
	block_card.cooldown_duration = BattleManager.BLOCK_COOLDOWN
	block_card.description = "Reduce incoming damage by %d%% for %.1fs" % [
		int(BattleManager.BLOCK_REDUCTION * 100), BattleManager.BLOCK_DURATION]

	graft_card.action_name = "Graft"
	graft_card.cooldown_duration = BattleManager.GRAFT_COOLDOWN
	graft_card.description = "Swap weapons mid-battle"

# ── Signal handlers ───────────────────────────────────────────────────────────
func _on_log(msg: String) -> void:
	battle_log.append_text(msg + "\n")

func _on_player_hp(hp: int, max_hp: int) -> void:
	player_hp_bar.max_value = max_hp
	player_hp_bar.value = hp
	player_hp_label.text = "HP: %d / %d" % [hp, max_hp]

func _on_enemy_hp(hp: int, max_hp: int) -> void:
	enemy_hp_bar.max_value = max_hp
	enemy_hp_bar.value = hp
	enemy_hp_label.text = "HP: %d / %d" % [hp, max_hp]

func _on_cooldown(slot: int, remaining: float, total: float) -> void:
	weapon_cards[slot].set_on_cooldown(remaining > 0.0, remaining, total)

func _on_block(is_blocking: bool, _remaining: float) -> void:
	block_card.modulate = Color(0.3, 1.0, 0.3) if is_blocking else Color.WHITE

func _on_action_cooldown(action: String, remaining: float, total: float) -> void:
	if action == "block":
		block_card.set_on_cooldown(remaining > 0.0, remaining, total)
	elif action == "graft":
		graft_card.set_on_cooldown(remaining > 0.0, remaining, total)

func _on_enemy_timer(remaining: float, total: float, weapon_name: String) -> void:
	timer_label.text = "%s in: %.1fs" % [weapon_name, remaining]
	timer_bar.max_value = total
	timer_bar.value = remaining

func _on_battle_ended(player_won: bool) -> void:
	result_label.text = "🏆 VICTORY!" if player_won else "💀 DEFEATED"
	result_label.modulate = Color.YELLOW if player_won else Color.RED
	result_screen.show()

func _on_continue_pressed() -> void:
	get_tree().reload_current_scene()

# ── Graft ─────────────────────────────────────────────────────────────────────
func _on_graft_requested() -> void:
	graft_menu.open()

func _on_graft_finished(swaps: Array[Dictionary]) -> void:
	BattleManager.apply_graft(swaps)
	#swap the old weapon cards with the new ones
	for swap in swaps:
		var slot: int = swap["slot"]
		weapon_cards[slot].weapon = BattleManager._equipped[slot]

func _on_graft_cancelled() -> void:
	BattleManager.cancel_graft()
