extends Area3D

var inRange : bool = false
@onready var node: Node3D = $".."
@onready var canvasprompt: Control = null
var auto_skip := false
@export var library: Node3D
@onready var particle_scene = preload("res://Particles/GlowingRingParticle.tscn")

var active_particles = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.signal_event.connect(DialogicSignal)
	Dialogic.timeline_ended.connect(_on_cutscene_ended)
	BattleManager.battle_ended.connect(_on_battle_ended)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Keep prompt positioned correctly
	#if inRange:
		#var prompt = get_prompt()
#
		#if prompt:
			#var world_pos = global_transform.origin + Vector3(0, 0.5, 0)
			#var screen_pos = get_viewport().get_camera_3d().unproject_position(world_pos)
			#prompt.position = screen_pos

	if Input.is_action_just_pressed("mouse_right"):

		if Dialogic.current_timeline != null:

			auto_skip = !auto_skip

			Dialogic.Inputs.auto_skip.enabled = auto_skip
			print("Auto Skip:", auto_skip)

	
	if Input.is_action_just_pressed("ui_interact") and inRange:
		var targetname = get_parent().name
		print(targetname)
		if Dialogic.current_timeline == null:
			#create a node with an area 3d and collision shape. set collisions to mask 2 add to the list below and voila!
			var start_dialogue = true
			match targetname:
				"book_pink":
					Dialogic.VAR.set_variable("target","book_pink")
				"book_blue":
					Dialogic.VAR.set_variable("target","book_blue")
				"book_green":
					Dialogic.VAR.set_variable("target","book_green")
				"book_purple":
					Dialogic.VAR.set_variable("target","book_purple")	
				"Statue3":
					Dialogic.VAR.set_variable("target","statue_3")
				"Statue4":
					Dialogic.VAR.set_variable("target","statue_4")
				"rock":
					Dialogic.VAR.set_variable("target","rock")
				"paper":
					Dialogic.VAR.set_variable("target","paper")
				"scissors":
					Dialogic.VAR.set_variable("target","scissor")
				#"Churchbro":
					#Dialogic.VAR.set_variable("target","churchbro")
				"NPC3":
					Dialogic.VAR.set_variable("target","npc3")
					#Dialogic.VAR.set_variable("target","npc3")
					#ObjectiveManager.complete_objective("inspect_library")
					ObjectiveManager.complete_objective("talk_npc3")
					#ObjectiveManager.reveal_objective("talk_churchbro")
				"NPC6":
					Dialogic.VAR.set_variable("target","npc6")
				"NPC4":
					Dialogic.VAR.set_variable("target","npc4")
				"NPC5":
					if GraftGlobals.churchmanDefeated:
						Dialogic.VAR.set_variable("target", "npc5_postchurch")
						
					else:
						Dialogic.VAR.set_variable("target", "npc5")
						ObjectiveManager.complete_objective("talk_npc5")
						ObjectiveManager.reveal_objective("enter_church")
						GraftGlobals.npc5Talked = true
				"Angry Steve":
					var game = get_tree().current_scene
					game.from_overworld_to_battle()
				"Churchbro":
					start_dialogue = false
			if start_dialogue:
				Dialogic.start("timelinelayer2")
				print("timeline started, current: ", Dialogic.current_timeline)
			get_viewport().set_input_as_handled()
		else:
			pass
	
func DialogicSignal(arg:String):
	#use this to catch signals
	#Prevents other npcs of the same type from listening to signal
	if not inRange:
		return
	#removes trash
	match arg:
		"remove_object":
			pass
		"rock_red":
			library.turn_red()
		"paper_blue":
			library.turn_blue()
		"scissor_green":
			library.turn_green()
		"reset_puzzle":
			library.reset_colors()
		"puzzle2_complete":
			GraftGlobals.libraryDone = true
			ObjectiveManager.complete_objective("solve_puzzle")
			ObjectiveManager.complete_objective("explore_area")
			ObjectiveManager.reveal_objective("fight_churchman")
		"angry_steve":
			pass
		"open_gate":
			ObjectiveManager.OpenGate.emit()

