class_name StatusEffect
extends Resource

enum Type {
	# Instant (fire once, no tracking)
	DAMAGE,
	HEAL,
	# Charge-based (tracked, deplete per attack)
	DAMAGE_BONUS,
	POISON,
	# Time-based (tracked, deplete over seconds)
	SPEED,
	DAMAGE_AMP,
	BURN,
	STUN,
}

enum Target {
	SELF,
	TARGET,
}

@export var effect_name: String = ""
@export var type: Type = Type.DAMAGE
@export var applies_to: Target = Target.TARGET
@export var value: float = 0.0
@export var duration: float = 0.0

# ── Apply — called once when weapon hits ──────────────────────────────────────
func apply(target: UnitData) -> void:
	match type:
		Type.DAMAGE:
			target.take_damage(int(value))
			BattleManager.log_message("💥 %s dealt %d damage to %s!" % [effect_name, int(value), target.unit_name])
		Type.HEAL:
			target.heal(int(value))
			BattleManager.log_message("💚 %s healed %s for %d HP!" % [effect_name, target.unit_name, int(value)])
		Type.DAMAGE_BONUS:
			target.add_effect(self)
		Type.POISON:
			var existing: ActiveEffect = target.find_effect_of_type(type)
			if existing:
				existing.remaining += value
				BattleManager.log_message("🔮 %s's %s increased to %d stacks" % [
					target.unit_name, effect_name, int(existing.remaining)])
			else:
				target.add_effect(self, value)
		Type.SPEED, Type.DAMAGE_AMP, Type.STUN:
			var existing: ActiveEffect = target.find_effect_of_type(type)
			if existing:
				existing.remaining += duration
				target.recalculate()
				BattleManager.log_message("🔮 %s's %s extended to %.1fs" % [
					target.unit_name, effect_name, existing.remaining])
			else:
				target.add_effect(self)
		Type.BURN:
			var existing: ActiveEffect = target.find_effect_of_type(type)
			if existing:
				existing.remaining += duration
				if value > existing.effect.value:
					existing.effect = self
				BattleManager.log_message("🔮 %s's %s extended to %.1fs" % [
					target.unit_name, effect_name, existing.remaining])
			else:
				target.add_effect(self)

# ── Tick — called every frame for tracked effects ────────────────────────────
func tick(delta: float, active: ActiveEffect, target: UnitData) -> void:
	match type:
		Type.SPEED, Type.DAMAGE_AMP, Type.STUN:
			active.remaining -= delta
		Type.BURN:
			var old_remaining := active.remaining
			active.remaining -= delta
			const TICK_INTERVAL: float = 1
			if int(old_remaining / TICK_INTERVAL) > int(max(0.0, active.remaining) / TICK_INTERVAL):
				target.take_damage(int(active.effect.value))
				BattleManager.log_message("🔥 Burn dealt %d damage to %s!" % [int(active.effect.value), target.unit_name])
				BattleManager.check_deaths()

# ── On attack — called when the unit that has this effect attacks ─────────────
func on_attack(active: ActiveEffect, target: UnitData) -> void:
	match type:
		Type.DAMAGE_BONUS:
			active.remaining -= 1.0
		Type.POISON:
			var stacks: int = int(active.remaining)
			var poison_dmg: int = int(target.max_hp * 0.05 * stacks)
			if poison_dmg > 0:
				target.take_damage(poison_dmg)
				BattleManager.log_message("🤢 Poison (%d stacks) dealt %d damage to %s!" % [stacks, poison_dmg, target.unit_name])
				BattleManager.check_deaths()
			active.remaining -= 1.0

# ── Helpers ───────────────────────────────────────────────────────────────────
func is_instant() -> bool:
	return type in [Type.DAMAGE, Type.HEAL]
