extends State

@export var move_state : State
@export var jump_state : State
@export var fall_state : State

func enter():
	player.stop_horizontal()
	state_machine.animMachine.travel("Idle")

func physics_update(delta):
	var direction = player.get_move_direction()
	
	if Input.is_action_just_pressed("jump"):
		state_machine.change_state(jump_state)
		return

	if not player.is_on_floor():
		state_machine.change_state(fall_state)

	if direction != Vector3.ZERO:
		state_machine.change_state(move_state)
		return
