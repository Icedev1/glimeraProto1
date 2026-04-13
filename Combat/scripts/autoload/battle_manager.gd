extends Node

signal battle_log_updated(message: String)
signal weapon_cooldown_updated(slot: int, remaining: float, total: float)
signal block_state_changed(is_blocking: bool, remaining: float)
signal action_cooldown_updated(action: String, remaining: float, total: float)
signal enemy_attack_timer_updated(remaining: float, total: float, weapon_name: String)
signal battle_ended(player_won: bool)
signal graft_requested

# ── Set this before the battle scene loads ────────────────────────────────────
@export var enemy: EnemyData = null

# ── Runtime state ─────────────────────────────────────────────────────────────
var _player: PlayerData  # shorthand reference
var _equipped: Array[Weapon] = []
var _inventory: Array[Weapon] = []
var _weapon_cooldowns: Array[CooldownTracker] = []

var _block_active: bool = false
const BLOCK_DURATION: float = 0.4
const BLOCK_REDUCTION: float = 0.6
const BLOCK_COOLDOWN: float = 1.5
var _block_remaining: float = 0.0
var _block_cooldown: CooldownTracker

const GRAFT_COOLDOWN: float = 10.0
var _graft_cooldown: CooldownTracker

var _enemy_attack_timer: float = 0.0
var _enemy_attack_total: float = 0.0
var _enemy_current_weapon: Weapon = null
var _enemy_weapon_index: int = 0

var _battle_active: bool = false

# ── Start ─────────────────────────────────────────────────────────────────────
func start_battle() -> void:
	assert(enemy != null, "BattleManager.enemy must be set before start_battle()")
	assert(enemy.weapons.size() > 0, "Enemy must have at least one weapon")
	assert(PlayerManager.data != null, "PlayerManager has no data")

	_player = PlayerManager.data
	_equipped = _player.equipped.duplicate()
	_inventory = _player.inventory.duplicate()
	_weapon_cooldowns.clear()
	for w in _equipped:
		_weapon_cooldowns.append(CooldownTracker.new(w.cooldown))

	_block_cooldown = CooldownTracker.new(BLOCK_COOLDOWN)
	_graft_cooldown = CooldownTracker.new(GRAFT_COOLDOWN)

	_player.init_combat()
	enemy.init_combat()

	_block_active = false
	_block_remaining = 0.0
	_enemy_weapon_index = 0
	_battle_active = true

	_schedule_enemy_attack()
	log_message("⚔️ %s appears!" % enemy.unit_name)

# ── Process ───────────────────────────────────────────────────────────────────
func _process(delta: float) -> void:
	if not _battle_active:
		return

	_player.tick_effects(delta)
	enemy.tick_effects(delta)

	# Player weapon cooldowns — scaled by player speed
	for i in range(_weapon_cooldowns.size()):
		var tracker := _weapon_cooldowns[i]
		tracker.tick(delta * _player.speed)
		emit_signal("weapon_cooldown_updated", i, tracker.remaining, tracker.duration)

	# Block window
	if _block_active:
		_block_remaining = max(0.0, _block_remaining - delta)
		emit_signal("block_state_changed", true, _block_remaining)
		if _block_remaining <= 0.0:
			_block_active = false
			emit_signal("block_state_changed", false, 0.0)
			log_message("Block window expired.")

	# Block cooldown
	if not _block_active:
		_block_cooldown.tick(delta * _player.speed)
		emit_signal("action_cooldown_updated", "block", _block_cooldown.remaining, _block_cooldown.duration)

	# Graft cooldown
	_graft_cooldown.tick(delta)
	emit_signal("action_cooldown_updated", "graft", _graft_cooldown.remaining, _graft_cooldown.duration)

	# Enemy attack countdown — scaled by enemy speed, frozen if stunned
	if _enemy_attack_timer > 0.0 and not enemy.is_stunned:
		_enemy_attack_timer = max(0.0, _enemy_attack_timer - delta * enemy.speed)
	emit_signal("enemy_attack_timer_updated",
		_enemy_attack_timer,
		_enemy_attack_total,
		_enemy_current_weapon.weapon_name
	)
	if _enemy_attack_timer <= 0.0 and not enemy.is_stunned:
		_execute_enemy_attack()

# ── Player actions ────────────────────────────────────────────────────────────
func player_attack(slot: int) -> void:
	if not _battle_active:
		return
	if _player.is_stunned:
		log_message("💫 You are stunned!")
		return
	if not _weapon_cooldowns[slot].is_ready():
		log_message("⏳ Weapon %d is cooling down!" % (slot + 1))
		return
	var w: Weapon = _equipped[slot]
	_resolve_attack(w, _player, enemy)
	_weapon_cooldowns[slot].start()

func player_block() -> void:
	if not _battle_active or _block_active or not _block_cooldown.is_ready():
		return
	if _player.is_stunned:
		log_message("💫 You are stunned!")
		return
	_block_active = true
	_block_remaining = BLOCK_DURATION
	_block_cooldown.start()
	emit_signal("block_state_changed", true, _block_remaining)
	log_message("🛡️ Blocking! Window: %.1fs" % BLOCK_DURATION)

