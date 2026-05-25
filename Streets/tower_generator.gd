extends Node3D

func _ready():
	build_tower()

func build_tower():

	create_block(Vector3(0, 0, 0), Vector3(12, 1, 12))

	create_block(Vector3(0, 3, -5.5), Vector3(12, 6, 1))
	create_block(Vector3(-5.5, 3, 0), Vector3(1, 6, 12))
	create_block(Vector3(5.5, 3, 0), Vector3(1, 6, 12))

	create_block(Vector3(-3.5, 3, 5.5), Vector3(4, 6, 1))
	create_block(Vector3(3.5, 3, 5.5), Vector3(4, 6, 1))

	create_block(Vector3(0, 5.5, 5.5), Vector3(4, 1, 1))

	create_block(Vector3(0, 7.5, 0), Vector3(6, 3, 6))

	create_pillar(-5.5, -5.5)
	create_pillar(5.5, -5.5)
	create_pillar(-5.5, 5.5)
	create_pillar(5.5, 5.5)

func create_pillar(x, z):
	create_block(Vector3(x, 4, z), Vector3(1.5, 8, 1.5))

func create_block(pos: Vector3, size: Vector3):

	var mesh_instance = MeshInstance3D.new()

	var box = BoxMesh.new()
	box.size = size

	mesh_instance.mesh = box
	mesh_instance.position = pos

	add_child(mesh_instance)
