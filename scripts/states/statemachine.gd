# StateMachine.gd
extends Node
class_name StateMachine

signal state_changed(new_state: State)

@export var initial_state: State
@export var anim_tree: AnimationTree

@onready var animMachine = anim_tree.get("parameters/playback")

var current_state: State
var player: CharacterBody3D

func _ready():
	player = get_parent()

	for state in get_children():
		state.player = player
		state.state_machine = self

	current_state = initial_state
	current_state.enter()
	
	Dialogic.timeline_started.connect(_on_dialogue_start)
	ObjectiveManager.cutsceneStart.connect(_on_dialogue_start)
	Dialogic.timeline_ended.connect(_on_dialogue_end)

func _on_dialogue_start():
	change_state(initial_state)
	player.stop_horizontal()

func _on_dialogue_end():
	change_state(initial_state)

func change_state(new_state: State):
	if new_state == current_state or new_state == null:
		return

	if current_state:
		current_state.exit()

	current_state = new_state
	current_state.enter()

	emit_signal("state_changed", current_state)

func _physics_process(delta):
	if Dialogic.current_timeline != null:
		player.velocity.x = 0
		player.velocity.z = 0
		player.move_and_slide()
		return

	if current_state:
		current_state.physics_update(delta)

	player.move_and_slide()
