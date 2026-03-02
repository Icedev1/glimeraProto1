class_name CameraSwitch
extends Area3D

@export var cam1 : Camera3D
@export var cam2 : Camera3D
signal switch(area : CameraSwitch)

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	add_to_group("camera_switches")
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass



func _on_body_exited(body: Node3D) -> void:
	switch.emit(self)
