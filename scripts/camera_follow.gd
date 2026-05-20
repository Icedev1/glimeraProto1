extends Camera3D

@export var spring_arm: Node3D
@export var lerp_power: float = 1.0
var original_pos : Vector3
var following_player: bool = true

func ready() -> void:
	PlayerManager.cameraswitch.connect(on_camera_switch)

func _process(delta: float) -> void:
	if not following_player:
		return
	if spring_arm == null:
		print("SPRING ARM IS NULL!")
		return
	if not current:
		return
	global_position = lerp(global_position, spring_arm.global_position, delta*lerp_power)
	
	
func on_camera_switch(to_player: bool, camera : Camera3D) -> void:
	if camera == null:
		var tween = create_tween()
		original_pos = global_position

		tween.tween_property(self, "global_transform", self.global_transform, 1.0)\
			.set_trans(Tween.TRANS_SINE)\
				.set_ease(Tween.EASE_IN_OUT)
		following_player = false

		
	else:
		var tween = create_tween()
		tween.tween_property(self, "global_transform", original_pos, 1.0)
		following_player = true
