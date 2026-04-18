extends Area3D

var inRange : bool = false
@export var timelineName : String
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if inRange and Input.is_action_just_pressed("ui_interact"):
		if Dialogic.current_timeline != null:
			return
		Dialogic.start(timelineName)
		get_viewport().set_input_as_handled()


func _on_body_entered(body: Node3D) -> void:
	inRange = true
	$CanvasLayer/Prompt.visible = true
	var world_pos = global_transform.origin + Vector3(0, 0.5, 0) # offset above
	var screen_pos = get_viewport().get_camera_3d().unproject_position(world_pos)
	$CanvasLayer/Prompt.position = screen_pos


func _on_body_exited(body: Node3D) -> void:
	inRange = false
	$CanvasLayer/Prompt.visible = false