# ── Enemy logic ───────────────────────────────────────────────────────────────
func _schedule_enemy_attack() -> void:
	if enemy.attack_pattern == "random":
		_enemy_current_weapon = enemy.weapons[randi() % enemy.weapons.size()]
	else:
		_enemy_current_weapon = enemy.weapons[_enemy_weapon_index % enemy.weapons.size()]
		_enemy_weapon_index += 1

	_enemy_attack_total = _enemy_current_weapon.cooldown
	_enemy_attack_timer = _enemy_attack_total
	emit_signal("enemy_attack_timer_updated",
		_enemy_attack_timer,
		_enemy_attack_total,
		_enemy_current_weapon.weapon_name
	)

func _execute_enemy_attack() -> void:
	if not _battle_active:
		return
	_resolve_attack(_enemy_current_weapon, enemy, _player)
	if _battle_active:
		_schedule_enemy_attack()

# ── Shared attack resolution ─────────────────────────────────────────────────
func _resolve_attack(w: Weapon, attacker: UnitData, defender: UnitData) -> void:
	if not _battle_active:
		return

	var is_player_attacking: bool = (attacker == _player)
	var hit_count := w.hit_count
	var base_per_hit: int = w.attack_damage

	var total_damage_dealt := 0
	var was_blocked := false

	for hit_i in range(hit_count):
		if not _battle_active:
			break

		var dmg: int = attacker.calculate_damage(base_per_hit)

		# Block reduction
		if not is_player_attacking and _block_active:
			dmg = int(dmg * (1.0 - BLOCK_REDUCTION))
			was_blocked = true

		defender.take_damage(dmg)
		total_damage_dealt += dmg
		
		# Life steal per hit
		if w.life_steal > 0.0:
			var heal_amount := int(dmg * w.life_steal)
			if heal_amount > 0:
				attacker.heal(heal_amount)
				log_message("💚 %s healed %d HP from life steal!" % [attacker.unit_name, heal_amount])

		if defender.is_dead():
			break

	# Log the attack
	if was_blocked:
		log_message("🛡️ %s used %s — BLOCKED! Took %d dmg (reduced)" % [attacker.unit_name, w.weapon_name, total_damage_dealt])
		_block_active = false
		_block_remaining = 0.0
		emit_signal("block_state_changed", false, 0.0)
	elif hit_count > 1:
		log_message("⚔️ %s hit %s %d times with %s for %d total damage!" % [attacker.unit_name, defender.unit_name, hit_count, w.weapon_name, total_damage_dealt])
	else:
		log_message("⚔️ %s hit %s with %s for %d damage!" % [attacker.unit_name, defender.unit_name, w.weapon_name, total_damage_dealt])

	if not _battle_active:
		return

	# Apply weapon effects
	for eff in w.effects:
		if not _battle_active:
			break
		var target: UnitData = attacker if eff.applies_to == StatusEffect.Target.SELF else defender
		eff.apply(target)

	# Attacker on_attack — triggers charge-based effects
	if _battle_active:
		attacker.process_on_attack()

	check_deaths()

# ── Public helpers ────────────────────────────────────────────────────────────

func log_message(msg: String) -> void:
	emit_signal("battle_log_updated", msg)

func check_deaths() -> void:
	if not _battle_active:
		return
	if _player.is_dead():
		_end_battle(false)
	elif enemy.is_dead():
		_end_battle(true)

func on_stun_expired(unit: UnitData) -> void:
	if not _battle_active:
		return
	if unit == enemy:
		_schedule_enemy_attack()

# ── End ───────────────────────────────────────────────────────────────────────
func _end_battle(player_won: bool) -> void:
	_battle_active = false
	if player_won:
		log_message("🏆 Victory! %s is defeated!" % enemy.unit_name)
	else:
		log_message("💀 Defeated by %s..." % enemy.unit_name)
	emit_signal("battle_ended", player_won)

# ── Graft (weapon swap) ──────────────────────────────────────────────────────
func player_graft() -> void:
	if not _battle_active or not _graft_cooldown.is_ready():
		return
	if _player.is_stunned:
		log_message("💫 You are stunned!")
		return
	_battle_active = false
	emit_signal("graft_requested")

func apply_graft(swaps: Array[Dictionary]) -> void:
	if swaps.size() == 0:
		_battle_active = true
		return

	var total_cost := 0
	for swap in swaps:
		var new_weapon: Weapon = swap["new_weapon"]
		if new_weapon:
			total_cost += new_weapon.hp_cost

	if total_cost > 0:
		_player.take_damage(total_cost)
		log_message("🔧 Graft cost: %d HP" % total_cost)

	if _player.is_dead():
		_end_battle(false)
		return

	for swap in swaps:
		var slot: int = swap["slot"]
		var new_weapon: Weapon = swap["new_weapon"]
		var old_weapon: Weapon = _equipped[slot]

		_equipped[slot] = new_weapon

		if old_weapon:
			_inventory.append(old_weapon)
		_inventory.erase(new_weapon)

		_weapon_cooldowns[slot] = CooldownTracker.new(new_weapon.cooldown if new_weapon else 1.0)

		log_message("🔧 Slot %d: %s → %s" % [slot + 1,
			old_weapon.weapon_name if old_weapon else "(empty)",
			new_weapon.weapon_name if new_weapon else "(empty)"])

	_graft_cooldown.start()
	_battle_active = true

func cancel_graft() -> void:
	_battle_active = true
