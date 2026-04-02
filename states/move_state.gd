extends State

@export var idle_state : State
@export var jump_state : State
@export var fall_state : State

func enter():
	state_machine.animMachine.travel("Walk")
	
func physics_update(delta):
	var input_dir = player.get_input()
	var direction = player._get_camera_direction(input_dir)


	# Check transitions
	if not player.is_on_floor():
		state_machine.change_state(fall_state)
		return

	if Input.is_action_just_pressed("ui_accept"):
		state_machine.change_state(jump_state)
		return
		

	if input_dir == Vector2.ZERO:
		state_machine.change_state(idle_state)
		#Has a bug where the input direction does not change when the player inputs a new direction before letting go of the previous one.
		player.camera = CamMan.instance.getPlayerCam()
		return

	# Camera-relative movement
	player.velocity.x = direction.x * player.SPEED
	player.velocity.z = direction.z * player.SPEED
	player.rotate_toward(direction, delta)
