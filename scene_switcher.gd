extends Node
var pauseScene = preload("res://Equip UI.tscn")
var pauseInstance
@export var canvas : CanvasLayer

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if get_tree().paused:
			get_tree().paused = false
			pauseInstance.queue_free()
		else:
			get_tree().paused = true
			pauseInstance = pauseScene.instantiate()
			canvas.add_child(pauseInstance)
			

		
