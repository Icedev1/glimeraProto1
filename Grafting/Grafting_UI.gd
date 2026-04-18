extends Control

@export var armIcons : Array[Texture2D]
@export var legIcons : Array[Texture2D]
@export var leftLegButton : TextureButton
@export var rightArmButton : TextureButton

# Called when the node enters the scene tree for the first time.
func _ready() -> void:
	rightArmButton.texture_normal = armIcons[GraftGlobals.right_arm_graft_index]
	leftLegButton.texture_normal = legIcons[GraftGlobals.left_leg_graft_index]
	


# Called every frame. 'delta' is the elapsed time since the previous frame.
func _process(delta: float) -> void:
	pass


func _on_texture_button_pressed() -> void:
	$ArmList.visible = true


func _on_leg_button_pressed() -> void:
	$LegList.visible = true


func _on_arm_list_item_selected(index: int) -> void:
	print("Selected arm graft index: ", index)
	GraftGlobals.right_arm_graft_changed.emit(index)
	GraftGlobals.right_arm_graft_index = index
	rightArmButton.texture_normal = armIcons[index]
	$ArmList.visible = false


func _on_leg_list_item_selected(index: int) -> void:
	print("Selected leg graft index: ", index)
	GraftGlobals.left_leg_graft_changed.emit(index)
	GraftGlobals.left_leg_graft_index = index
	leftLegButton.texture_normal = legIcons[index]
	$LegList.visible = false
