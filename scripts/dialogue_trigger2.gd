extends Area3D

var inRange : bool = false
@onready var node: Node3D = $".."
@onready var canvasprompt: Control = null
var auto_skip := false
@onready var library: Node3D = $"../../.."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.signal_event.connect(DialogicSignal)

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
				"Angry Steve":
					var game = get_tree().current_scene
					game.from_overworld_to_battle()
			
			Dialogic.start("timelinelayer2")
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
	
	#triggers battle on touch
	var targetname = get_parent().name
	match targetname:
		#"door_lr":			
			#var player = $"../../../CharacterBody3D"
			#if player:
				#player.rotate_y(PI)
				#var push_dir = Vector3(0, 0, -0.1)	
				#player.apply_knockback(push_dir, 3.0, 0.25)
				#Dialogic.VAR.set_variable("target","door_lr")
				#Dialogic.start("bedroom")
				#get_viewport().set_input_as_handled()
				#
			#prompt.visible = false
		"Chill Derek":
			pass
		"Aggressive Cornelius":
			pass
		"Angry Steve":
			pass
	
	

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
