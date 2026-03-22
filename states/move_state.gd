extends State

@export var idle_state : State
@export var jump_state : State
@export var fall_state : State

func physics_update(delta):
	var input_dir = player._get_input()
	var direction = player._get_camera_direction(input_dir)

	# Edge detection leftover from your script (optional for ledge later)
	if not player.edge_ray.is_colliding():
		var forward = player.global_transform.basis.z
		forward.y = 0

	# Check transitions
	if not player.is_on_floor():
		state_machine.change_state(fall_state)
		return

	if Input.is_action_just_pressed("ui_accept"):
		state_machine.change_state(jump_state)
		return

	if input_dir == Vector2.ZERO:
		state_machine.change_state(idle_state)
		player.camera = CamMan.instance.getPlayerCam()
		return

	# Camera-relative movement
	player.velocity.x = direction.x * player.SPEED
	player.velocity.z = direction.z * player.SPEED
	player.rotate_toward(direction, delta)
