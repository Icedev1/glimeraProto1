extends Node


func _unhandled_key_input(event: InputEvent) -> void:

	if event.is_action_pressed("Reload_Scene"):
		get_tree().reload_current_scene()
	elif event.is_action_pressed("Quit_Scene"):
		get_tree().quit()
	elif event.is_action_pressed("FullScreen_Mode"):
		var is_fullscreen : bool = DisplayServer.window_get_mode() == DisplayServer.WINDOW_MODE_FULLSCREEN
		var target_mode : int = DisplayServer.WINDOW_MODE_WINDOWED if is_fullscreen else DisplayServer.WINDOW_MODE_FULLSCREEN
		DisplayServer.window_set_mode(target_mode)
	elif event.is_action_pressed("Slow_Mode"):
		Engine.time_scale = 0.25 if Engine.time_scale == 1.0 else 1.0
