extends CharacterBody3D

@onready var animation_player: AnimationPlayer = %AnimationPlayer
@onready var armature: Node3D = $"MAsked Gli/Armature"
var _meshes: Array[MeshInstance3D] = []
var _flash_material: ShaderMaterial
var _is_acting: bool = false

const BLEND_TIME: float = 0.15

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
