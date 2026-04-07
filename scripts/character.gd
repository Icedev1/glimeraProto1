extends CharacterBody3D

const SPEED = 1
const JUMP_VELOCITY = 2.5

@export var camera : Camera3D

var equipped_item

func _ready() -> void:
	add_to_group("player")

func _physics_process(delta: float) -> void:
	if get_tree().paused:
		return

	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Dialogic.current_timeline != null:
		return

	if Input.is_action_just_pressed("use_item"):
		use_item()

	move_and_slide()

func get_input() -> Vector2:
	return Vector2(
		Input.get_action_strength("move_right") - Input.get_action_strength("move_left"),
		Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
	)

func _get_camera_direction(input_dir: Vector2) -> Vector3:
	if input_dir == Vector2.ZERO:
		camera = CamMan.instance.getPlayerCam()

	var cam_basis = camera.global_transform.basis
	var cam_forward = cam_basis.z
	var cam_right = cam_basis.x

	cam_forward.y = 0
	cam_right.y = 0

	return (cam_right * input_dir.x + cam_forward * input_dir.y).normalized()

func rotate_toward(direction: Vector3, delta: float):
	const TURN_SPEED = 9.0
	var move_dir = Vector3(velocity.x, 0, velocity.z)
	if move_dir.length() < 0.05:
		return
	rotation.y = lerp_angle(rotation.y, atan2(direction.x, direction.z) - PI / 2, delta * TURN_SPEED)

func set_item(item):
	equipped_item = item
	print("Equipped:", item.name)

func use_item():
	if equipped_item == null:
		return

	if equipped_item.name == "Violin":
		play_violin()
	elif equipped_item.name == "Woodstomp":
		do_woodstomp()

func play_violin():
	print("violin used")

func do_woodstomp():
	velocity.y = 6


func _on_inventory_ui_item_selected(item: Variant) -> void:
	pass # Replace with function body.
