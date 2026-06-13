extends Control

@onready var background: TextureRect = $Background
@onready var title: Label = $Title
@onready var menu_buttons: VBoxContainer = $MenuButtons
@onready var settings: Panel = $Settings
@onready var button_sfx: AudioStreamPlayer = $ButtonSFX
@onready var background_music: AudioStreamPlayer = $"Background Music"


func _ready() -> void:
	#title.visible = true
	menu_buttons.visible = true
	settings.visible = false
	#Turns on Background effects.
	#background.get_child(0).visible = true

func _on_start_button_pressed() -> void:
	button_sfx.play()
	background_music.stop()
	get_tree().root.get_node("Root").from_main_menu_to_overworld()

func _on_settings_button_pressed() -> void:
	button_sfx.play()
	#get_tree().root.get_node("Root").screenshake()
	#title.visible = false
	menu_buttons.visible = false
	settings.visible = true


func _on_quit_button_pressed() -> void:
	button_sfx.play()
	get_tree().quit()


func _on_back_button_pressed() -> void:
	button_sfx.play()	
	#get_tree().root.get_node("Root").screenshake()
	_ready()

#hovering
func _on_start_button_mouse_entered() -> void:
	_hover_on($MenuButtons/StartButton)

func _on_start_button_mouse_exited() -> void:
	_hover_off($MenuButtons/StartButton)

func _on_settings_button_mouse_entered() -> void:
	_hover_on($MenuButtons/SettingsButton)

func _on_settings_button_mouse_exited() -> void:
	_hover_off($MenuButtons/SettingsButton)

func _on_quit_button_mouse_entered() -> void:
	_hover_on($MenuButtons/QuitButton)

func _on_quit_button_mouse_exited() -> void:
	_hover_off($MenuButtons/QuitButton)

var _tweens = {}

func _hover_on(button: Button) -> void:
	var clock = button.get_node("ClockIcon")
	var label = button.get_node("Label")
	var label2 = button.get_node("Label2")
	
	if _tweens.has(button.name):
		_tweens[button.name].kill()
	
	button.text = ""
	clock.visible = true
	label.visible = true
	label2.visible = true
	
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tweens[button.name] = tween
	tween.tween_property(clock, "modulate:a", 1.0, 0.3)

func _hover_off(button: Button) -> void:
	var clock = button.get_node("ClockIcon")
	var label = button.get_node("Label")
	var label2 = button.get_node("Label2")
	
	if _tweens.has(button.name):
		_tweens[button.name].kill()
	
	if button.name == "StartButton":
		button.text = "Start"
	elif button.name == "SettingsButton":
		button.text = "Settings"
	elif button.name == "QuitButton":
		button.text = "Quit"
	
	var tween = create_tween().set_ease(Tween.EASE_IN).set_trans(Tween.TRANS_CUBIC)
	_tweens[button.name] = tween
	tween.tween_property(clock, "modulate:a", 0.0, 0.2)
	tween.tween_callback(func():
		clock.visible = false
		label.visible = false
		label2.visible = false
	)

#pressing
func _on_start_button_button_down() -> void:
	_press_on($MenuButtons/StartButton)

func _on_start_button_button_up() -> void:
	_press_off($MenuButtons/StartButton)

func _on_settings_button_button_down() -> void:
	_press_on($MenuButtons/SettingsButton)

func _on_settings_button_button_up() -> void:
	_press_off($MenuButtons/SettingsButton)

func _on_quit_button_button_down() -> void:
	_press_on($MenuButtons/QuitButton)

func _on_quit_button_button_up() -> void:
	_press_off($MenuButtons/QuitButton)

func _press_on(button: Button) -> void:
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	tween.tween_property(button, "scale", Vector2(0.95, 0.95), 0.08)

func _press_off(button: Button) -> void:
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_BACK)
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.15)
