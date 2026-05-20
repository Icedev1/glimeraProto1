extends State

@export var idle_state : State
@export var jump_state : State
@export var fall_state : State

func enter():
	state_machine.animMachine.travel("Walk")

func physics_update(delta):
	var direction = player.get_move_direction()
	
	if Input.is_action_just_pressed("jump"):
		state_machine.change_state(jump_state)
		return

	if not player.is_on_floor():
		state_machine.change_state(fall_state)
		return
	
	if direction == Vector3.ZERO:
		state_machine.change_state(idle_state)
		return


	player.move_horizontal(direction)
	player.rotate_toward(direction, delta)
