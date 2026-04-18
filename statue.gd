extends Node3D

var left = false
var right = false
var front = false
var back = false
@export var distance : float
# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:

	if Input.is_action_just_pressed("ui_interact") and (left or right or front or back):
		var tween = create_tween()
		print("moving statue")
		if left:
			tween.tween_property(self, "global_position", global_position + Vector3(distance, 0, 0), 1.0)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN_OUT)
		elif right:
			tween.tween_property(self, "global_position", global_position + Vector3(-distance, 0, 0), 1.0)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN_OUT)
		elif front:
			tween.tween_property(self, "global_position", global_position + Vector3(0, 0, -distance), 1.0)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN_OUT)
		elif back:
			tween.tween_property(self, "global_position", global_position + Vector3(0, 0, distance), 1.0)\
			.set_trans(Tween.TRANS_SINE)\
			.set_ease(Tween.EASE_IN_OUT)

func _on_left_body_entered(body: Node3D) -> void:
	left = true
	print("left entered")


func _on_left_body_exited(body: Node3D) -> void:
	left = false


func _on_right_body_entered(body: Node3D) -> void:
	right = true
	print("right entered")


func _on_right_body_exited(body: Node3D) -> void:
	right = false


func _on_back_body_entered(body: Node3D) -> void:
	back = true
	print("back entered")


func _on_back_body_exited(body: Node3D) -> void:
	back = false


func _on_front_body_entered(body: Node3D) -> void:
	front = true
	print("front entered")


func _on_front_body_exited(body: Node3D) -> void:
	front = false
