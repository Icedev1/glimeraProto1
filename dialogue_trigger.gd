extends Area3D

var inRange : bool = false
@onready var node: Node3D = $".."
@onready var canvasprompt: Control = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.signal_event.connect(DialogicSignal)
	

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Keep prompt positioned correctly
	if inRange:
		var prompt = get_prompt()

		if prompt:
			var world_pos = global_transform.origin + Vector3(0, 0.5, 0)
			var screen_pos = get_viewport().get_camera_3d().unproject_position(world_pos)
			prompt.position = screen_pos

	
	if Input.is_action_just_pressed("ui_interact") and inRange:
		var targetname = get_parent().name
		if Dialogic.current_timeline == null:
			#create a node with an area 3d and collision shape. set collisions to mask 2 add to the list below and voila!
			match targetname:
				"trash":
					Dialogic.VAR.set_variable("target","junk")
				"violin":
					Dialogic.VAR.set_variable("target","violin")
				"bed":
					Dialogic.VAR.set_variable("target","bed")
				"window":
					Dialogic.VAR.set_variable("target","window")
				"door_fd":
					Dialogic.VAR.set_variable("target","door_fd")
				"Passive Bob":
					Dialogic.VAR.set_variable("target","passive_bob")
				"Calm Marcus":
					Dialogic.VAR.set_variable("target","frz_chr_outside_house")
				"Chill Derek":
					Dialogic.VAR.set_variable("target","quest_npc_1")
				"Angry Steve":
					var game = get_tree().current_scene
					game.from_overworld_to_battle()
			
			Dialogic.start("bedroom")
			get_viewport().set_input_as_handled()
		else:
			pass
	
func DialogicSignal(arg:String):
	#use this to catch signals
	#Prevents other npcs of the same type from listening to signal
	if not inRange:
		return
	#removes trash
	if arg == "remove_object": 
		node.queue_free()
	if arg == "open_door":
		var game = get_tree().current_scene
		game.transition_to_street("res://Street1.tscn", "Spawn_FromHouse")
	if arg == "start_quest_1":
		print("quest 1 started")
		Dialogic.VAR.set_variable("quest_1","started")
	if arg == "angry_steve":
		pass

func _on_body_entered(body: Node3D) -> void:
	inRange = true
	
	var prompt = get_prompt()

	if prompt:
		prompt.visible = true
	
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
				Dialogic.start("bedroom")
				get_viewport().set_input_as_handled()
				
			prompt.visible = false
		"Aggressive Cornelius":
			var game = get_tree().current_scene
			game.from_overworld_to_battle()
	

func _on_body_exited(body: Node3D) -> void:
	inRange = false
	
	var prompt = get_prompt()

	if prompt:
		prompt.visible = false


func get_prompt():
	if canvasprompt == null or not is_instance_valid(canvasprompt):
		var prompts = get_tree().get_nodes_in_group("prompt")
		if prompts.size() > 0:
			canvasprompt = prompts[0]

	return canvasprompt
