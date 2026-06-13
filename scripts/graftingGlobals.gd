extends Node

signal right_arm_graft_changed(new_index : int)
signal left_leg_graft_changed(new_index : int)
signal menu_opened()

var right_arm_graft_index : int = 0
var left_leg_graft_index : int = 0
var sawObtained : bool = false
var sledgehammerObtained : bool  = false
var hoseObtained : bool = false
var graftSFX : AudioStream = preload("res://Sounds/SFX/1101.wav")
var porcelainDefeated: bool = false
var angrySteveDead: bool = false
var violinObtained: bool = false
var intimidatingDefeated: bool = false

#layer2
var churchbroDefeated: bool = false
#guy on the stairs
var npc5Talked: bool = false
var churchman1Talked: bool = false
var libraryDone: bool = false
var churchmanDefeated : bool = false
var churchmanPostLibraryTalked : bool = false
#newgrafts
var broomObtained: bool = false
var unicycleObtained: bool = false
