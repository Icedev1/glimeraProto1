extends CharacterBody3D

const SPEED = 1
const JUMP_VELOCITY = 2.5

@onready var edge_ray: RayCast3D = $EdgeRay
@export var camera : Camera3D


#grafting system
enum ArmItem {
	VIOLIN,
	WOODSTOMP
}

var current_item = ArmItem.VIOLIN

@onready var violin = $ArmSlot/Violin
@onready var woodstomp = $ArmSlot/WoodStomp

func _ready() -> void:
	update_visual()


func _rotate_toward_movement(delta, direction):
	const TURN_SPEED = 9.0
	var move_dir := Vector3(velocity.x, 0, velocity.z)

	if move_dir.length() < 0.05:
		return

	rotation.y = lerp_angle(rotation.y, (atan2(direction.x, direction.z) - PI / 2), delta * TURN_SPEED)


func _physics_process(delta: float) -> void:
	if not is_on_floor():
		velocity += get_gravity() * delta
	
	if Dialogic.current_timeline != null:
		return


	#input for the grafting
	if Input.is_action_just_pressed("switch_item"):
		if current_item == ArmItem.VIOLIN:
			switch_item(ArmItem.WOODSTOMP)
		else:
			switch_item(ArmItem.VIOLIN)

	if Input.is_action_just_pressed("use_item"):
		use_item()
	# =========================


func get_input() -> Vector2:
	return Vector2(
		Input.get_action_strength("ui_right") - Input.get_action_strength("ui_left"),
		Input.get_action_strength("ui_down") - Input.get_action_strength("ui_up")
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



# grafting system

func switch_item(new_item: ArmItem):
	current_item = new_item
	update_visual()


func update_visual():
	violin.visible = current_item == ArmItem.VIOLIN
	woodstomp.visible = current_item == ArmItem.WOODSTOMP


func use_item():
	match current_item:
		ArmItem.VIOLIN:
			play_violin()
		ArmItem.WOODSTOMP:
			do_woodstomp()


func play_violin():
	print("violin used")


func do_woodstomp():
	print("woodstomp used")
