extends Node

signal save_started
signal save_completed

const SLOT_COUNT = 3
const SAVE_DIR = "user://saves/"

var loading_from_save: bool = false

func _ready():
	DirAccess.make_dir_absolute(SAVE_DIR)

func _get_path(slot: int) -> String:
	return SAVE_DIR + "slot_%d.save" % slot

func save(slot: int):
	save_started.emit()
	var data = {
		"timestamp": Time.get_datetime_string_from_system(),
		"checkpoint_scene": StoryFlags.current_scene,
		"checkpoint_position": {
			"x": StoryFlags.checkpoint_position.x,
			"y": StoryFlags.checkpoint_position.y,
			"z": StoryFlags.checkpoint_position.z,
		},
		"Enemy1_2Defeat": StoryFlags.Enemy1_2Defeat,
		"EnemyM_2Defeat": StoryFlags.EnemyM_2Defeat,
		"statueQuestComplete": StoryFlags.statueQuestComplete,
		"Layer1GateUnlock": StoryFlags.Layer1GateUnlock,
		"Layer2GateUnlock": StoryFlags.Layer2GateUnlock,
		"right_arm_graft_index": GraftGlobals.right_arm_graft_index,
		"left_leg_graft_index": GraftGlobals.left_leg_graft_index,
		"sawObtained": GraftGlobals.sawObtained,
		"sledgehammerObtained": GraftGlobals.sledgehammerObtained,
		"hoseObtained": GraftGlobals.hoseObtained,
		"violinObtained": GraftGlobals.violinObtained,
		"porcelainDefeated": GraftGlobals.porcelainDefeated,
		"angrySteveDead": GraftGlobals.angrySteveDead,
		"intimidatingDefeated": GraftGlobals.intimidatingDefeated,
		"churchbroDefeated": GraftGlobals.churchbroDefeated,
		"npc5Talked": GraftGlobals.npc5Talked,
		"churchman1Talked": GraftGlobals.churchman1Talked,
		"libraryDone": GraftGlobals.libraryDone,
		"churchmanDefeated": GraftGlobals.churchmanDefeated,
		"churchmanPostLibraryTalked": GraftGlobals.churchmanPostLibraryTalked,
		"objective_layer": ObjectiveManager.current_layer,
		"objective_layers": ObjectiveManager.layers.duplicate(true),
		"defeated_enemies": BattleManager.get_defeated_enemies(),
		"consumables": _save_consumables(),
	}
	var file = FileAccess.open(_get_path(slot), FileAccess.WRITE)
	file.store_string(JSON.stringify(data))
	file.close()
	save_completed.emit()

func load_slot(slot: int) -> bool:
	var path = _get_path(slot)
	if not FileAccess.file_exists(path):
		return false
	var file = FileAccess.open(path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data:
		return false

	StoryFlags.current_scene = data["checkpoint_scene"]
	StoryFlags.checkpoint_position = Vector3(
		data["checkpoint_position"]["x"],
		data["checkpoint_position"]["y"],
		data["checkpoint_position"]["z"]
	)
	StoryFlags.Enemy1_2Defeat = data["Enemy1_2Defeat"]
	StoryFlags.EnemyM_2Defeat = data["EnemyM_2Defeat"]
	StoryFlags.statueQuestComplete = data["statueQuestComplete"]
	StoryFlags.Layer1GateUnlock = data.get("Layer1GateUnlock", false)
	StoryFlags.Layer2GateUnlock = data.get("Layer2GateUnlock", false)

	GraftGlobals.right_arm_graft_index = data["right_arm_graft_index"]
	GraftGlobals.left_leg_graft_index = data["left_leg_graft_index"]
	GraftGlobals.sawObtained = data["sawObtained"]
	GraftGlobals.sledgehammerObtained = data["sledgehammerObtained"]
	GraftGlobals.hoseObtained = data["hoseObtained"]
	GraftGlobals.violinObtained = data["violinObtained"]
	GraftGlobals.porcelainDefeated = data.get("porcelainDefeated", false)
	GraftGlobals.angrySteveDead = data.get("angrySteveDead", false)
	GraftGlobals.intimidatingDefeated = data.get("intimidatingDefeated", false)
	GraftGlobals.churchbroDefeated = data.get("churchbroDefeated", false)
	GraftGlobals.npc5Talked = data.get("npc5Talked", false)
	GraftGlobals.churchman1Talked = data.get("churchman1Talked", false)
	GraftGlobals.libraryDone = data.get("libraryDone", false)
	GraftGlobals.churchmanDefeated = data.get("churchmanDefeated", false)
	GraftGlobals.churchmanPostLibraryTalked = data.get("churchmanPostLibraryTalked", false)

	ObjectiveManager.current_layer = data["objective_layer"]
	ObjectiveManager.layers = data["objective_layers"]
	BattleManager.load_defeated_enemies(data["defeated_enemies"])
	_load_consumables(data["consumables"])
	PlayerManager.sync_from_grafts()

	loading_from_save = true
	return true

func get_slot_info(slot: int) -> Dictionary:
	var path = _get_path(slot)
	if not FileAccess.file_exists(path):
		return {"empty": true}
	var file = FileAccess.open(path, FileAccess.READ)
	var data = JSON.parse_string(file.get_as_text())
	file.close()
	if not data:
		return {"empty": true}
	return {
		"empty": false,
		"timestamp": data.get("timestamp", ""),
		"scene": data.get("checkpoint_scene", ""),
	}

func delete_slot(slot: int):
	var path = _get_path(slot)
	if FileAccess.file_exists(path):
		DirAccess.remove_absolute(path)

func _save_consumables() -> Array:
	var result = []
	if PlayerManager.data == null:
		return result
	for c in PlayerManager.data.consumables:
		result.append({
			"name": c.consumable_name,
			"quantity": c.quantity
		})
	return result

func _load_consumables(data: Array):
	if PlayerManager.data == null:
		PlayerManager.init_player()
	for saved in data:
		for c in PlayerManager.data.consumables:
			if c.consumable_name == saved["name"]:
				c.quantity = saved["quantity"]
				break
