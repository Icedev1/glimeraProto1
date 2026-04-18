extends Control

@onready var hand_l = $"../CharacterBody3D/Proto Gli 1/Armature/Skeleton/Hand_l"
@onready var lowerarm_l = $"../CharacterBody3D/Proto Gli 1/Armature/Skeleton/LowerArm_l"
@onready var shin_r = $"../CharacterBody3D/Proto Gli 1/Armature/Skeleton/Shin_r"
@onready var thigh_r = $"../CharacterBody3D/Proto Gli 1/Armature/Skeleton/Thigh_r"
@onready var shin_guard = $"../CharacterBody3D/Proto Gli 1/Armature/Skeleton/Shin Guard"
@onready var boot = $"../CharacterBody3D/Proto Gli 1/Armature/Skeleton/Boot"

@onready var ui_hand_l = $"SubViewportContainer/SubViewport/Node3D/CharacterBody3D/Proto Gli 1/Armature/Skeleton/Hand_l"
@onready var ui_lowerarm_l = $"SubViewportContainer/SubViewport/Node3D/CharacterBody3D/Proto Gli 1/Armature/Skeleton/LowerArm_l"
@onready var ui_thigh_r = $"SubViewportContainer/SubViewport/Node3D/CharacterBody3D/Proto Gli 1/Armature/Skeleton/Thigh_r"
@onready var ui_shin_r = $"SubViewportContainer/SubViewport/Node3D/CharacterBody3D/Proto Gli 1/Armature/Skeleton/Shin_r"
@onready var ui_shin_guard = $"SubViewportContainer/SubViewport/Node3D/CharacterBody3D/Proto Gli 1/Armature/Skeleton/Shin Guard"
@onready var ui_boot = $"SubViewportContainer/SubViewport/Node3D/CharacterBody3D/Proto Gli 1/Armature/Skeleton/Boot"
@onready var ui_skeleton = $"SubViewportContainer/SubViewport/Node3D/CharacterBody3D/Proto Gli 1/Armature/Skeleton"

@onready var left_arm_button = $"ColorRect2/VBoxContainer/HBoxContainer/TextureButton"
@onready var right_leg_button = $"ColorRect/VBoxContainer/HBoxContainer2/TextureButton"

var is_open: bool = false
var left_arm_equipped: String = "default"
var right_leg_equipped: String = "default"

var violin_scene = preload("res://Grafting/Violin/Violin 1.fbx")
var violin_icon = load("res://Grafting/violin icon.png")
var saw_scene = preload("res://Grafting/saw.fbx")
var saw_icon = load("res://Grafting/saw_icon.png")
var sledgehammer_scene = preload("res://Grafting/Sledgehammer.fbx")
var sledgehammer_icon = load("res://Grafting/sledgehammer_icon.png")

func _ready() -> void:
	set_process_input(true)
	visible = false
	left_arm_button.texture_normal = violin_icon
	left_arm_button.gui_input.connect(_on_left_arm_input)
	right_leg_button.texture_normal = sledgehammer_icon
	right_leg_button.pressed.connect(_on_right_leg_pressed)

func _input(event) -> void:
	if event is InputEventKey and event.pressed:
		if event.keycode == KEY_G:
			is_open = !is_open
			visible = is_open

# Helper

func attach_graft(skeleton: Skeleton3D, graft_name: String, scene: PackedScene, bone_name: String, bone_idx: int, position: Vector3, rotation: Vector3, scale: Vector3) -> void:
	var existing = skeleton.get_node_or_null(graft_name)
	if existing:
		existing.free()
	
	var attachment = BoneAttachment3D.new()
	attachment.name = graft_name
	attachment.bone_name = bone_name
	attachment.bone_idx = bone_idx
	skeleton.add_child(attachment)
	attachment.owner = skeleton
	
	var instance = scene.instantiate()
	attachment.add_child(instance)
	
	for child in instance.get_children():
		if child is OmniLight3D:
			child.queue_free()
	
	instance.position = position
	instance.rotation_degrees = rotation
	instance.scale = scale

