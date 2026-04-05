class_name PlayerData
extends UnitData

@export var equipped: Array[Weapon] = [null, null, null, null]
@export var inventory: Array[Weapon] = []

func _init() -> void:
	unit_name = "Gli"

# ── Save / Load ───────────────────────────────────────────────────────────────
func save(path: String = PlayerManager.SAVE_PATH) -> void:
	ResourceSaver.save(self, path)

static func load(path: String = PlayerManager.SAVE_PATH) -> PlayerData:
	if ResourceLoader.exists(path):
		return ResourceLoader.load(path) as PlayerData
	return null
