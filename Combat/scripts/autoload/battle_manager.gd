extends Node

signal battle_log_updated(message: String)
signal weapon_cooldown_updated(slot: int, remaining: float, total: float)
signal block_state_changed(is_blocking: bool, remaining: float)
signal action_cooldown_updated(action: String, remaining: float, total: float)
signal enemy_attack_timer_updated(remaining: float, total: float, weapon_name: String, element_name: String)
signal battle_ended(player_won: bool)
signal graft_requested
signal consumable_updated(consumable: Consumable)  ## Emitted when selected consumable changes or is used

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
var _block_cooldown_duration: float
var _block_remaining: float = 0.0
var _block_cooldown: CooldownTracker

var _graft_cooldown_duration: float
var _graft_cooldown: CooldownTracker

# ── Consumable state ──────────────────────────────────────────────────────────
var _consumable_cooldown_duration: float
var _consumable_cooldown: CooldownTracker
var _consumables: Array[Consumable] = []
var _consumable_index: int = 0

var _enemy_attack_timer: float = 0.0
var _enemy_attack_total: float = 0.0
var _enemy_current_weapon: Weapon = null
var _enemy_weapon_index: int = 0

var _battle_active: bool = false

var player_mesh: MeshInstance3D
var enemy_mesh: MeshInstance3D

const SLOT_ARM: int = 0
const SLOT_LEG: int = 1
const NUM_SLOTS: int = 2

# ── Element damage multipliers ───────────────────────────────────────────────
# Player attacking enemy (weapon element vs enemy unit element)
const ELEMENT_PLAYER_EFFECTIVE: float = 1.5
const ELEMENT_PLAYER_NEUTRAL: float = 1.0
const ELEMENT_PLAYER_INEFFECTIVE: float = 0.5

# Enemy attacking player (enemy weapon element vs player's 2 equipped elements)
const ELEMENT_ENEMY_SUPER_EFFECTIVE: float = 1.75
const ELEMENT_ENEMY_EFFECTIVE: float = 1.3
const ELEMENT_ENEMY_NEUTRAL: float = 1.0
const ELEMENT_ENEMY_INEFFECTIVE: float = 0.7
const ELEMENT_ENEMY_SUPER_INEFFECTIVE: float = 0.4

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
		_weapon_cooldowns.append(CooldownTracker.new(w.cooldown if w else 1.0))

	_block_cooldown = CooldownTracker.new(_block_cooldown_duration)
	_graft_cooldown = CooldownTracker.new(_graft_cooldown_duration)
	_consumable_cooldown = CooldownTracker.new(_consumable_cooldown_duration)
	_consumables = _player.consumables.duplicate()
	_consumable_index = 0

	_player.init_combat()
	enemy.init_combat()

	_block_active = false
	_block_remaining = 0.0
	_enemy_weapon_index = 0
	_battle_active = true

	_schedule_enemy_attack()
	log_message("⚔️ %s appears!" % enemy.unit_name)

	# Separate meshes so flash shader doesn't affect both
	player_mesh.set_surface_override_material(
		0,
		player_mesh.get_active_material(0).duplicate()
	)
	enemy_mesh.set_surface_override_material(
		0,
		enemy_mesh.get_active_material(0).duplicate()
	)

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

	# Consumable cooldown
	_consumable_cooldown.tick(delta)
	emit_signal("action_cooldown_updated", "consumable", _consumable_cooldown.remaining, _consumable_cooldown.duration)

	# Enemy attack countdown — scaled by enemy speed, frozen if stunned
	if _enemy_attack_timer > 0.0 and not enemy.is_stunned:
		_enemy_attack_timer = max(0.0, _enemy_attack_timer - delta * enemy.speed)
	emit_signal("enemy_attack_timer_updated",
		_enemy_attack_timer,
		_enemy_attack_total,
		_enemy_current_weapon.weapon_name,
		Weapon.element_name(_enemy_current_weapon.element)
	)
	if _enemy_attack_timer <= 0.0 and not enemy.is_stunned:
		_execute_enemy_attack()

