extends StaticBody3D

@export var item_name: String = "Sword"
@onready var light = $OmniLight3D
@onready var particles = $GPUParticles3D

func _ready() -> void:
	$Area3D.body_entered.connect(_on_area_3d_body_entered)
	$Area3D.body_exited.connect(_on_area_3d_body_exited)

func interact() -> void:
	print("Picked up: ", item_name)
	queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	#print("area entered by: ", body.name, " is CharacterBody3D: ", body is CharacterBody3D)
	if not body is CharacterBody3D:
		return
	light.visible = true
	particles.emitting = true
	Dialogue.objectRange.emit(self, true)

func _on_area_3d_body_exited(body: Node3D) -> void:
	if not body is CharacterBody3D:
		return
	light.visible = false
	particles.emitting = false
	Dialogue.objectRange.emit(self, false)
