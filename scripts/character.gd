extends CharacterBody3D


const SPEED = 1
const JUMP_VELOCITY = 2.5
@export var camera : Camera3D

func _ready() -> void:
	pass
	
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

func get_input() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_up") - Input.get_action_strength("move_down")
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
