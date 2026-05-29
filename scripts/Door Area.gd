extends Area3D

var inRange : bool = false
@onready var node: Node3D = $".."
@onready var canvasprompt: Control = null
@export var streetPath: String
@export var spawnName: String

@onready var particle_scene = preload("res://Particles/GlowingRingParticle.tscn")

var active_particles = null


# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	pass



# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	# Keep prompt positioned correctly
	#if inRange:
		#var prompt = get_prompt()
#
		#if prompt:
			#var world_pos = global_transform.origin + Vector3(0, 0.5, 0)
			#var screen_pos = get_viewport().get_camera_3d().unproject_position(world_pos)
			#prompt.position = screen_pos



	
	if Input.is_action_just_pressed("ui_interact") and inRange:
		var game = get_tree().current_scene
		game.transition_to_street(streetPath, spawnName)
	


func _on_body_entered(body: Node3D) -> void:
	inRange = true
	
	var prompt = get_prompt()


	if prompt:
		prompt.visible = true
	
	if active_particles == null:

		active_particles = particle_scene.instantiate()
		active_particles.global_transform = $CollisionShape3D.global_transform
		
		active_particles.set_as_top_level(true)
		active_particles.scale = Vector3(0.2,0.2,0.2)

		get_tree().current_scene.add_child(active_particles)
		
		
		
	
	

func _on_body_exited(body: Node3D) -> void:
	inRange = false
	
	var prompt = get_prompt()

	if prompt:
		prompt.visible = false
		
	if active_particles:
		active_particles.queue_free()
		active_particles = null


func get_prompt():
	if canvasprompt == null or not is_instance_valid(canvasprompt):
		var prompts = get_tree().get_nodes_in_group("prompt")
		if prompts.size() > 0:
			canvasprompt = prompts[0]

	return canvasprompt
