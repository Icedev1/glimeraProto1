extends Area3D

@export var target_street : String
@export var spawn_name : String

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:

		var game = get_tree().current_scene

		game.transition_to_street(target_street, spawn_name)
