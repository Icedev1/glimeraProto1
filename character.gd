extends CharacterBody3D


const SPEED = 3.0
const JUMP_VELOCITY = 4.5
@onready var edge_ray: RayCast3D = $EdgeRay


func _rotate_toward_movement(delta, direction):
	const TURN_SPEED = 9.0
	var move_dir := Vector3(velocity.x, 0, velocity.z)

	if move_dir.length() < 0.05:
		return

	rotation.y = lerp_angle(rotation.y, (atan2(direction.x, direction.z) - PI / 2), delta * TURN_SPEED)


func _physics_process(delta: float) -> void:
	var camera = CamMan.instance.getPlayerCam()
	
	#var input_dir := Input.get_vector("ui_left", "ui_right", "ui_up", "ui_down")
	var input_dir = Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
	)
		
	# Add the gravity.
	if not is_on_floor():
		velocity += get_gravity() * delta

	# Handle jump.
	if Input.is_action_just_pressed("ui_accept") and is_on_floor():
		velocity.y = JUMP_VELOCITY

	# Get the input direction and handle the movement/deceleration.
	# As good practice, you should replace UI actions with custom gameplay actions.
	
	var cam_basis = camera.global_transform.basis

	var cam_forward = cam_basis.z
	var cam_right = cam_basis.x
	cam_forward.y = 0
	cam_right.y = 0

	var direction = (cam_right * input_dir.x + cam_forward * input_dir.y).normalized()


	velocity.x = direction.x * SPEED
	velocity.z = direction.z * SPEED

	_rotate_toward_movement(delta, direction)
	move_and_slide()
