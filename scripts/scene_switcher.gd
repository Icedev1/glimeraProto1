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
		if Dialogic.current_timeline == null:
			open_menu()

func open_menu() -> void:
	if _is_open():
		return
	pauseInstance = pauseScene.instantiate()
	canvas.add_child(pauseInstance)
	# lets the Equip UI's back button ask to be closed
	if pauseInstance.has_signal("close_requested"):
		pauseInstance.close_requested.connect(close_menu)
	GraftGlobals.menu_opened.emit()
	get_tree().paused = true
	_toggle_menu_camera(true)
	hud_label.visible = false
	objective_display.visible = false
	SFXPlayer.play_sfx(load("res://Sounds/SFX/STA_OPE_001.wav"))

func close_menu() -> void:
	if not _is_open():
		return
	_toggle_menu_camera(false)
	get_tree().paused = false
	pauseInstance.queue_free()
	pauseInstance = null
	hud_label.visible = true
	objective_display.visible = true
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
	var char_cam = player.get_node_or_null("CameraPivot/CharacterCam")
	var transition_cam = player.get_node_or_null("CameraPivot/TransitionCam")
	var model = player.get_node_or_null("MAsked Gli")
	if not menu_cam or not char_cam or not transition_cam:
		return

	if active:
		var forward = model.global_transform.basis.z
		forward.y = 0
		forward = forward.normalized()
		menu_cam.global_position = player.global_position + forward * 1.2 + Vector3.UP * 0.6
		menu_cam.look_at(player.global_position + Vector3.UP * 0.4, Vector3.UP)
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
	var tween = create_tween()
	tween.set_parallel(true)
	tween.tween_property(
		transition_cam,
		"global_transform",
		to_cam.global_transform,
		0.35
	).set_trans(Tween.TRANS_SINE).set_ease(Tween.EASE_IN_OUT)
	await tween.finished
	to_cam.make_current()
