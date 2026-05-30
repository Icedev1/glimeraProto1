extends Node
var pauseScene = preload("res://Grafting/Equip UI.tscn") # EquipUI scene
var pauseInstance
@export var canvas : CanvasLayer
@export var equip_ui: Control
@onready var hud_label: Label = get_tree().root.get_node("Root/CanvasLayer/Label")
@onready var objective_display = get_tree().root.get_node("Root/CanvasLayer/ObjectiveDisplay")

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
	if Input.is_action_just_pressed("ui_cancel") and !BattleManager._battle_active:
		if get_tree().paused:
			_toggle_menu_camera(false)
			get_tree().paused = false
			pauseInstance.queue_free()
			hud_label.visible = true
			objective_display.visible = true
			SFXPlayer.play_sfx(load("res://Sounds/SFX/WIN_CLO_001.wav"))
		else:
			pauseInstance = pauseScene.instantiate()
			canvas.add_child(pauseInstance)
			GraftGlobals.menu_opened.emit()
			get_tree().paused = true
			_toggle_menu_camera(true)
			hud_label.visible = false
			objective_display.visible = false
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

	if not player:
		return

	var pivot = player.get_node_or_null("CameraPivot")
	if pivot:
		pivot.menu_open = active

	var menu_cam = player.get_node_or_null("MenuCamera")
	var char_cam = player.get_node_or_null("CameraPivot/CharacterCam")
	var transition_cam = player.get_node_or_null("CameraPivot/TransitionCam")

	if not menu_cam or not char_cam or not transition_cam:
		return

	var from_cam : Camera3D
	var to_cam : Camera3D

	if active:
		from_cam = char_cam
		to_cam = menu_cam
	else:
		from_cam = menu_cam
		to_cam = char_cam


	transition_cam.global_transform = from_cam.global_transform


	transition_cam.make_current()


	if active and player.has_method("face_menu_camera"):
		player.face_menu_camera()


	var tween = create_tween()
	tween.set_parallel(true)

	tween.tween_property(
		transition_cam,
		"global_position",
		to_cam.global_position,
		0.35
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	tween.tween_property(
		transition_cam,
		"global_rotation",
		to_cam.global_rotation,
		0.35
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await tween.finished


	to_cam.make_current()
