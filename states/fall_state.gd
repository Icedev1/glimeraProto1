extends State

@export var idle_state : State

func physics_update(delta):
	var input_dir = player._get_input()
	var direction = player._get_camera_direction(input_dir)

	player.velocity.x = direction.x * player.SPEED
	player.velocity.z = direction.z * player.SPEED

	if player.is_on_floor():
		state_machine.change_state(idle_state)
