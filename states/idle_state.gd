extends State

@export var move_state : State
@export var jump_state : State
@export var fall_state : State

func enter():
	# Stop horizontal movement
	player.velocity.x = 0
	player.velocity.z = 0

func physics_update(delta):
	var input_dir = player._get_input()

	# If player moves, switch to MoveState
	if input_dir != Vector2.ZERO:
		state_machine.change_state(move_state)
		return

	# If player jumps, switch to JumpState
	if Input.is_action_just_pressed("ui_accept"):
		state_machine.change_state(jump_state)
		return

	# If player falls off edge, switch to FallState
	if not player.is_on_floor():
		state_machine.change_state(fall_state)
