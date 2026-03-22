extends Node
class_name StateMachine

signal state_changed(new_state: State)

var player : CharacterBody3D
var current_state : State

@export var initial_state : State

func _ready():
	player = get_parent()
	
	for state in get_children():
		state.player = player
		state.state_machine = self
	
	current_state = initial_state
	current_state.call_deferred("enter")
	
	emit_signal("state_changed", current_state)


func change_state(new_state: State):
	if new_state == null or new_state == current_state:
		return
	
	if current_state:
		current_state.exit()

	current_state = new_state
	current_state.enter()
	
	emit_signal("state_changed", current_state)


func _process(delta):
	if current_state and Dialogic.current_timeline == null:
		current_state.update(delta)


func _physics_process(delta):
	if current_state and Dialogic.current_timeline == null:
		current_state.physics_update(delta)
	
	if player and Dialogic.current_timeline == null:
		player.move_and_slide()
