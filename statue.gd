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

		var dir = Vector3.ZERO

		if left:
			dir = Vector3(1, 0, 0)
		elif right:
			dir = Vector3(-1, 0, 0)
		elif front:
			dir = Vector3(0, 0, -1)
		elif back:
			dir = Vector3(0, 0, 1)

		# ✅ NEW: collision check BEFORE tween
		if can_move(dir, distance):

			var tween = create_tween()

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
		else:
			$".".global_transform.origin = Vector3(-2.194,0.002,2.128)
			$"../Statue2".global_transform.origin = Vector3(-0.755,0.002,2.128)
			$"../Statue3".global_transform.origin = Vector3(0.562,0.002,1.386)
func can_move(direction: Vector3, distance: float) -> bool:
	var space_state = get_world_3d().direct_space_state

	var from = global_position
	var to = global_position + direction * distance

	var query = PhysicsRayQueryParameters3D.create(from, to)
	query.exclude = [self]

	var result = space_state.intersect_ray(query)

	return result.is_empty()

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
