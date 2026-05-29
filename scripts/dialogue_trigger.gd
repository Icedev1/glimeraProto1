extends Area3D

var inRange : bool = false
@onready var node: Node3D = $".."
@onready var canvasprompt: Control = null
var auto_skip := false
@onready var particle_scene = preload("res://Particles/GlowingRingParticle.tscn")

var active_particles = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.signal_event.connect(DialogicSignal)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if get_parent().name == "Angry Steve" and GraftGlobals.angrySteveDead:
		get_parent().hide()
		return
		
	if Input.is_action_just_pressed("mouse_right"):
		if Dialogic.current_timeline != null:

			auto_skip = !auto_skip

			Dialogic.Inputs.auto_skip.enabled = auto_skip
			print("Auto Skip:", auto_skip)

	
	if Input.is_action_just_pressed("ui_interact") and inRange:
		var targetname = get_parent().name
		if Dialogic.current_timeline == null:
			var skip = false
			#create a node with an area 3d and collision shape. set collisions to mask 2 add to the list below and voila!
			match targetname:
				#GLI HOUSE
				"trash":
					Dialogic.VAR.set_variable("target", "junk")
					ObjectiveManager.complete_objective("pickup_sledgehammer")
				"violin":
					Dialogic.VAR.set_variable("target", "violin")
					ObjectiveManager.complete_objective("pickup_violin")
					ObjectiveManager.reveal_objective("pickup_sledgehammer")
				"bed":
					Dialogic.VAR.set_variable("target", "bed")
				"clock":
					Dialogic.VAR.set_variable("target", "clock")
				"window":
					Dialogic.VAR.set_variable("target", "window")
				"door_fd":
					Dialogic.VAR.set_variable("target", "door_fd")
				"Roland":
					Dialogic.VAR.set_variable("target", "roland")
				"door_glihouse":
					Dialogic.VAR.set_variable("target", "door_glihouse")
				"door_neighbour1":
					Dialogic.VAR.set_variable("target", "door_neighbour1")
					ObjectiveManager.complete_objective("see_figure")
					ObjectiveManager.reveal_objective("find_noise")
				"door_neighbour2":
					Dialogic.VAR.set_variable("target", "door_neighbour2")
				"door_building1":
					Dialogic.VAR.set_variable("target", "door_building1")
				"door_building2":
					Dialogic.VAR.set_variable("target", "door_building1")
				"door_building3":
					Dialogic.VAR.set_variable("target", "door_building1")
				"door_building4":
					Dialogic.VAR.set_variable("target", "door_building1")
				"door_building5":
					Dialogic.VAR.set_variable("target", "door_building1")
				"door_building6":
					Dialogic.VAR.set_variable("target", "door_building1")
				"door_building7":
					Dialogic.VAR.set_variable("target", "door_building7")
				"door_building8":
					Dialogic.VAR.set_variable("target", "door_building1")
				"door_building9":
					Dialogic.VAR.set_variable("target", "door_building1")
				"door_building10":
					Dialogic.VAR.set_variable("target", "door_building1")
				"npc2":
					Dialogic.VAR.set_variable("target", "npc2")
				#"Passive Bob":
					#Dialogic.VAR.set_variable("target","passive_bob")
				#"Calm Marcus":
					#Dialogic.VAR.set_variable("target","frz_chr_outside_house")

				"Chill Derek":  # Nervous Figure (market quest NPC)
					Dialogic.VAR.set_variable("target","quest_npc_1")
					ObjectiveManager.reveal_objective("help_figure")

				"Angry Steve":# Jittery Vendor (market combat NPC)
					var game = get_tree().current_scene
					game.from_overworld_to_battle()

							# STREET 2
				"Porcelain Figure":
					if GraftGlobals.porcelainDefeated:
						Dialogic.VAR.set_variable("target", "porcelain_figure_defeated")
					else:
						skip = true
				#"Porcelain Figure Defeated":
					#Dialogic.VAR.set_variable("target", "porcelain_figure_defeated")
				"Evene":
					Dialogic.VAR.set_variable("target", "evene")
					ObjectiveManager.complete_objective("find_noise")
				
				# STAIRS (first visit)
				"Stairs":
					Dialogic.VAR.set_variable("target", "stairs")
					ObjectiveManager.complete_objective("inspect_stairs")
					ObjectiveManager.reveal_objective("find_climb")
				
				# MARKET
				"Nervous Figure":
					Dialogic.VAR.set_variable("target", "nervous_figure")
					ObjectiveManager.reveal_objective("help_figure")
				"Overjoyed Figure":
					Dialogic.VAR.set_variable("target", "overjoyed_figure")
				"Figure1":
					Dialogic.VAR.set_variable("target", "figure1")
				"Figure2":
					Dialogic.VAR.set_variable("target", "figure2")
				"Figure3":
					Dialogic.VAR.set_variable("target", "figure3")
				"Jittery Vendor":
					Dialogic.VAR.set_variable("target", "jittery_vendor")
				
				# STAIRS AGAIN
				"Intimidating Figure":
					Dialogic.VAR.set_variable("target", "intimidating_figure")
				
			if skip:
				return
			Dialogic.start("interactable")
			get_viewport().set_input_as_handled()

	
