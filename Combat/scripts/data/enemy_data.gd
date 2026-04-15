class_name EnemyData
extends UnitData

@export var weapons: Array[Weapon] = []
@export_enum("ordered", "random") var attack_pattern: String = "ordered"
@export var element: Weapon.Element = Weapon.Element.ROCK