func remove_graft(skeleton: Skeleton3D, graft_name: String) -> void:
	var attachment = skeleton.get_node_or_null(graft_name)
	if attachment:
		attachment.free()


func _on_left_arm_input(event: InputEvent) -> void:
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			if left_arm_equipped == "violin":
				unequip_left_arm()
			else:
				equip_violin()
		elif event.button_index == MOUSE_BUTTON_RIGHT:
			if left_arm_equipped == "saw":
				unequip_left_arm()
			else:
				equip_saw()

func equip_violin() -> void:
	hand_l.visible = false
	lowerarm_l.visible = false
	ui_hand_l.visible = false
	ui_lowerarm_l.visible = false
	
	var skeleton = hand_l.get_parent() as Skeleton3D
	attach_graft(skeleton, "LeftArmGraft", violin_scene, "LowerArm_l", 11, Vector3(0,0,0), Vector3(180,90,90), Vector3(1,1,1))
	attach_graft(ui_skeleton, "LeftArmGraft", violin_scene, "LowerArm_l", 11, Vector3(0,0,0), Vector3(180,90,110), Vector3(1,1,1))
	
	left_arm_button.texture_normal = violin_icon
	left_arm_equipped = "violin"

func equip_saw() -> void:
	hand_l.visible = false
	lowerarm_l.visible = false
	ui_hand_l.visible = false
	ui_lowerarm_l.visible = false
	
	var skeleton = hand_l.get_parent() as Skeleton3D
	attach_graft(skeleton, "LeftArmGraft", saw_scene, "UpperArm_l", 10, Vector3(0,0,0), Vector3(0,-70,0), Vector3(1,1,1))
	attach_graft(ui_skeleton, "LeftArmGraft", saw_scene, "UpperArm_l", 10, Vector3(0,0,0), Vector3(0,-70,0), Vector3(1,1,1))
	
	left_arm_button.texture_normal = saw_icon
	left_arm_equipped = "saw"

func unequip_left_arm() -> void:
	hand_l.visible = true
	lowerarm_l.visible = true
	ui_hand_l.visible = true
	ui_lowerarm_l.visible = true
	
	var skeleton = hand_l.get_parent() as Skeleton3D
	remove_graft(skeleton, "LeftArmGraft")
	remove_graft(ui_skeleton, "LeftArmGraft")
	
	left_arm_button.texture_normal = null
	left_arm_equipped = "default"

func _on_right_leg_pressed() -> void:
	if right_leg_equipped == "default":
		equip_right_leg()
	else:
		unequip_right_leg()

func equip_right_leg() -> void:
	thigh_r.visible = false
	shin_r.visible = false
	shin_guard.visible = false
	boot.visible = false
	ui_thigh_r.visible = false
	ui_shin_r.visible = false
	ui_shin_guard.visible = false
	ui_boot.visible = false
	
	var skeleton = thigh_r.get_parent() as Skeleton3D
	attach_graft(skeleton, "RightLegGraft", sledgehammer_scene, "Thigh_r", 24, Vector3(0,2.1,0), Vector3(0,0,0), Vector3(2.3,2.3,2.3))
	attach_graft(ui_skeleton, "RightLegGraft", sledgehammer_scene, "Thigh_r", 24, Vector3(0,2.1,0), Vector3(0,0,0), Vector3(2.3,2.3,2.3))
	
	right_leg_button.texture_normal = sledgehammer_icon
	right_leg_equipped = "sledgehammer"

func unequip_right_leg() -> void:
	thigh_r.visible = true
	shin_r.visible = true
	shin_guard.visible = true
	boot.visible = true
	ui_thigh_r.visible = true
	ui_shin_r.visible = true
	ui_shin_guard.visible = true
	ui_boot.visible = true
	
	var skeleton = thigh_r.get_parent() as Skeleton3D
	remove_graft(skeleton, "RightLegGraft")
	remove_graft(ui_skeleton, "RightLegGraft")
	
	right_leg_button.texture_normal = null
	right_leg_equipped = "default"
