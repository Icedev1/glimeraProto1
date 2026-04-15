extends Node
var pauseScene = preload("uid://cljfxgcfyk4fv") # EquipUI scene
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
			get_tree().paused = true
			
			GraftGlobals.menu_opened.emit()
			

		
