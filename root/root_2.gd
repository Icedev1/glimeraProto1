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

var current_battle_enemy: EnemyData = null   


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
	get_viewport().use_occlusion_culling = false
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

	show_street("gli's_house")
	

func start_battle(battle_scene_path: String, enemy_data: EnemyData = null):
	MusicPlayer.play_music(load("res://Sounds/hipstop1_2.ogg"))
	current_state = "battle"
	if enemy_data != null:
		current_battle_enemy = enemy_data  
	
	ui_scene.hide()
	overworld_container.hide()
	overworld_container.process_mode = Node.PROCESS_MODE_DISABLED
	
	_load_battle(battle_scene_path, current_battle_enemy)
	
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

func _load_battle(path: String, enemy_data: EnemyData = null):
	_cleanup_battle()
	
	var scene = load(path).instantiate()
	if enemy_data != null:
		scene.enemy_resource = enemy_data
	
	battle_container.add_child(scene)
	current_battle = scene

func _cleanup_battle():
	if current_battle:
		if PlayerManager.data.inventory.has(preload("res://Combat/resources/weapons/saw.tres")):
			GraftGlobals.sawObtained = true
			print("NYOOOOM")
		if PlayerManager.data.inventory.has(preload("res://Combat/resources/weapons/hose.tres")):
			GraftGlobals.hoseObtained = true
			print("pshhhhhh")
		#if BattleManager.enemy == preload("res://Combat/resources/enemies/boss1/boss1.tres"):
			#if BattleManager.enemy.unit
			#get_tree().change_scene_to_file("res://Sounds/SFX/Bye.tscn")
		current_battle.queue_free()
		current_battle = null

# -----------------
# TRANSITIONS
# -----------------

#This is where you add the transitions.
func from_main_menu_to_overworld():
	transition1.playfade(func():
		$CanvasLayer.show()
		switch_world_scene("res://gli's_house.tscn")
	)

func from_overworld_to_battle(enemy_data: EnemyData = null):
	transition2.playscreenshatter(func():
		start_battle("res://Combat/scenes/battle.tscn", enemy_data)
	)

func from_battle_to_overworld():
	overworld_container.process_mode = Node.PROCESS_MODE_ALWAYS
	transition1.playfade(func():
		show_overworld()
		var players = get_tree().get_nodes_in_group("player")
		for p in players:
			if not p.is_inside_tree():
				continue
			var menu_cam = p.get_node_or_null("MenuCamera")
			var char_cam = p.get_node_or_null("CameraPivot/CharacterCam")
			if menu_cam and char_cam:
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
