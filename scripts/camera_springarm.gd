extends Node3D
@export var mouse_sensibility: float = 0.01
@export var default_length: float = 6.0
@export var min_length: float = 0.5
@onready var spring_arm := $SpringArm3D
@onready var spring_position := $"SpringArm3D/SpringPosition"

var menu_open := false:
	set(value):
		menu_open = value
		_update_mouse_mode()


var freelook_enabled := true:
	set(value):
		freelook_enabled = value
		_update_mouse_mode()

func _ready() -> void:
	Dialogic.timeline_started.connect(_on_dialogue_started)
	Dialogic.timeline_ended.connect(_on_dialogue_ended)
	ObjectiveManager.cutsceneStart.connect(_on_dialogue_started)
	_update_mouse_mode()

func _can_look() -> bool:
	if menu_open:
		return false
	if not freelook_enabled:
		return false
	
	
	var root := get_tree().current_scene
	if root != null and ("current_state" in root) and root.current_state == "battle":
		return false
	return true

func _update_mouse_mode() -> void:
	var want := Input.MOUSE_MODE_CAPTURED if _can_look() else Input.MOUSE_MODE_VISIBLE
	if Input.mouse_mode != want:
		Input.set_mouse_mode(want)

func _on_dialogue_started() -> void:
	freelook_enabled = false

func _on_dialogue_ended() -> void:
	freelook_enabled = true

func _process(_delta: float) -> void:
	# Keeps it correct in steady state and re-captures when control returns
	# (e.g. coming back from a battle, where this node was process-disabled).
	_update_mouse_mode()

func _unhandled_input(event: InputEvent) -> void:
	if not _can_look():
		return
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * mouse_sensibility
		rotation.y = wrapf(rotation.y, 0.0, TAU)
		rotation.x -= event.relative.y * mouse_sensibility
		rotation.x = clampf(rotation.x, -PI/2, PI/4)

func _physics_process(delta: float) -> void:
	var space_state = get_world_3d().direct_space_state
	var origin = global_position
	var target = spring_position.global_position

	var query = PhysicsRayQueryParameters3D.create(origin, target)
	query.exclude = [get_parent()]
	query.collision_mask = 1

	var result = space_state.intersect_ray(query)

	if result:
		var hit_dist = global_position.distance_to(result.position)
		spring_arm.spring_length = max(min_length, hit_dist - 0.3)
	else:
		spring_arm.spring_length = lerp(spring_arm.spring_length, default_length, delta * 5.0)
