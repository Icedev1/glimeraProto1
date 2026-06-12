class_name NPC extends Node3D

var is_player_in_range: bool = false
@export var enemy_data: EnemyData
@export var timeline_name: String = "timeline"
@export var battle_scene: String = "res://Combat/scenes/battle.tscn"

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.signal_event.connect(DialogicSignal)
	BattleManager.battle_ended.connect(_on_battle_ended)
	if name == "Intimidating Figure" and not GraftGlobals.hoseObtained:
		hide()
		$Area3D.monitoring = false
		$Area3D.monitorable = false


func _process(_delta: float) -> void:
	if name == "Intimidating Figure" and GraftGlobals.hoseObtained and not visible:
		print("showing Intimidating Figure")
		show()
		$Area3D.monitoring = true
		$Area3D.monitorable = true

func DialogicSignal(arg:String):
	#Prevents other npcs of the same type from listening to signal
	if not is_player_in_range:
		return
	#starts battle(WIP)
	if arg == "battle_start": 
		print("battle_scene: ", battle_scene)
		get_tree().root.get_node("Root").from_overworld_to_battle(enemy_data, battle_scene)
		
		
func _on_area_3d_body_entered(body: Node3D) -> void:
	is_player_in_range = true
	Dialogue.interactRange.emit(self, true)


func _on_area_3d_body_exited(body: Node3D) -> void:
	is_player_in_range = false
	Dialogue.interactRange.emit(self, false)

func _on_battle_ended(_won: bool, _weapons: Array, _consumables: Array):
	if enemy_data != null and enemy_data.unit_name == "Porcelain Figure":
		is_player_in_range = false
		Dialogue.interactRange.emit(self, false)
		$Area3D.monitoring = false
		$Area3D.monitorable = false
		GraftGlobals.porcelainDefeated = true
