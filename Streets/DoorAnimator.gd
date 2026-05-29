extends AnimationPlayer

@export var currentScene: String

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	ObjectiveManager.OpenGate.connect(gateOpen)
	if StoryFlags.Layer1GateUnlock and currentScene == "1-2":
		gateOpen()
	elif StoryFlags.Layer2GateUnlock and currentScene == "2-1":
		gateOpen()

func gateOpen():
	play("gate_opening")
# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
