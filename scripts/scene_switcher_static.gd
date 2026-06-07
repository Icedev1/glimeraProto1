extends Node
var pauseScene = preload("res://Grafting/Equip UI.tscn") # EquipUI scene
var pauseInstance
var char_cam
var camera_tween : Tween
var current_target_camera : Camera3D
var gameplay_camera : Camera3D
@export var canvas : CanvasLayer
@export var equip_ui: Control
@onready var hud_label: Label = get_tree().root.get_node("Root/CanvasLayer/Label")

func _ready() -> void:
	print(get_tree().root.get_children())
	await get_tree().process_frame
	await get_tree().process_frame
	var players = get_tree().get_nodes_in_group("player")

func _process(_delta: float) -> void:
	if BattleManager._battle_active:
		return
	if Input.is_action_just_pressed("ui_cancel"):
		toggle_menu()


func _is_open() -> bool:
	return is_instance_valid(pauseInstance)

func toggle_menu() -> void:
	if _is_open():
		close_menu()
	else:
		open_menu()

func open_menu() -> void:
	if _is_open():
		return
	pauseInstance = pauseScene.instantiate()
	canvas.add_child(pauseInstance)
	
	if pauseInstance.has_signal("close_requested"):
		pauseInstance.close_requested.connect(close_menu)
	GraftGlobals.menu_opened.emit()
	get_tree().paused = true
	_toggle_menu_camera(true)
	hud_label.visible = false
	SFXPlayer.play_sfx(load("res://Sounds/SFX/STA_OPE_001.wav"))

func close_menu() -> void:
	if not _is_open():
		return
	_toggle_menu_camera(false)
	get_tree().paused = false
	pauseInstance.queue_free()
	pauseInstance = null
	hud_label.visible = true
	SFXPlayer.play_sfx(load("res://Sounds/SFX/WIN_CLO_001.wav"))

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
	if active:
		var char_cam = CamMan.instance.getPlayerCam()
	var transition_cam = $"../Camera3D3/TransitionCamera"

	if not menu_cam or not char_cam or not transition_cam:
		return

	var to_cam : Camera3D

	if active:
		to_cam = menu_cam
	else:
		to_cam = char_cam.get_parent() as Camera3D

	current_target_camera = to_cam

	# Stop previous transition safely
	if camera_tween and camera_tween.is_valid():
		camera_tween.kill()

	# IMPORTANT:
	# Only snap to current camera if transition cam is NOT already active
	if not transition_cam.current:
		transition_cam.global_transform = get_viewport().get_camera_3d().global_transform

	transition_cam.make_current()

	if active and player.has_method("face_menu_camera"):
		player.face_menu_camera()

	camera_tween = create_tween()
	camera_tween.set_parallel(true)

	camera_tween.tween_property(
		transition_cam,
		"global_position",
		to_cam.global_position,
		0.35
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	camera_tween.tween_property(
		transition_cam,
		"global_rotation",
		to_cam.global_rotation,
		0.35
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)

	await camera_tween.finished

	# Prevent old awaits from overriding newer transitions
	if current_target_camera == to_cam:
		to_cam.make_current() 