func DialogicSignal(arg:String):
	#use this to catch signals
	#Prevents other npcs of the same type from listening to signal
	if not inRange:
		return
	#removes trash
	match arg:
		"remove_object": 
			node.queue_free()
		"open_door":
			var game = get_tree().current_scene
			game.transition_to_street("res://Streets/Street1-1.tscn", "Spawn_FromHouse")
		"roland_talked":
			ObjectiveManager.complete_objective("pickup_violin")
			ObjectiveManager.complete_objective("pickup_sledgehammer")
			ObjectiveManager.set_main_quest("Try to figure out what happened")
		"enable_glihouse":
			pass
		"saw_picked_up":
			GraftGlobals.sawObtained = true
			PlayerManager.sync_from_grafts()
		"open_door7":
			%AnimationPlayerDoor.play("door_opening")
		"close_door7":
			%AnimationPlayerDoor.play_backwards("door_opening")
		"start_quest_1":
			print("quest 1 started")
			$"../../Statue".process_mode = Node.PROCESS_MODE_INHERIT
			$"../../Statue2".process_mode = Node.PROCESS_MODE_INHERIT
			$"../../Statue3".process_mode = Node.PROCESS_MODE_INHERIT
			Dialogic.VAR.set_variable("quest_1","started")
		"reset_quest_1":
			$"../../Statue".global_transform.origin = Vector3(-2.194,0.002,2.128)
			$"../../Statue2".global_transform.origin = Vector3(-0.755,0.002,2.128)
			$"../../Statue3".global_transform.origin = Vector3(0.562,0.002,1.386)
		#"angry_steve":
			#pass
		"garden_hose_received":
			print("garden_hose_received fired")
			ObjectiveManager.complete_objective("help_figure")
			ObjectiveManager.complete_objective("find_climb")
			ObjectiveManager.reveal_objective("climb_stairs")
		"inspect_stairs_done":
			ObjectiveManager.complete_objective("inspect_stairs")
			ObjectiveManager.reveal_objective("find_climb")
		"porcelain_defeated":
		# post-combat inspect triggers — handled by combat system
			pass
		"climb_stairs":
			ObjectiveManager.complete_objective("climb_stairs")
			ObjectiveManager.advance_layer()
			pass

func _on_body_entered(body: Node3D) -> void:
	if get_parent().name == "Angry Steve" and GraftGlobals.angrySteveDead:
		get_parent().hide()
		return
	
	print("dialogue_trigger body entered: ", get_parent().name, " body: ", body.name)
	inRange = true
	
	var prompt = get_prompt()
	if prompt:
		prompt.visible = true
	
	if active_particles == null:
		active_particles = particle_scene.instantiate()
		active_particles.global_transform = $CollisionShape3D.global_transform
		active_particles.set_as_top_level(true)
		active_particles.scale = Vector3(0.2,0.2,0.2)
		get_tree().current_scene.add_child(active_particles)
	#triggers battle on touch
	var targetname = get_parent().name
	match targetname:
		"door_lr":			
			var player = $"../../../CharacterBody3D"
			if player:
				player.rotate_y(PI)
				var push_dir = Vector3(0, 0, -0.1)	
				player.apply_knockback(push_dir, 3.0, 0.25)
				Dialogic.VAR.set_variable("target","door_lr")
				Dialogic.start("interactable")
				get_viewport().set_input_as_handled()
				
			prompt.visible = false
		"Chill Derek": # Nervous Figure - statue quest completion
			if body.collision_layer & (1 << 4):
				prompt.visible = false
				StoryFlags.statueQuestComplete = true
				Dialogic.VAR.set_variable("target", "nervous_figure")
				Dialogic.start("interactable")
				get_viewport().set_input_as_handled()
				$"../../Statue/StaticBody3D".queue_free()
				$"../../Statue/left".queue_free()
				$"../../Statue/right".queue_free()
				$"../../Statue/back".queue_free()
				$"../../Statue/front".queue_free()
			elif body.collision_layer & (1 << 5):
				prompt.visible = false
				Dialogic.VAR.set_variable("wrong_statue", true)
				Dialogic.VAR.set_variable("target", "nervous_figure")
				Dialogic.start("interactable")
				get_viewport().set_input_as_handled()
				
		"Aggressive Cornelius":
			var game = get_tree().current_scene
			game.from_overworld_to_battle("res://Combat/resources/enemies/enemy1/enemy1.tres")
			$"..".chasing = false
		"Angry Steve":
			get_tree().root.get_node("Root").from_overworld_to_battle(
				preload("res://Combat/resources/enemies/tutorial enemies/tutorial_enemy2.tres"),"res://Combat/scenes/battle_tutorial.tscn")
			$"..".chasing = false
	
	

func _on_body_exited(body: Node3D) -> void:
	inRange = false
	
	var prompt = get_prompt()

	if prompt:
		prompt.visible = false
		
	if active_particles:
		active_particles.queue_free()
		active_particles = null


func get_prompt():
	if canvasprompt == null or not is_instance_valid(canvasprompt):
		var prompts = get_tree().get_nodes_in_group("prompt")
		if prompts.size() > 0:
			canvasprompt = prompts[0]

	return canvasprompt


func _on_interaction_volume_body_entered(body: Node3D) -> void:
	_on_body_entered(body)


func _on_interaction_volume_body_exited(body: Node3D) -> void:
	_on_body_exited(body)
