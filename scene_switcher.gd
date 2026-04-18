extends Node
var pauseScene = preload("res://Grafting/Equip UI.tscn") # EquipUI scene
var pauseInstance
@export var canvas : CanvasLayer

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if get_tree().paused:
			get_tree().paused = false
			pauseInstance.queue_free()
		else:
			pauseInstance = pauseScene.instantiate()
			canvas.add_child(pauseInstance)
			GraftGlobals.menu_opened.emit()
			get_tree().paused = true
			

		
