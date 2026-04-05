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
	data.max_hp = 25
	data.inventory = _default_inventory()
	data.equipped[0] = preload("uid://dhctuph5xn3k2") # lighter
	data.equipped[1] = preload("uid://cxrkjxb6p6s30") # blowhorn
	data.equipped[2] = preload("uid://7exwce5lhtws")  #flashlight
	data.equipped[3] = preload("uid://cq6h2qdc81ayw") # violin (heal + empower)
	#save()



#func save() -> void:
	#data.save(SAVE_PATH)

func _default_inventory() -> Array[Weapon]:
	return [
		preload("uid://bwat6x5bxiu6x"), #poision arm
		preload("uid://cxrkjxb6p6s30"), # blowhorn (slow)
		preload("uid://d16evo8w5imeb"), # tabel_leg (multi hit)
		preload("uid://dhctuph5xn3k2"), # lighter (burn)
		preload("uid://cly1nbgmusfg1"), # run shoe (haste)
		preload("uid://7exwce5lhtws"), # flashlight(stun)
		preload("uid://cq6h2qdc81ayw"), # violin (quick_Heal + empower)
		preload("uid://csl1v4wtvdm2c"), # w1 (dmg_buff)
		preload("uid://pw833xw0y2in"), # w2 (self_Harm)
		preload("uid://6qt5mfg0b4wo"), # w3 (weaken)
		preload("uid://ypx12txeeeqe"),# w4 (lifesteal)
		
	]
