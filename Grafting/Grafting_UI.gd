extends Control

@export var graftIcons : Array[Texture2D]
@export var leftLegButton : TextureButton
@export var rightArmButton : TextureButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	match $SubViewportContainer/SubViewport/Node3D/CharacterBody3D/GraftingSystem.right_arm_graft_index:
		0:
			rightArmButton.texture_normal = graftIcons[0]
		1:
			rightArmButton.texture_normal = graftIcons[1]
	
	match $SubViewportContainer/SubViewport/Node3D/CharacterBody3D/GraftingSystem.left_leg_graft_index:
		0:
			leftLegButton.texture_normal = graftIcons[0]
		1:
			leftLegButton.texture_normal = graftIcons[2]


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass
