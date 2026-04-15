class_name Consumable
extends Resource

@export var consumable_name: String = ""
@export var heal_amount: int = 0
@export var quantity: int = 1
@export var battle_description: String = ""  ## Shown on the card (e.g. "Heal 10 HP")
@export var description: String = ""         ## Lore description (not shown in combat)