# ── Player actions ────────────────────────────────────────────────────────────
func player_attack(slot: int) -> void:
	if not _battle_active:
		return
	if slot < 0 or slot >= NUM_SLOTS:
		return
	if _player.is_stunned:
		log_message("💫 You are stunned!")
		return
	if not _weapon_cooldowns[slot].is_ready():
		var label := "Arm" if slot == SLOT_ARM else "Leg"
		log_message("⏳ %s weapon is cooling down!" % label)
		return
	var w: Weapon = _equipped[slot]
	if w == null:
		return
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
		_enemy_current_weapon.weapon_name,
		Weapon.element_name(_enemy_current_weapon.element)
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

	# Element multiplier
	var element_mult: float = 1.0
	var element_label: String = ""
	if is_player_attacking:
		element_mult = _get_player_attack_element_mult(w)
		element_label = _get_player_attack_element_label(w)
	else:
		element_mult = _get_enemy_attack_element_mult(w)
		element_label = _get_enemy_attack_element_label(w)

	var total_damage_dealt := 0
	var was_blocked := false

	for hit_i in range(hit_count):
		if not _battle_active:
			break

		var dmg: int = attacker.calculate_damage(base_per_hit)

		# Apply element multiplier
		dmg = int(dmg * element_mult)

		# Block reduction
		if not is_player_attacking and _block_active:
			dmg = int(dmg * (1.0 - BLOCK_REDUCTION))
			was_blocked = true

		defender.take_damage(dmg)

		# Flash on hit
		var visual: MeshInstance3D = player_mesh if defender == _player else enemy_mesh
		if visual:
			var mat := visual.get_surface_override_material(0)
			if mat is ShaderMaterial and dmg != 0:
				get_tree().root.get_node("Root").screenshake()
				mat.set_shader_parameter("flash_intensity", 1.0)
				var tween := get_tree().create_tween()
				tween.tween_property(mat, "shader_parameter/flash_intensity", 1.2, 0.03)
				tween.tween_property(mat, "shader_parameter/flash_intensity", 1.0, 0.05)
				tween.tween_property(mat, "shader_parameter/flash_intensity", 0.0, 0.25)\
					.set_trans(Tween.TRANS_QUAD)\
					.set_ease(Tween.EASE_OUT)

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
		log_message("🛡️ %s used %s — BLOCKED! Took %d dmg (reduced) %s" % [attacker.unit_name, w.weapon_name, total_damage_dealt, element_label])
		_block_active = false
		_block_remaining = 0.0
		emit_signal("block_state_changed", false, 0.0)
	elif hit_count > 1:
		log_message("⚔️ %s hit %s %d times with %s for %d total damage! %s" % [attacker.unit_name, defender.unit_name, hit_count, w.weapon_name, total_damage_dealt, element_label])
	else:
		log_message("⚔️ %s hit %s with %s for %d damage! %s" % [attacker.unit_name, defender.unit_name, w.weapon_name, total_damage_dealt, element_label])

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

# ── Consumables ───────────────────────────────────────────────────────────────
func get_current_consumable() -> Consumable:
	if _consumables.size() == 0:
		return null
	if _consumable_index < 0 or _consumable_index >= _consumables.size():
		_consumable_index = 0
	return _consumables[_consumable_index]

func _has_available_consumables() -> bool:
	for c in _consumables:
		if c.quantity > 0:
			return true
	return false

func player_use_consumable() -> void:
	if not _battle_active:
		return
	if _player.is_stunned:
		log_message("💫 You are stunned!")
		return
	if not _consumable_cooldown.is_ready():
		log_message("⏳ Consumables are cooling down!")
		return
	var consumable := get_current_consumable()
	if consumable == null or consumable.quantity <= 0:
		log_message("❌ No consumables available!")
		return

	consumable.quantity -= 1
	_player.heal(consumable.heal_amount)
	log_message("🧪 Used %s! Healed %d HP" % [consumable.consumable_name, consumable.heal_amount])
	_consumable_cooldown.start()

	# If this consumable is now empty, try to cycle to next available
	if consumable.quantity <= 0:
		if _has_available_consumables():
			_cycle_to_next_available(1)
		# else: stay on last one (greyed out)

	emit_signal("consumable_updated", get_current_consumable())

