class_name PromptManager extends Node

var camera : Camera3D
@export var interactPrompt : Control

func _ready() -> void:
	Dialogue.interactRange.connect(_promptVisible)

func _promptVisible(npc : NPC, inRange : bool) -> void:
	camera = CamMan.instance.getPlayerCam()
	var screen_pos = camera.unproject_position(npc.global_transform.origin)
	interactPrompt.position = screen_pos + Vector2(0, -75)
	if Dialogic.current_timeline == null:
		interactPrompt.visible = inRange
	
