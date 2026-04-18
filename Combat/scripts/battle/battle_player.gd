extends CharacterBody3D

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var armature: Node3D = $"MAsked Gli/Armature"
var _meshes: Array[MeshInstance3D] = []
var _flash_material: ShaderMaterial
var _is_acting: bool = false

const BLEND_TIME: float = 0.15

# ── Graft visuals ─────────────────────────────────────────────────────────────
@onready var _graft_scenes: Dictionary = {
	preload("res://Combat/resources/weapons/saw.tres"):           preload("res://Grafting/SawGraft.tscn"),
	preload("res://Combat/resources/weapons/hose.tres"):          preload("res://Grafting/HoseGraft.tscn"),
	preload("res://Combat/resources/weapons/sledge_hammer.tres"): preload("res://Grafting/SledgehammerGraft.tscn"),
}

@onready var _right_arm_attach: BoneAttachment3D = $"MAsked Gli/Armature/Skeleton/RightArmGraft"
@onready var _left_leg_attach: BoneAttachment3D  = $"MAsked Gli/Armature/Skeleton/LeftLegGraft"

@onready var _arm_base_parts: Array[Node3D] = [
	$"MAsked Gli/Armature/Skeleton/LowerArm_r",
	$"MAsked Gli/Armature/Skeleton/Hand_r",
]
@onready var _leg_base_parts: Array[Node3D] = [
	$"MAsked Gli/Armature/Skeleton/Thigh_l",
	$"MAsked Gli/Armature/Skeleton/Shin_l",
	$"MAsked Gli/Armature/Skeleton/Shin Guard_001",
	$"MAsked Gli/Armature/Skeleton/Boot_001",
]

func _ready() -> void:
	var flash_shader = preload("res://Shaders/flash2.gdshader")
	_flash_material = ShaderMaterial.new()
	_flash_material.shader = flash_shader
	_flash_material.set_shader_parameter("flash_intensity", 0.0)
	_flash_material.set_shader_parameter("flash_color", Vector3(1, 0.2, 0.2))

	_collect_meshes(armature, _meshes)
	for mesh in _meshes:
		mesh.material_overlay = _flash_material

	animation_player.play("Idle Straight")

	BattleManager.player_attacked.connect(_on_player_attacked)
	BattleManager.player_hit.connect(_on_player_hit)
	BattleManager.equipped_weapon_changed.connect(_on_equipped_changed)

	# Make sure equipped reflects current overworld grafts, then paint the model
	PlayerManager.sync_from_grafts()
	_apply_graft_visual(0, PlayerManager.data.equipped[0])  # arm
	_apply_graft_visual(1, PlayerManager.data.equipped[1])  # leg

func _collect_meshes(node: Node, result: Array[MeshInstance3D]) -> void:
	for child in node.get_children():
		if child is MeshInstance3D:
			result.append(child)
		_collect_meshes(child, result)

func _flash() -> void:
	_flash_material.set_shader_parameter("flash_intensity", 1.0)
	var tween := get_tree().create_tween()
	tween.tween_property(_flash_material, "shader_parameter/flash_intensity", 1.2, 0.03)
	tween.tween_property(_flash_material, "shader_parameter/flash_intensity", 1.0, 0.05)
	tween.tween_property(_flash_material, "shader_parameter/flash_intensity", 0.0, 0.25)\
		.set_trans(Tween.TRANS_QUAD)\
		.set_ease(Tween.EASE_OUT)

func _on_player_attacked() -> void:
	if _is_acting:
		return
	_is_acting = true
	animation_player.play("Cast Spell", BLEND_TIME, 2.0)
	await animation_player.animation_finished
	animation_player.play("Idle Straight", BLEND_TIME)
	_is_acting = false

func _on_player_hit(_damage: int, was_blocked: bool) -> void:
	if was_blocked:
		return
	if _is_acting:
		_flash()
		return
	_flash()
	_is_acting = true
	animation_player.play("get Hit", BLEND_TIME)
	await animation_player.animation_finished
	animation_player.play("Idle Straight", BLEND_TIME)
	_is_acting = false

# ── Graft visual handling ────────────────────────────────────────────────────
func _on_equipped_changed(slot: int, new_weapon: Weapon) -> void:
	_apply_graft_visual(slot, new_weapon)

func _apply_graft_visual(slot: int, weapon: Weapon) -> void:
	var attach: BoneAttachment3D
	var base_parts: Array[Node3D]
	if slot == 0:
		attach = _right_arm_attach
		base_parts = _arm_base_parts
	else:
		attach = _left_leg_attach
		base_parts = _leg_base_parts

	# Clear any existing graft model on this limb
	for child in attach.get_children():
		child.queue_free()

	var graft_scene: PackedScene = _graft_scenes.get(weapon)
	if graft_scene == null:
		# Base limb (gli_arm / gli_leg) — show natural body parts
		for part in base_parts:
			if part: part.visible = true
	else:
		# Graft — hide natural parts, spawn graft model, flash overlay
		for part in base_parts:
			if part: part.visible = false
		var graft_instance := graft_scene.instantiate()
		attach.add_child(graft_instance)
		_apply_flash_overlay(graft_instance)

func _apply_flash_overlay(node: Node) -> void:
	# New graft meshes need the same overlay so they flash red with the rest
	# of the body when the player gets hit.
	if node is MeshInstance3D:
		node.material_overlay = _flash_material
	for child in node.get_children():
		_apply_flash_overlay(child)