func player_next_consumable() -> void:
	_cycle_to_next_available(1)
	emit_signal("consumable_updated", get_current_consumable())

func player_prev_consumable() -> void:
	_cycle_to_next_available(-1)
	emit_signal("consumable_updated", get_current_consumable())

func _cycle_to_next_available(direction: int) -> void:
	if _consumables.size() == 0:
		return
	var start := _consumable_index
	for i in range(_consumables.size()):
		_consumable_index = (_consumable_index + direction) % _consumables.size()
		if _consumable_index < 0:
			_consumable_index += _consumables.size()
		if _consumables[_consumable_index].quantity > 0:
			return
	# No available consumables found — stay where we are
	_consumable_index = start

# ── Element helpers ───────────────────────────────────────────────────────────

## Player attacks enemy: weapon element vs enemy unit element
func _get_player_attack_element_mult(w: Weapon) -> float:
	var atk_el := w.element
	var def_el := enemy.element
	if atk_el == def_el:
		return ELEMENT_PLAYER_NEUTRAL
	elif Weapon.element_beats(atk_el) == def_el:
		return ELEMENT_PLAYER_EFFECTIVE
	else:
		return ELEMENT_PLAYER_INEFFECTIVE

func _get_player_attack_element_label(w: Weapon) -> String:
	var mult := _get_player_attack_element_mult(w)
	if mult > ELEMENT_PLAYER_NEUTRAL:
		return "⬆ Effective!"
	elif mult < ELEMENT_PLAYER_NEUTRAL:
		return "⬇ Ineffective"
	return ""

## Enemy attacks player: enemy weapon element vs player's 2 equipped weapon elements
func _get_enemy_attack_element_mult(w: Weapon) -> float:
	var atk_el := w.element
	var score := 0  # +1 per weapon weak to atk, -1 per weapon strong against atk
	for equipped_w in _equipped:
		if equipped_w == null:
			continue
		var eq_el := equipped_w.element
		if eq_el == atk_el:
			pass  # neutral, score += 0
		elif Weapon.element_beats(atk_el) == eq_el:
			score += 1  # this equipped weapon is weak to attacker
		else:
			score -= 1  # this equipped weapon is strong against attacker

	match score:
		2:  return ELEMENT_ENEMY_SUPER_EFFECTIVE
		1:  return ELEMENT_ENEMY_EFFECTIVE
		0:  return ELEMENT_ENEMY_NEUTRAL
		-1: return ELEMENT_ENEMY_INEFFECTIVE
		-2: return ELEMENT_ENEMY_SUPER_INEFFECTIVE
	return ELEMENT_ENEMY_NEUTRAL

func _get_enemy_attack_element_label(w: Weapon) -> String:
	var mult := _get_enemy_attack_element_mult(w)
	if mult >= ELEMENT_ENEMY_SUPER_EFFECTIVE:
		return "⬆⬆ Super effective!"
	elif mult >= ELEMENT_ENEMY_EFFECTIVE:
		return "⬆ Effective!"
	elif mult <= ELEMENT_ENEMY_SUPER_INEFFECTIVE:
		return "⬇⬇ Super ineffective"
	elif mult <= ELEMENT_ENEMY_INEFFECTIVE:
		return "⬇ Ineffective"
	return ""

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

		var slot_label := "Arm" if slot == SLOT_ARM else "Leg"
		log_message("🔧 %s: %s → %s" % [slot_label,
			old_weapon.weapon_name if old_weapon else "(empty)",
			new_weapon.weapon_name if new_weapon else "(empty)"])

	_graft_cooldown.start()
	_battle_active = true

func cancel_graft() -> void:
	_battle_active = true
