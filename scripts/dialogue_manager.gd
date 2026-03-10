class_name DialMan extends Node

var character : NPC
var inRange : bool = false
@export var dialBox : Control

	
func _process(delta: float) -> void:
	if inRange and Input.is_action_just_pressed("ui_interact"):
		if Dialogic.current_timeline == null:
			Dialogic.start("timeline")
			get_viewport().set_input_as_handled()
		else:
			pass
		
		
func _ready() -> void:
	Dialogue.interactRange.connect(setNPC)
	
func setNPC(npc : NPC, range : bool):
	character = npc
	inRange = range

func showDialogue():
	dialBox.visible = true
	
	
	
