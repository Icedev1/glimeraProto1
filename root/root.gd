extends Node

@onready var ui_scene = $UIScene
@onready var overworld = $Overworld3D
@onready var battle_container = $BattleScene3D

var current_battle = null
var current_state = ""

func _ready():
	show_main_menu()

# -----------------
# STATE SWITCHING
# -----------------

func show_main_menu():
	current_state = "main_menu"
	
	ui_scene.show()
	overworld.hide()
	_cleanup_battle()
	

func show_overworld():
	current_state = "overworld"
	
	ui_scene.hide()
	overworld.show()
	_cleanup_battle()
	

func start_battle(battle_scene_path: String):
	current_state = "battle"
	
	ui_scene.hide()
	overworld.hide()
	overworld.process_mode = Node.PROCESS_MODE_DISABLED
	
	_load_battle(battle_scene_path)
	

# -----------------
# BATTLE HANDLING
# -----------------

func _load_battle(path: String):
	_cleanup_battle()
	
	var scene = load(path).instantiate()
	battle_container.add_child(scene)
	current_battle = scene

func _cleanup_battle():
	if current_battle:
		current_battle.queue_free()
		current_battle = null

# -----------------
# TRANSITIONS
# -----------------

#This is where you add the transitions.

func from_overworld_to_battle():
	#remember to add a battle_scene here
	start_battle("res://battle_scene.tscn")
