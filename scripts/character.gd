extends CharacterBody3D

const SPEED := 2.0
const JUMP_VELOCITY := 2.0
const TURN_SPEED := 9.0

@onready var camera := $"CameraPivot/CharacterCam" as Camera3D
@onready var camera_pivot := $CameraPivot as Node3D
@onready var model := $"MAsked Gli" as Node3D

var knockback_velocity := Vector3.ZERO
var knockback_time := 0.0

func _physics_process(delta):
	# Gravity
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Knockback
	if knockback_time > 0.0:
		velocity += knockback_velocity
		knockback_time -= delta

func get_input() -> Vector3:
	return Vector3(
		Input.get_action_strength("move_right")
		- Input.get_action_strength("move_left"),

		0.0,

		Input.get_action_strength("move_down")
		- Input.get_action_strength("move_up")
	)

func get_move_direction() -> Vector3:
	var input_dir := get_input()

	if input_dir == Vector3.ZERO:
		return Vector3.ZERO

	var cam_basis = camera.global_transform.basis

	# THIS matches your original logic
	var forward = cam_basis.z
	var right = cam_basis.x

	forward.y = 0
	right.y = 0

	forward = forward.normalized()
	right = right.normalized()

	return (right * input_dir.x + forward * input_dir.z).normalized()

func move_horizontal(direction: Vector3):
	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED

func stop_horizontal():
	velocity.x = 0
	velocity.z = 0

func rotate_toward(direction: Vector3, delta: float):
	if direction.length() < 0.01:
		return

	var target_angle = atan2(direction.x, direction.z) - PI / 2

	model.rotation.y = lerp_angle(
		model.rotation.y,
		target_angle,
		delta * TURN_SPEED
	)

func apply_knockback(dir: Vector3, strength := 4.0, duration := 0.2):
	knockback_velocity = dir.normalized() * strength
	knockback_time = duration

func reset_model_rotation() -> void:
	$"MAsked Gli".rotation.y = 0.0

func face_menu_camera() -> void:
	var menu_cam = get_node_or_null("MenuCamera")
	if menu_cam:
		var dir = menu_cam.global_position - global_position
		dir.y = 0
		dir = dir.normalized()
		var target_angle = atan2(dir.x, dir.z) - PI / 2
		$"MAsked Gli".rotation.y = target_angle


func _on_respawn_area_3d_body_entered(body: Node3D) -> void:
	$".".global_transform.origin = Vector3.ZERO # Replace with function body.
