class_name DialMan extends Node

var character : NPC
var inRange : bool = false
@export var dialBox : Control

	
func _process(delta: float) -> void:
	if inRange and character != null and Input.is_action_just_pressed("ui_interact"):
		print("DialMan fired, porcelainDefeated: ", GraftGlobals.porcelainDefeated, " character: ", character.name)
	if inRange and character != null and Input.is_action_just_pressed("ui_interact"):
		if Dialogic.current_timeline == null:
			if GraftGlobals.porcelainDefeated and character.name == "Porcelain Figure":
				Dialogic.VAR.set_variable("target", "porcelain_figure_defeated")
				Dialogic.start("interactable")
				get_viewport().set_input_as_handled()
			else:
				Dialogic.start(character.timeline_name)
				get_viewport().set_input_as_handled()
		
func _ready() -> void:
	Dialogue.interactRange.connect(setNPC)
	Dialogic.timeline_ended.connect(_on_timeline_ended)
	
func setNPC(npc : NPC, range : bool):
	if range:
		character = npc
	else:
		character = null
	inRange = range

func showDialogue():
	dialBox.visible = true
	

func _on_timeline_ended():
	character = null
	inRange = false
