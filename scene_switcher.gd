extends Node
var pauseScene = preload("res://Grafting/Equip UI.tscn") # EquipUI scene
var pauseInstance
@export var canvas : CanvasLayer

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if get_tree().paused:
			get_tree().paused = false
			pauseInstance.queue_free()
			SFXPlayer.play_sfx(load("res://Sounds/SFX/WIN_CLO_001.wav"))
		else:
			pauseInstance = pauseScene.instantiate()
			canvas.add_child(pauseInstance)
			GraftGlobals.menu_opened.emit()
			get_tree().paused = true
			SFXPlayer.play_sfx(load("res://Sounds/SFX/STA_OPE_001.wav"))
			

		
