class_name Weapon
extends Resource

@export var weapon_name: String = ""
@export var attack_damage: int = 0
@export var cooldown: float = 1.0
@export var hp_cost: int = 0

# ── Weapon modifiers (read directly during attack) ───────────────────────────
@export var hit_count: int = 1
@export var life_steal: float = 0.0

# ── Status effects applied on hit ─────────────────────────────────────────────
@export var effects: Array[StatusEffect] = []

func _init(p_name: String = "", p_damage: int = 0, p_cooldown: float = 1.0, p_hp_cost: int = 0):
	weapon_name = p_name
	attack_damage = p_damage
	cooldown = p_cooldown
	hp_cost = p_hp_cost

func get_description() -> String:
	var parts: PackedStringArray = []
	if hit_count > 1:
		parts.append("%d hits" % hit_count)
	if life_steal > 0.0:
		parts.append("%d%% life steal" % int(life_steal * 100))
	for eff in effects:
		parts.append(_describe_effect(eff))
	return "\n".join(parts) if parts.size() > 0 else ""

func _describe_effect(eff: StatusEffect) -> String:
	match eff.type:
		StatusEffect.Type.DAMAGE, StatusEffect.Type.HEAL, StatusEffect.Type.POISON:
			return "%s (%d)" % [eff.effect_name, int(eff.value)]
		StatusEffect.Type.DAMAGE_BONUS:
			return "%s (%d)" % [eff.effect_name, int(eff.duration)]
		StatusEffect.Type.SPEED, StatusEffect.Type.DAMAGE_AMP, \
		StatusEffect.Type.BURN, StatusEffect.Type.STUN:
			return "%s (%.1fs)" % [eff.effect_name, eff.duration]
	return eff.effect_name
