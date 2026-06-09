extends Control
@onready var background: TextureRect = $Background
@onready var title: Label = $Title
@onready var menu_buttons: VBoxContainer = $MenuButtons
@onready var settings: Panel = $Settings
@onready var button_sfx: AudioStreamPlayer = $ButtonSFX
@onready var background_music: AudioStreamPlayer = $"Background Music"

func _ready() -> void:
	menu_buttons.visible = true
	settings.visible = false
	_refresh_continue_button()

func _refresh_continue_button() -> void:
	var info = SaveManager.get_slot_info(0)
	var continue_btn = $MenuButtons/ContinueButton
	continue_btn.modulate.a = 1.0
	continue_btn.disabled = false
	if info["empty"] or not info.get("scene", "").contains("Streets"):
		continue_btn.modulate.a = 0.4
		continue_btn.disabled = true

func _on_new_game_button_pressed() -> void:
	button_sfx.play()
	background_music.stop()
	SaveManager.delete_slot(0)
	get_tree().root.get_node("Root").from_main_menu_to_overworld()

func _on_continue_button_pressed() -> void:
	button_sfx.play()
	background_music.stop()
	if SaveManager.load_slot(0):
		if StoryFlags.current_scene == "" or not StoryFlags.current_scene.contains("Streets"):
			get_tree().root.get_node("Root").from_main_menu_to_overworld()
		else:
			get_tree().root.get_node("Root").transition_to_street(
				StoryFlags.current_scene, ""
			)

func _on_settings_button_pressed() -> void:
	button_sfx.play()
	menu_buttons.visible = false
	settings.visible = true

func _on_quit_button_pressed() -> void:
	button_sfx.play()
	get_tree().quit()

func _on_back_button_pressed() -> void:
	button_sfx.play()
	_ready()

# ── Hovering ──────────────────────────────────────────────────────────────────
func _on_new_game_button_mouse_entered() -> void:
	_hover_on($MenuButtons/NewGameButton)
func _on_new_game_button_mouse_exited() -> void:
	_hover_off($MenuButtons/NewGameButton)

func _on_continue_button_mouse_entered() -> void:
	_hover_on($MenuButtons/ContinueButton)
func _on_continue_button_mouse_exited() -> void:
	_hover_off($MenuButtons/ContinueButton)

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
	if _tweens.has(button.name):
		_tweens[button.name].kill()
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tweens[button.name] = tween
	tween.tween_property(button, "scale", Vector2(1.05, 1.05), 0.15)

func _hover_off(button: Button) -> void:
	if _tweens.has(button.name):
		_tweens[button.name].kill()
	var tween = create_tween().set_ease(Tween.EASE_OUT).set_trans(Tween.TRANS_CUBIC)
	_tweens[button.name] = tween
	tween.tween_property(button, "scale", Vector2(1.0, 1.0), 0.15)

# ── Pressing ──────────────────────────────────────────────────────────────────
func _on_new_game_button_button_down() -> void:
	_press_on($MenuButtons/NewGameButton)
func _on_new_game_button_button_up() -> void:
	_press_off($MenuButtons/NewGameButton)

func _on_continue_button_button_down() -> void:
	_press_on($MenuButtons/ContinueButton)
func _on_continue_button_button_up() -> void:
	_press_off($MenuButtons/ContinueButton)

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
