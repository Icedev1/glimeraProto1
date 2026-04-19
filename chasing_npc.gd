extends Node3D

@export var speed: float = 2.5

var player: Node3D = null
var chasing: bool = false
var active = true

@onready var anim: AnimationPlayer = $NPC1/AnimationPlayer
func _ready() -> void:
	BattleManager.connect("battle_ended", die)
	
	
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

func die():
	var statue = preload("res://statue.tscn").instantiate()
	statue.global_position = global_position
	get_parent().add_child(statue)
	queue_free()
func _on_area_3d_body_entered(body: Node3D) -> void:
	if active:
		var game = get_tree().current_scene
		game.from_overworld_to_battle()
		chasing = false
		active = false