func _on_body_entered(body: Node3D) -> void:
	inRange = true
	var targetname = get_parent().name
	print("churchman1Talked: ", GraftGlobals.churchman1Talked)
	print("libraryDone: ", GraftGlobals.libraryDone)
	print("churchmanPostLibraryTalked: ", GraftGlobals.churchmanPostLibraryTalked)
	
	if targetname == "Churchbro" and GraftGlobals.churchbroDefeated:
		return
	
	var prompt = get_prompt()
	if prompt:
		prompt.visible = true
	
	if active_particles == null:
		active_particles = particle_scene.instantiate()
		active_particles.global_transform = $CollisionShape3D.global_transform
		active_particles.set_as_top_level(true)
		active_particles.scale = Vector3(0.2,0.2,0.2)
		get_tree().current_scene.add_child(active_particles)
	
	match targetname:
		"Chill Derek":
			pass
		"Aggressive Cornelius":
			pass
		"Angry Steve":
			pass
		"Church Man1":
			if Dialogic.current_timeline == null and not GraftGlobals.churchmanDefeated:
				if not GraftGlobals.churchman1Talked:
					Dialogic.VAR.set_variable("target", "churchman1")
				elif GraftGlobals.libraryDone and not GraftGlobals.churchmanPostLibraryTalked:
					Dialogic.VAR.set_variable("target", "churchman_postlibrary")
				else:
					return
				Dialogic.start("timelinelayer2")
			if prompt:
				prompt.visible = false
		"Churchbro":
			if not GraftGlobals.churchbroDefeated:
				if prompt:
					prompt.visible = false
				var game = get_tree().current_scene
				game.from_overworld_to_battle()

func _on_body_exited(body: Node3D) -> void:
	inRange = false
	
	var prompt = get_prompt()

	if prompt:
		prompt.visible = false
	
	if active_particles:
		active_particles.queue_free()
		active_particles = null

func _on_cutscene_ended():
	if get_parent().name == "Churchbro":
		if GraftGlobals.churchbroDefeated:
			monitoring = false
		return
	if get_parent().name != "Church Man1":
		return
	if not inRange:
		return
	if GraftGlobals.churchmanDefeated:
		get_node("Church Man1")
		Dialogic.VAR.set_variable("target", "churchman_defeated")
		Dialogic.start_timeline("timelinelayer2")
		return
	if not GraftGlobals.churchman1Talked:
		GraftGlobals.churchman1Talked = true
		ObjectiveManager.complete_objective("enter_church")
		return
	if not GraftGlobals.libraryDone:
		return
	if not GraftGlobals.churchmanPostLibraryTalked:
		GraftGlobals.churchmanPostLibraryTalked = true
		var game = get_tree().current_scene
		game.from_overworld_to_battle()
		return

	
func get_prompt():
	if canvasprompt == null or not is_instance_valid(canvasprompt):
		var prompts = get_tree().get_nodes_in_group("prompt")
		if prompts.size() > 0:
			canvasprompt = prompts[0]

	return canvasprompt

func _on_battle_ended(player_won: bool, weapons_dropped: Array[Weapon], consumables_dropped: Array[Consumable]):
	if get_parent().name == "Churchbro":
		if not player_won:
			return
		GraftGlobals.churchbroDefeated = true
		ObjectiveManager.complete_objective("talk_churchbro")
		ObjectiveManager.reveal_objective("enter_church")
		monitoring = false
		Dialogic.VAR.set_variable("target", "churchbro_defeated")
		Dialogic.start("timelinelayer2")
	elif get_parent().name == "Church Man1":
		if not player_won:
			return
		GraftGlobals.churchmanDefeated = true
		ObjectiveManager.complete_objective("fight_churchman")
		ObjectiveManager.reveal_objective("return_to_stairs")
