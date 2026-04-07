extends Node

var current_object
var in_range: bool = false

func _ready() -> void:
	Dialogue.objectRange.connect(_on_object_range)

func _on_object_range(obj, is_in_range: bool) -> void:
	print("objectRange received! in_range: ", is_in_range)
	current_object = obj
	in_range = is_in_range
	Dialogue.near_object = is_in_range

func _process(_delta: float) -> void:
	if in_range and current_object != null and Input.is_action_just_pressed("ui_interact"):
		current_object.interact()
		get_viewport().set_input_as_handled()
