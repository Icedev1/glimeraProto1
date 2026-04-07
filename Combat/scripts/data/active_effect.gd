class_name ActiveEffect
extends RefCounted

var effect: StatusEffect
var remaining: float

func _init(p_effect: StatusEffect) -> void:
	effect = p_effect
	remaining = p_effect.duration

func is_expired() -> bool:
	return remaining <= 0.0
