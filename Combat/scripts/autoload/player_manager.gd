extends Node

#const SAVE_PATH: String = "user://player.tres"

var data: PlayerData

func _ready() -> void:
	#DirAccess.make_dir_recursive_absolute(OS.get_user_data_dir() + "/saves")
	#data = PlayerData.load(SAVE_PATH)
	#if data == null:
	init_player()

func init_player() -> void:
	data = PlayerData.new()
	data.max_hp = 100
	data.inventory = _default_inventory()
	data.consumables = _default_consumables()
	#data.equipped[0] = preload("res://Combat/resources/weapons/hose.tres") # hose
	data.equipped[0] = preload("res://Combat/resources/weapons/saw.tres") # saw
	data.equipped[1] = preload("res://Combat/resources/weapons/sledge_hammer.tres") # sledge_hammer
	#data.equipped[0] = preload("res://Combat/resources/weapons/gli_arm.tres") # gli_arm
	#data.equipped[1] = preload("res://Combat/resources/weapons/gli_leg.tres") # gli_leg
	#save()
	
	#"res://Combat/resources/weapons/hose.tres" # hose
	#"res://Combat/resources/weapons/sledge.tres" # slege_hammer
	

#func save() -> void:
	#data.save(SAVE_PATH)

func _default_inventory() -> Array[Weapon]:
	return [
		preload("res://Combat/resources/weapons/poison_arm.tres"), #poision arm
		preload("res://Combat/resources/weapons/blowhorn.tres"), # blowhorn (slow)
		preload("res://Combat/resources/weapons/table_leg.tres"), # tabel_leg (multi hit)
		preload("res://Combat/resources/weapons/lighter.tres"), # lighter (burn)
		preload("res://Combat/resources/weapons/run_kit.tres"), # run kit (haste)
		preload("res://Combat/resources/weapons/flash_light.tres"), # flashlight(stun)
		preload("res://Combat/resources/weapons/violin.tres"), # violin (quick_Heal + empower)
		preload("res://Combat/resources/weapons/w1.tres"), # w1 (dmg_buff)
		preload("res://Combat/resources/weapons/w2.tres"), # w2 (self_Harm)
		preload("res://Combat/resources/weapons/w3.tres"), # w3 (weaken)
		preload("res://Combat/resources/weapons/w4.tres"),# w4 (lifesteal)
		preload("res://Combat/resources/weapons/saw.tres"), # saw
		
	]

func _default_consumables() -> Array[Consumable]:
	return [
		preload("res://Combat/resources/consumables/bandage.tres"), # bandage
		preload("res://Combat/resources/consumables/health_potion.tres"), # health_potion
	]
