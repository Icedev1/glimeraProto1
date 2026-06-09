extends Node3D
@export var speed: float = 4
@export var enemy_data: EnemyData 
@export var battle_scene: String = "res://Combat/scenes/battle.tscn"
@export var enemy_id: String = ""
var player: Node3D = null
var chasing: bool = false
var active = true
@onready var anim: AnimationPlayer = $NPC1/AnimationPlayer

func _ready() -> void:
	# Hide if already defeated
	if enemy_id != "" and BattleManager.is_defeated(enemy_id):
		queue_free()
		return
	BattleManager.connect("battle_ended", die)

func _process(delta):
	if chasing and player:
		var direction = player.global_position - global_position
		direction.y = 0
		direction = direction.normalized()
		global_position += direction * speed * delta
		look_at(player.global_position)
		# Play walk animation
		if anim.current_animation != "Walk2":
			anim.play("Walk2")
	else:
		if anim.current_animation != "Idle":
			anim.play("Idle")

func die(player_won: bool = true, _weapons = [], _consumables = []):
	if player_won and enemy_id != "":
		BattleManager.mark_defeated(enemy_id)
	queue_free()

func _on_area_3d_body_entered(body: Node3D) -> void:
	if GraftGlobals.angrySteveDead:
		queue_free()
		return
	if active:
		print("active")
		var game = get_tree().current_scene
		game.from_overworld_to_battle(enemy_data, battle_scene)
		chasing = false
		active = false
		die()
	else:
		print("passive")
