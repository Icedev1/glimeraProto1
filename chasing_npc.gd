extends Node3D

@export var speed: float = 2.5

var player: Node3D = null
var chasing: bool = false

@onready var anim: AnimationPlayer = $NPC1/AnimationPlayer

func _process(delta):

	if chasing and player:

		var direction = player.global_position - global_position
		direction.y = 0
		direction = direction.normalized()

		# Move toward player
		global_position += direction * speed * delta

		# Face player
		look_at(player.global_position)

		# Play walk animation
		if anim.current_animation != "Walk2":
			anim.play("Walk2")

	else:
		# Idle animation
		if anim.current_animation != "Idle":
			anim.play("Idle")
