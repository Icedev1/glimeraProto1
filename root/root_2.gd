extends Node

@onready var ui_scene = $UIScene
@onready var overworld_container = $Overworld3D
var current_overworld = null

@onready var battle_container = $BattleScene3D

@onready var transition1 = $SceneTransition
@onready var transition2 = $SceneTransition2
@onready var screenshakerect: ColorRect = $SceneShake/ColorRect

var current_battle = null
var current_state = ""

func _ready():
	$SceneTransition/ColorRect.modulate.a = 0
	$SceneTransition2/ColorRect.modulate.a = 0
	
	for child in overworld_container.get_children():
		child.hide()
	
	show_main_menu()

# -----------------
# STATE SWITCHING
# -----------------

func switch_world_scene(scene_name: String):
	if overworld_container.get_child_count() > 0:
		overworld_container.get_child(0).queue_free()
	var newMap = load(scene_name).instantiate()
	overworld_container.add_child(newMap)
	current_overworld = newMap
	overworld_container.show()
	ui_scene.hide()


func show_main_menu():
	current_state = "main_menu"
	
	ui_scene.show()
	overworld_container.hide()
	_cleanup_battle()
	

func show_overworld():
	current_state = "overworld"
	
	ui_scene.hide()
	overworld_container.show()
	_cleanup_battle()

	show_street("Street1")
	

func start_battle(battle_scene_path: String):
	current_state = "battle"
	
	ui_scene.hide()
	overworld_container.hide()
	overworld_container.process_mode = Node.PROCESS_MODE_DISABLED
	
	_load_battle(battle_scene_path)
	
# -----------------
# Handle Overworld
# -----------------

func load_overworld(path: String):
	_cleanup_overworld()

	var scene = load(path).instantiate()
	overworld_container.add_child(scene)

	current_overworld = scene

	# Connect exits automatically
	if scene.has_signal("request_scene_change"):
		scene.request_scene_change.connect(_on_overworld_request_change)

func _cleanup_overworld():
	if current_overworld:
		current_overworld.queue_free()
		current_overworld = null

func _on_overworld_request_change(next_scene_path: String, spawn_name: String):
	load_overworld(next_scene_path)

	# Tell new scene where to place player
	if current_overworld.has_method("spawn_player"):
		current_overworld.spawn_player(spawn_name)

func show_street(street_name: String):

	var street = overworld_container.get_node(street_name)

	if street:
		street.show()
		street.process_mode = Node.PROCESS_MODE_INHERIT



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
func from_main_menu_to_overworld():
	transition1.playfade(func():
		switch_world_scene("res://Street1.tscn")
	)

func from_overworld_to_battle():
	transition2.playscreenshatter(func():
		start_battle("res://Combat/scenes/battle.tscn")
	)

func from_battle_to_overworld():
	overworld_container.process_mode = Node.PROCESS_MODE_ALWAYS
	transition1.playclockwipe(func():
		show_overworld()
	)

func transition_to_street(target_street: String, spawn_name: String):
	transition1.playfade(func():
		switch_world_scene(target_street)
		var spawn = current_overworld.get_node(spawn_name)
		current_overworld.get_node("CharacterBody3D").global_transform.origin = spawn.global_transform.origin
	)

func screenshake():
	screenshakerect.material.set_shader_parameter("ShakeStrength", 0.1)
	await get_tree().create_timer(0.05).timeout	
	screenshakerect.material.set_shader_parameter("ShakeStrength", 0)
