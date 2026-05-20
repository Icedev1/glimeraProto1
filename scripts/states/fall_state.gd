extends State

@export var idle_state : State
@export var move_state : State
@export var jump_state : State

func enter():
	#state_machine.animMachine.travel("Fall")
	pass

func physics_update(delta):
	var direction = player.get_move_direction()

	player.move_horizontal(direction)
	player.rotate_toward(direction, delta)

	if player.is_on_floor():
		if direction == Vector3.ZERO:
			state_machine.change_state(idle_state)
		else:
			state_machine.change_state(move_state)
