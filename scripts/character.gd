extends CharacterBody3D


const SPEED = 2.0
const JUMP_VELOCITY = 2.5
@onready var edge_ray: RayCast3D = $EdgeRay
@export var camera : Camera3D


func _rotate_toward_movement(delta, direction):
	const TURN_SPEED = 9.0
	var move_dir := Vector3(velocity.x, 0, velocity.z)

	if move_dir.length() < 0.05:
		return

	rotation.y = lerp_angle(rotation.y, (atan2(direction.x, direction.z) - PI / 2), delta * TURN_SPEED)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Dialogic.current_timeline != null:
		return
	# Kept this incase statemachine didn't work
	#var input_dir = Vector2(
		#Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		#Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	#)
		#
	## Add the gravity.
	#
#
	## Handle jump.
	#if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		#velocity.y = JUMP_VELOCITY
#
	#if input_dir == Vector2(0,0):
		#camera = CamMan.instance.getPlayerCam()
	#
	#var cam_basis = camera.global_transform.basis
#
	#var cam_forward = cam_basis.z
	#var cam_right = cam_basis.x
	#cam_forward.y = 0
	#cam_right.y = 0
	##left over from making ledge detection
	#if not edge_ray.is_colliding():
		#var basis = self.global_transform.basis
		#var forward = basis.z
		#forward.y = 0
		#
#
	#var direction = (cam_right * input_dir.x + cam_forward * input_dir.y).normalized()
#
#
	#velocity.x = direction.x * SPEED
	#velocity.z = direction.z * SPEED
#
	#_rotate_toward_movement(delta, direction)
	#move_and_slide()
	#
func _get_input() -> Vector2:
	return Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)

func _get_camera_direction(input_dir: Vector2) -> Vector3:
	if input_dir == Vector2.ZERO:
		camera = CamMan.instance.getPlayerCam()

	var cam_basis = camera.global_transform.basis
	var cam_forward = cam_basis.z
	var cam_right = cam_basis.x

	cam_forward.y = 0
	cam_right.y = 0

	return (cam_right * input_dir.x + cam_forward * input_dir.y).normalized()

func rotate_toward(direction: Vector3, delta: float):
	const TURN_SPEED = 9.0
	var move_dir = Vector3(velocity.x, 0, velocity.z)
	if move_dir.length() < 0.05:
		return
	rotation.y = lerp_angle(rotation.y, atan2(direction.x, direction.z) - PI / 2, delta * TURN_SPEED)
