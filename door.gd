extends Area3D

var inRange : bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	if Input.is_action_just_pressed("ui_interact") and inRange:
		var game = get_tree().current_scene
		game.transition_to_street("res://Street1.tscn", "Spawn_FromHouse")


func _on_body_entered(body: Node3D) -> void:
	inRange = true
	


func _on_body_exited(body: Node3D) -> void:
	inRange = false
