class_name UnitData
extends Resource

signal hp_changed(current_hp: int, max_hp: int)

@export var unit_name: String = ""
@export var max_hp: int = 100

# ── Combat state (not exported — never saved) ─────────────────────────────────
var current_hp: int = 0
var active_effects: Array[ActiveEffect] = []
var speed: float = 1.0
var damage_bonus_flat: int = 0
var damage_multiplier: float = 1.0
var is_stunned: bool = false

# ── Combat lifecycle ──────────────────────────────────────────────────────────
func init_combat() -> void:
	current_hp = max_hp
	active_effects.clear()
	speed = 1.0
	damage_bonus_flat = 0
	damage_multiplier = 1.0
	is_stunned = false

# ── HP management ─────────────────────────────────────────────────────────────
func take_damage(amount: int) -> void:
	current_hp = max(0, current_hp - amount)
	hp_changed.emit(current_hp, max_hp)

func heal(amount: int) -> void:
	current_hp = min(current_hp + amount, max_hp)
	hp_changed.emit(current_hp, max_hp)

func is_dead() -> bool:
	return current_hp <= 0

# ── Damage calculation ────────────────────────────────────────────────────────
func calculate_damage(base_damage: int) -> int:
	return maxi(0, int((base_damage + damage_bonus_flat) * damage_multiplier))

# ── Effect management ─────────────────────────────────────────────────────────
func add_effect(effect: StatusEffect, custom_remaining := -1.0) -> void:
	var ae := ActiveEffect.new(effect)
	if custom_remaining >= 0.0:
		ae.remaining = custom_remaining
	active_effects.append(ae)
	recalculate()
	BattleManager.log_message("🔮 %s gained: %s" % [unit_name, effect.effect_name])

func find_effect_of_type(type: StatusEffect.Type) -> ActiveEffect:
	for ae in active_effects:
		if ae.effect.type == type:
			return ae
	return null

func recalculate() -> void:
	speed = 1.0
	damage_bonus_flat = 0
	damage_multiplier = 1.0
	is_stunned = false
	for ae in active_effects:
		match ae.effect.type:
			StatusEffect.Type.SPEED:
				speed += ae.effect.value
			StatusEffect.Type.DAMAGE_AMP:
				damage_multiplier += ae.effect.value
			StatusEffect.Type.STUN:
				is_stunned = true
			StatusEffect.Type.DAMAGE_BONUS:
				damage_bonus_flat += int(ae.effect.value)
	speed = maxf(speed, 0.1)
	damage_multiplier = maxf(damage_multiplier, 0.0)

func tick_effects(delta: float) -> void:
	var i := active_effects.size() - 1
	var changed := false
	while i >= 0:
		var ae: ActiveEffect = active_effects[i]
		ae.effect.tick(delta, ae, self)
		if ae.is_expired():
			_on_effect_expired(ae)
			active_effects.remove_at(i)
			changed = true
		i -= 1
	if changed:
		recalculate()

func process_on_attack() -> void:
	var i := active_effects.size() - 1
	var changed := false
	while i >= 0:
		var ae: ActiveEffect = active_effects[i]
		ae.effect.on_attack(ae, self)
		if ae.is_expired():
			_on_effect_expired(ae)
			active_effects.remove_at(i)
			changed = true
		i -= 1
	if changed:
		recalculate()

func _on_effect_expired(ae: ActiveEffect) -> void:
	BattleManager.log_message("⏳ %s's %s wore off" % [unit_name, ae.effect.effect_name])
	if ae.effect.type == StatusEffect.Type.STUN:
		BattleManager.on_stun_expired(self)

# ── Debug ─────────────────────────────────────────────────────────────────────
func get_effects_text() -> String:
	if active_effects.size() == 0:
		return "None"
	var parts: PackedStringArray = []
	for ae in active_effects:
		parts.append("%s (%.1f)" % [ae.effect.effect_name, ae.remaining])
	return ", ".join(parts)
