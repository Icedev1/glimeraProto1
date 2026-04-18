extends Node3D

@onready var armature: Node3D = $Armature

var _meshes: Array[MeshInstance3D] = []
var _flash_material: ShaderMaterial

func _ready() -> void:
	var flash_shader = preload("res://Shaders/flash2.gdshader")
	_flash_material = ShaderMaterial.new()
	_flash_material.shader = flash_shader
	_flash_material.set_shader_parameter("flash_intensity", 0.0)
	_flash_material.set_shader_parameter("flash_color", Vector3(1, 0.2, 0.2))

	_collect_meshes(armature, _meshes)
	for mesh in _meshes:
		mesh.material_overlay = _flash_material

	BattleManager.enemy_attacked.connect(_on_enemy_attacked)
	BattleManager.enemy_hit.connect(_on_enemy_hit)

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

func _on_enemy_attacked() -> void:
	pass

func _on_enemy_hit(_damage: int) -> void:
	_flash()
