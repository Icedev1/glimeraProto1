class_name CooldownTracker
extends RefCounted

signal became_ready

var duration: float
var remaining: float = 0.0

func _init(p_duration: float) -> void:
	duration = p_duration

func start() -> void:
	remaining = duration

func tick(delta: float) -> void:
	if remaining <= 0.0:
		return
	remaining = max(0.0, remaining - delta)
	if remaining == 0.0:
		became_ready.emit()

func is_ready() -> bool:
	return remaining <= 0.0
