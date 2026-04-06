extends Control

@onready var background: Panel = $Background
@onready var title: Label = $Title
@onready var menu_buttons: VBoxContainer = $MenuButtons
@onready var settings: Panel = $Settings
@onready var button_sfx: AudioStreamPlayer = $ButtonSFX
@onready var background_music: AudioStreamPlayer = $"Background Music"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	title.visible = true
	menu_buttons.visible = true
	settings.visible = false
	#Turns on Background effects.
	background.get_child(0).visible = true

func _on_start_button_pressed() -> void:
	button_sfx.play()
	await button_sfx.finished
	background_music.stop()
	get_tree().root.get_node("Root").from_main_menu_to_overworld()
	pass

func _on_settings_button_pressed() -> void:
	button_sfx.play()
	title.visible = false
	menu_buttons.visible = false
	settings.visible = true


func _on_quit_button_pressed() -> void:
	button_sfx.play()
	get_tree().quit()


func _on_back_button_pressed() -> void:
	button_sfx.play()	
	_ready()
