class_name CamMan
extends Node3D

static var instance: CamMan

func _ready():
	for camSwitch in get_tree().get_nodes_in_group("camera_switches"):
		camSwitch.switch.connect(_on_camera_switch)
	instance = self

func getPlayerCam() -> Camera3D:
	return get_viewport().get_camera_3d()
	
	
func move_to_camera(target_camera: Camera3D):
	var tween = create_tween()

	tween.tween_property(self, "global_transform", target_camera.global_transform, 1.0)\
		.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN_OUT)

func _on_camera_switch(area: CameraSwitch) -> void:
	#if !area.cam.is_current():
		#area.cam.current = true
	var tween = create_tween()

	tween.tween_property(getPlayerCam(), "global_transform", area.cam.global_transform, 1.0)\
		.set_trans(Tween.TRANS_SINE)\
		.set_ease(Tween.EASE_IN_OUT)
	print("switched camera")
