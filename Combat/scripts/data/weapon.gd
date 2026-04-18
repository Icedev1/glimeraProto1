class_name Weapon
extends Resource

enum Element { ROCK, PAPER, SCISSOR }

@export var weapon_name: String = ""
@export var attack_damage: int = 0
@export var cooldown: float = 1.0
@export var hp_cost: int = 0
@export var is_arm: bool = true  ## true = arm weapon, false = leg weapon
@export var element: Element = Element.ROCK

# ── Weapon modifiers  ───────────────────────────
@export var hit_count: int = 1
@export var life_steal: float = 0.0

# ── Status effects applied on hit ─────────────────────────────────────────────
@export var effects: Array[StatusEffect] = []

# ── Element helpers ───────────────────────────────────────────────────────────
## Returns the element that this element beats
static func element_beats(e: Element) -> Element:
	match e:
		Element.ROCK:    return Element.SCISSOR
		Element.PAPER:   return Element.ROCK
		Element.SCISSOR: return Element.PAPER
	return e

static func element_name(e: Element) -> String:
	match e:
		Element.ROCK:    return "Rock"
		Element.PAPER:   return "Paper"
		Element.SCISSOR: return "Scissor"
	return "Unknown"

func get_description() -> String:
	var parts: PackedStringArray = []
	parts.append("[%s | %s]" % ["element", Weapon.element_name(element)])
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
		StatusEffect.Type.BLEED, StatusEffect.Type.STUN:
			return "%s (%.1fs)" % [eff.effect_name, eff.duration]
	return eff.effect_name
