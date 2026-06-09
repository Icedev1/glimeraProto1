extends Node

signal objectives_updated
signal layer_advanced(new_layer: int)
signal main_quest_updated(new_quest: String)
signal OpenGate

var current_layer: int = 0

var main_quest: String = "Find out who's knocking"

# Each layer has a pool of objectives that get revealed progressively.
# "visible" controls whether the objective shows on screen yet.
var layers: Array = []

func _ready() -> void:
	if layers.size() > 0:
		return
	layers = [
		[
			{ "id": "pickup_violin", "text": "Pick up your violin", "done": false, "visible": true },
			{ "id": "pickup_sledgehammer", "text": "Grab something from the trash pile", "done": false, "visible": false },
			#{ "id": "interact_door", "text": "Find out who's knocking", "done": false, "visible": false },
			{ "id": "see_figure", "text": "See what the figure is up to", "done": false, "visible": false },
			{ "id": "find_noise", "text": "Find out where the noise came from", "done": false, "visible": false },
			{ "id": "inspect_stairs", "text": "Inspect the stairs", "done": false, "visible": false },
			{ "id": "find_climb", "text": "Find something to climb the stairs", "done": false, "visible": false },
			{ "id": "help_figure", "text": "Help the Figure find her friend", "done": false, "visible": false },
			{ "id": "climb_stairs", "text": "Climb the stairs", "done": false, "visible": false },
		],
		[
			{ "id": "explore_area", "text": "Explore the area", "done": false, "visible": true },
			{ "id": "talk_npc5", "text": "Talk to the guard on the stairs", "done": false, "visible": true },
			{ "id": "talk_npc3", "text": "Look for information", "done": false, "visible": false },
			{ "id": "talk_churchbro", "text": "Ask about the church", "done": false, "visible": false },
			{ "id": "enter_church", "text": "Enter the church", "done": false, "visible": false },
			{ "id": "solve_puzzle", "text": "Solve the library puzzle", "done": false, "visible": false },
			{ "id": "fight_churchman", "text": "Defeat the Priest", "done": false, "visible": false },
			{ "id": "return_to_stairs", "text": "Climb the stairs", "done": false, "visible": false },
		],
	]

func reveal_objective(id: String) -> void:
	for obj in layers[current_layer]:
		if obj["id"] == id and not obj["visible"]:
			obj["visible"] = true
			objectives_updated.emit()
			return

func complete_objective(id: String) -> void:
	print("trying to complete: ", id)
	for obj in layers[current_layer]:
		print("checking: ", obj["id"], " done: ", obj["done"])
	for obj in layers[current_layer]:
		if obj["id"] == id and not obj["done"]:
			obj["done"] = true
			objectives_updated.emit()
			return

func advance_layer() -> void:
	if current_layer < layers.size() - 1:
		current_layer += 1
		layer_advanced.emit(current_layer)
		objectives_updated.emit()

func get_current_objectives() -> Array:
	var visible_objectives = []
	for obj in layers[current_layer]:
		if obj["visible"]:
			visible_objectives.append(obj)
	return visible_objectives
	
func set_main_quest(text: String) -> void:
	# hide all completed objectives when main quest changes
	for obj in layers[current_layer]:
		if obj["done"]:
			obj["visible"] = false
	main_quest = text
	main_quest_updated.emit(text)
	objectives_updated.emit()
