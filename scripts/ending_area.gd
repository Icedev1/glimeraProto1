extends Area3D
@onready var mesh_instance_3d: MeshInstance3D = $"../Camera3D/MeshInstance3D"


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	mesh_instance_3d.visible = false


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
	


func _on_body_entered(body: Node3D) -> void:
	var player = get_parent() as AnimationPlayer
	MusicPlayer.stop_music()
	ObjectiveManager.cutsceneStart.emit()
	player.play("Final Scene", 0,5)
	
