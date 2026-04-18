extends Node

#const SAVE_PATH: String = "user://player.tres"

var data: PlayerData

# ── Graft index → weapon mapping ──────────────────────────────────────────────
# Mirrors GraftPlayer.arm_graftables / leg_graftables — index 0 is the base limb.
# Keep this in sync with the overworld GraftPlayer script.
var _arm_weapons: Array[Weapon] = [
	preload("res://Combat/resources/weapons/gli_arm.tres"),       # 0: base (no graft)
	preload("res://Combat/resources/weapons/saw.tres"),           # 1: Saw
	preload("res://Combat/resources/weapons/hose.tres"),          # 2: Hose
]

var _leg_weapons: Array[Weapon] = [
	preload("res://Combat/resources/weapons/gli_leg.tres"),       # 0: base (no graft)
	preload("res://Combat/resources/weapons/sledge_hammer.tres"), # 1: Sledgehammer
]

func _ready() -> void:
	init_player()

func init_player() -> void:
	data = PlayerData.new()
	data.max_hp = 100
	data.consumables = _default_consumables()
	sync_from_grafts()

# ── Pull the overworld graft state into PlayerData ────────────────────────────
func sync_from_grafts() -> void:
	if data == null:
		return
	var arm_idx: int = clamp(GraftGlobals.right_arm_graft_index, 0, _arm_weapons.size() - 1)
	var leg_idx: int = clamp(GraftGlobals.left_leg_graft_index, 0, _leg_weapons.size() - 1)

	var equipped_arm: Weapon = _arm_weapons[arm_idx]
	var equipped_leg: Weapon = _leg_weapons[leg_idx]

	data.equipped[0] = equipped_arm  # BattleManager.SLOT_ARM
	data.equipped[1] = equipped_leg  # BattleManager.SLOT_LEG
	data.inventory = _build_inventory(equipped_arm, equipped_leg)

# ── Inventory = base limbs + owned grafts, minus what's currently equipped ────
func _build_inventory(equipped_arm: Weapon, equipped_leg: Weapon) -> Array[Weapon]:
	var inv: Array[Weapon] = []

	# Base limbs are always available as swap targets
	if equipped_arm != _arm_weapons[0]:
		inv.append(_arm_weapons[0])
	if equipped_leg != _leg_weapons[0]:
		inv.append(_leg_weapons[0])

	# Arm grafts (gated by GraftGlobals obtained flags)
	if GraftGlobals.sawObtained and equipped_arm != _arm_weapons[1]:
		inv.append(_arm_weapons[1])
	if GraftGlobals.hoseObtained and equipped_arm != _arm_weapons[2]:
		inv.append(_arm_weapons[2])

	# Leg grafts (for now sledge hammer always treated as obtained)
	if equipped_leg != _leg_weapons[1]:
		inv.append(_leg_weapons[1])

	return inv

func _default_consumables() -> Array[Consumable]:
	return [
		(preload("res://Combat/resources/consumables/bandage_2.tres") as Consumable).duplicate(),
		(preload("res://Combat/resources/consumables/health_potion.tres") as Consumable).duplicate(),
	]


#func _default_inventory() -> Array[Weapon]:
	#return [
		##preload("res://Combat/resources/weapons/poison_arm.tres"), #poision arm
		##preload("res://Combat/resources/weapons/blowhorn.tres"), # blowhorn (slow)
		##preload("res://Combat/resources/weapons/table_leg.tres"), # tabel_leg (multi hit)
		##preload("res://Combat/resources/weapons/lighter.tres"), # lighter (burn)
		##preload("res://Combat/resources/weapons/run_kit.tres"), # run kit (haste)
		##preload("res://Combat/resources/weapons/flash_light.tres"), # flashlight(stun)
		##preload("res://Combat/resources/weapons/violin.tres"), # violin (quick_Heal + empower)
		##preload("res://Combat/resources/weapons/w1.tres"), # w1 (dmg_buff)
		##preload("res://Combat/resources/weapons/w2.tres"), # w2 (self_Harm)
		##preload("res://Combat/resources/weapons/w3.tres"), # w3 (weaken)
		##preload("res://Combat/resources/weapons/w4.tres"),# w4 (lifesteal)
		##preload("res://Combat/resources/weapons/saw.tres"), # saw
		##preload("res://Combat/resources/weapons/gli_arm.tres"), # gli_arm
		##preload("res://Combat/resources/weapons/gli_leg.tres"), # gli_leg
		##preload("res://Combat/resources/weapons/hose.tres"), # hose
		##preload("res://Combat/resources/weapons/sledge_hammer.tres"), # sledge_hammer
		#
	#]
