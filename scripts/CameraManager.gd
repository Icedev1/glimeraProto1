class_name CamMan
extends Node3D

static var instance: CamMan

func _ready():
	for camSwitch in get_tree().get_nodes_in_group("camera_switches"):
		camSwitch.switch.connect(_on_camera_switch)
	instance = self

func getPlayerCam() -> Camera3D:
	return get_viewport().get_camera_3d()
	
	


func _on_camera_switch(area: CameraSwitch) -> void:
	if !area.cam.is_current():
		area.cam.make_current()
		print("switched camera")
