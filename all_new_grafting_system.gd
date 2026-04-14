extends Node

@onready var right_arm : BoneAttachment3D = $"../MAsked Gli/Armature/Skeleton/RightArmGraft"
@onready var left_leg : BoneAttachment3D = $"../MAsked Gli/Armature/Skeleton/LeftLegGraft"
@onready var arm_graftables : Array[PackedScene] = [
	null,
	preload("res://Grafting/SawGraft.tscn") as PackedScene

]
@onready var leg_graftables : Array[PackedScene] = [
	null,
	preload("res://Grafting/SledgehammerGraft.tscn") as PackedScene
]

@onready var base_leg_parts : Array[Node3D] = [
	$"../MAsked Gli/Armature/Skeleton/Thigh_l",
	$"../MAsked Gli/Armature/Skeleton/Shin_l",
	$"../MAsked Gli/Armature/Skeleton/Shin Guard_001",
	$"../MAsked Gli/Armature/Skeleton/Boot_001"
]
@onready var arm_parts : Array[Node3D] = [
	$"../MAsked Gli/Armature/Skeleton/LowerArm_r",
	$"../MAsked Gli/Armature/Skeleton/Hand_r"
]

func _ready() -> void:
	GraftGlobals.left_leg_graft_changed.connect(graft_left_leg)
	GraftGlobals.right_arm_graft_changed.connect(graft_right_arm)
	
	graft_left_leg(GraftGlobals.left_leg_graft_index)
	graft_right_arm(GraftGlobals.right_arm_graft_index)
	
	
func graft_right_arm(index : int) -> void:
	if index < 0 or index >= arm_graftables.size():
		return
	elif GraftGlobals.right_arm_graft_index == 0 and index != 0:
		for part in arm_parts:
			part.visible = false
		# Remove any existing graft
	for child in right_arm.get_children():
		child.queue_free()
	
	if index == 0:
		for part in arm_parts:
			part.visible = true
		return
	
	var graft_scene = arm_graftables[index]
	var graft_instance = graft_scene.instantiate()
	

	
	right_arm.add_child(graft_instance)

func graft_left_leg(index : int) -> void:
	if index < 0 or index >= leg_graftables.size():
		return
	elif GraftGlobals.left_leg_graft_index == 0 and index != 0:
		for part in base_leg_parts:
			part.visible = false
			
	for child in left_leg.get_children():
		child.queue_free()
	
	if index == 0:
		for part in base_leg_parts:
			part.visible = true
			print("index = 0")
		return

	var graft_scene = leg_graftables[index]
	var graft_instance = graft_scene.instantiate()
	
	left_leg.add_child(graft_instance)
