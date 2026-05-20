extends Node3D

@export var mouse_sensibility: float = 0.01
@export var default_length: float = 6.0
@export var min_length: float = 0.5
@onready var spring_arm := $SpringArm3D
@onready var spring_position := $"SpringArm3D/SpringPosition"
var menu_open := false


func _ready() -> void:
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)

func _unhandled_input(event: InputEvent) -> void:
	if menu_open:
		return
	if event is InputEventMouseMotion:
		rotation.y -= event.relative.x * mouse_sensibility
	if event is InputEventMouseMotion: #&& Input.is_action_pressed("mouse_right") add this to get control over camera
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
