extends Node
var pauseScene = preload("res://Grafting/Equip UI.tscn") # EquipUI scene
var pauseInstance
@export var canvas : CanvasLayer
@export var equip_ui: Control
@onready var hud_label: Label = get_tree().root.get_node("Root/CanvasLayer/Label")

func _ready() -> void:
	print(get_tree().root.get_children())
	await get_tree().process_frame
	await get_tree().process_frame
	var players = get_tree().get_nodes_in_group("player")
	for p in players:
		var char_cam = p.get_node_or_null("CameraPivot/CharacterCam")
		if char_cam:
			char_cam.make_current()
			return

func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_cancel"):
		if get_tree().paused:
			_toggle_menu_camera(false)
			get_tree().paused = false
			pauseInstance.queue_free()
			hud_label.visible = true
			SFXPlayer.play_sfx(load("res://Sounds/SFX/WIN_CLO_001.wav"))
		else:
			pauseInstance = pauseScene.instantiate()
			canvas.add_child(pauseInstance)
			GraftGlobals.menu_opened.emit()
			get_tree().paused = true
			_toggle_menu_camera(true)
			hud_label.visible = false
			SFXPlayer.play_sfx(load("res://Sounds/SFX/STA_OPE_001.wav"))
			

func _toggle_menu_camera(active: bool) -> void:
	var players = get_tree().get_nodes_in_group("player")
	var player = null
	for p in players:
		if not p.is_inside_tree():
			continue
		var parent = p.get_parent()
		var is_in_subviewport = false
		while parent != null:
			if parent is SubViewport:
				is_in_subviewport = true
				break
			parent = parent.get_parent()
		if not is_in_subviewport:
			player = p
			break

	if player:
		var pivot = player.get_node_or_null("CameraPivot")
		if pivot:
			pivot.menu_open = active
		var menu_cam = player.get_node_or_null("MenuCamera")
		var char_cam = player.get_node_or_null("CameraPivot/CharacterCam")
	if player:
		var pivot = player.get_node_or_null("CameraPivot")
		if pivot:
			pivot.menu_open = active
		var menu_cam = player.get_node_or_null("MenuCamera")
		var char_cam = player.get_node_or_null("CameraPivot/CharacterCam")
		if menu_cam and char_cam:
			if active:
				menu_cam.make_current()
				if player.has_method("face_menu_camera"):
					player.face_menu_camera()
			else:
				char_cam.make_current()
