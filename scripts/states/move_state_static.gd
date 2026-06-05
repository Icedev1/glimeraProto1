extends State
@export var idle_state : State
@export var jump_state : State
@export var fall_state : State

var anim_player = null

func enter():
	state_machine.animMachine.travel("Walk")
	anim_player = player.get_node_or_null("AnimationPlayer")

func physics_update(delta):
	var input_dir = player._get_input()
	var direction = player._get_camera_direction(input_dir)
	
	if anim_player:
		anim_player.speed_scale = player.SPEED / 1.2

	if not player.is_on_floor():
		state_machine.change_state(fall_state)
		return
	if Input.is_action_just_pressed("ui_accept"):
		state_machine.change_state(jump_state)
		return
	if input_dir == Vector2.ZERO:
		state_machine.change_state(idle_state)
		return
	player.velocity.x = direction.x * player.SPEED
	player.velocity.z = direction.z * player.SPEED
	player.rotate_toward(direction, delta)
