extends Area3D

var inRange : bool = false
@onready var node: Node3D = $".."

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.signal_event.connect(DialogicSignal)


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
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
			
			Dialogic.start("bedroom")
			get_viewport().set_input_as_handled()
		else:
			pass
	
func DialogicSignal(arg:String):
	#Prevents other npcs of the same type from listening to signal
	if not inRange:
		return
	#removes trash
	if arg == "remove_object": 
		node.queue_free()
	if arg == "open_door":
		var game = get_tree().current_scene
		game.transition_to_street("res://Street1.tscn", "Spawn_FromHouse")
	

func _on_body_entered(body: Node3D) -> void:
	inRange = true

func _on_body_exited(body: Node3D) -> void:
	inRange = false
