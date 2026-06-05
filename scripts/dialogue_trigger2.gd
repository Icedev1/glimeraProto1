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
				"Churchbro":
					Dialogic.VAR.set_variable("target","churchbro")
				"NPC3":
					Dialogic.VAR.set_variable("target","npc3")
					Dialogic.VAR.set_variable("target","npc3")
					#ObjectiveManager.complete_objective("inspect_library")
					ObjectiveManager.complete_objective("talk_npc3")
					ObjectiveManager.reveal_objective("talk_churchbro")
				"NPC6":
					Dialogic.VAR.set_variable("target","npc6")
				"NPC4":
					Dialogic.VAR.set_variable("target","npc4")
				"NPC5":
					Dialogic.VAR.set_variable("target","npc5")
				"Angry Steve":
					var game = get_tree().current_scene
					game.from_overworld_to_battle()
				"Churchbro":
					Dialogic.VAR.set_variable("target","churchbro")
					ObjectiveManager.complete_objective("talk_churchbro")
					ObjectiveManager.reveal_objective("enter_church")
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
			#put reward here.
			pass
		"angry_steve":
			pass

func _on_body_entered(body: Node3D) -> void:
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
	
	var targetname = get_parent().name
	match targetname:
		"Chill Derek":
			pass
		"Aggressive Cornelius":
			pass
		"Angry Steve":
			pass
		"Church Man1":
			if Dialogic.current_timeline == null:
				Dialogic.VAR.set_variable("target", "churchman1")
				Dialogic.start("timelinelayer2")
			if prompt:
				prompt.visible = false

func _on_body_exited(body: Node3D) -> void:
	inRange = false
	
	var prompt = get_prompt()

	if prompt:
		prompt.visible = false
	
	if active_particles:
		active_particles.queue_free()
		active_particles = null

func _on_cutscene_ended():
	if get_parent().name != "Church Man1":
		return
	if not inRange:
		return
	var game = get_tree().current_scene
	game.from_overworld_to_battle()
	
func get_prompt():
	if canvasprompt == null or not is_instance_valid(canvasprompt):
		var prompts = get_tree().get_nodes_in_group("prompt")
		if prompts.size() > 0:
			canvasprompt = prompts[0]

	return canvasprompt
