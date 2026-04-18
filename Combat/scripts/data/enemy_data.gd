class_name EnemyData
extends UnitData

@export var weapons: Array[Weapon] = []
@export_enum("ordered", "random") var attack_pattern: String = "ordered"
@export var element: Weapon.Element = Weapon.Element.ROCK

# ── Rewards on defeat ────────────────────────────────────────────────────────
@export var reward_weapons: Array[Weapon] = []
@export var reward_consumables: Array[Consumable] = []
