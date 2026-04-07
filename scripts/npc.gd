class_name NPC extends Node3D

var is_player_in_range: bool = false

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	Dialogic.signal_event.connect(DialogicSignal)

# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(_delta: float) -> void:
	pass

func DialogicSignal(arg:String):
	#Prevents other npcs of the same type from listening to signal
	if not is_player_in_range:
		return
	#starts battle(WIP)
	if arg == "battle_start": 
		print("battle started") 
		
func _on_area_3d_body_entered(_body: Node3D) -> void:
	is_player_in_range = true
	Dialogue.interactRange.emit(self, true)


func _on_area_3d_body_exited(_body: Node3D) -> void:
	is_player_in_range = false
	Dialogue.interactRange.emit(self, false)
