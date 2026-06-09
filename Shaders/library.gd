extends Node3D
@onready var handmesh: MeshInstance3D = $metarig/Plane005
@onready var handmesh2: MeshInstance3D = $metarig_001/Plane005_001
@onready var handmesh3: MeshInstance3D = $metarig_002/Plane005_002
var material : StandardMaterial3D
var material2 : StandardMaterial3D
var material3 : StandardMaterial3D
@onready var cylinder_006: MeshInstance3D = $Cylinder_006
@onready var collision_shape_3d: CollisionShape3D = $Cylinder_006/StaticBody3D/CollisionShape3D


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	material = handmesh.get_active_material(0).duplicate()
	material2 = handmesh2.get_active_material(0).duplicate()
	material3 = handmesh3.get_active_material(0).duplicate()
	
	handmesh.set_surface_override_material(0, material)
	handmesh2.set_surface_override_material(0, material2)
	handmesh3.set_surface_override_material(0, material3)
	
	cylinder_006.visible = false
	collision_shape_3d.disabled = true
	
	ObjectiveManager.complete_objective("inspect_library")
	ObjectiveManager.reveal_objective("solve_puzzle")

	reset_colors()

func reset_colors():

	material.albedo_color = Color.RED
	material2.albedo_color = Color.BLUE
	material3.albedo_color = Color.GREEN

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass

func turn_red():
	if material.albedo_color == Color.WHITE:
		material.albedo_color = Color.RED
		appear_pillar()
	else:
		material.albedo_color = Color.WHITE

func turn_blue():
	if material2.albedo_color == Color.WHITE:
		material2.albedo_color = Color.BLUE
	else:
		material2.albedo_color = Color.WHITE

func turn_green():
	if material3.albedo_color == Color.WHITE:
		material3.albedo_color = Color.GREEN
	else:
		material3.albedo_color = Color.WHITE
		
func appear_pillar():
	cylinder_006.visible = true
	collision_shape_3d.disabled = false
