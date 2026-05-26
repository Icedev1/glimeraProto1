extends Area3D
@export var target_street : String
@export var spawn_name : String
func _on_body_entered(body: Node3D) -> void:
	if body is CharacterBody3D:
		StoryFlags.current_scene = target_street
		StoryFlags.checkpoint_position = body.global_position
		SaveManager.save(0)
		print("Saved! Scene: ", StoryFlags.current_scene, " Pos: ", StoryFlags.checkpoint_position)
		var game = get_tree().current_scene
		game.transition_to_street(target_street, spawn_name)
