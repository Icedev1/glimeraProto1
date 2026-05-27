extends Area3D
@export var target_street : String
@export var spawn_name : String

func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		match target_street:
			"res://Streets/Street1-2.tscn": # entering street 2
				ObjectiveManager.reveal_objective("see_figure")
			"res://Streets/Market1.tscn": # entering market pt.1
				ObjectiveManager.complete_objective("find_noise")
				ObjectiveManager.reveal_objective("find_climb")
		
		var game = get_tree().current_scene
		game.transition_to_street(target_street, spawn_name)
