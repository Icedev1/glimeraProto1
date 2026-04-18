extends Node

signal right_arm_graft_changed(new_index : int)
signal left_leg_graft_changed(new_index : int)
signal menu_opened()

var right_arm_graft_index : int = 0
var left_leg_graft_index : int = 0
var sawObtained : bool = false
var violinObtained : bool = false
var hoseObtained : bool = false
var graftSFX : AudioStream = preload("res://Sounds/SFX/1101.wav")
