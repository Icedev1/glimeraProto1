extends State

@export var fall_state : State

func enter():
	player.velocity.y = player.JUMP_VELOCITY

func physics_update(delta):
	# Transition to fall immediately after jump is applied
	state_machine.change_state(fall_state)
