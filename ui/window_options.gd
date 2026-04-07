extends OptionButton


func _on_item_selected(index: int) -> void:
	if index == 0:
		#Windowed
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, false)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	elif index == 1:
		#Borderless
		DisplayServer.window_set_flag(DisplayServer.WINDOW_FLAG_BORDERLESS, true)
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_WINDOWED)
	elif index == 2:
		#Fullscreen
		DisplayServer.window_set_mode(DisplayServer.WINDOW_MODE_FULLSCREEN)

func _on_resolution_options_item_selected(index: int) -> void:
	var resolution = {
		0: Vector2i(1280,800),
		1: Vector2i(1920,1200),
		2: Vector2i(1280,720),
		3: Vector2i(1920,1080),
		4: Vector2i(2560,1440)
		}
	get_tree().root.content_scale_size = resolution.get(index)
	
	


func _on_check_button_toggled(toggled_on: bool) -> void:
	if toggled_on:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_ENABLED)
	else:
		DisplayServer.window_set_vsync_mode(DisplayServer.VSYNC_DISABLED)
