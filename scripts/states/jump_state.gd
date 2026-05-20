extends State

@export var fall_state : State

func enter():
	player.velocity.y = player.JUMP_VELOCITY
	#state_machine.animMachine.travel("Jump")

func physics_update(delta):
	var direction = player.get_move_direction()

	player.move_horizontal(direction)
	player.rotate_toward(direction, delta)

	if player.velocity.y < 0:
		state_machine.change_state(fall_state)
