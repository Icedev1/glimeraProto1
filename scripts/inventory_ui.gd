extends Control

signal item_selected(item)

var player
var items = []
var selected_item = null

@onready var violin_button = $Panel/VBoxContainer/Violin
@onready var woodstomp_button = $Panel/VBoxContainer/Woodstomp

func _ready():
	await get_tree().process_frame
	player = get_tree().get_first_node_in_group("player")

	items = [
		preload("res://resources/violin.tres"),
		preload("res://resources/woodstomp.tres")
	]

	visible = false

func _process(delta):
	update_ui()

func _input(event):
	if event.is_action_pressed("open_inventory"):
		visible = !visible
		get_tree().paused = visible

func update_ui():
	if selected_item == null:
		return

	if selected_item.name == "Violin":
		violin_button.disabled = true
		woodstomp_button.disabled = false
	else:
		violin_button.disabled = false
		woodstomp_button.disabled = true

func _on_violin_pressed():
	selected_item = items[0]
	emit_signal("item_selected", selected_item)
	close_inventory()

func _on_woodstomp_pressed():
	selected_item = items[1]
	emit_signal("item_selected", selected_item)
	close_inventory()

func close_inventory():
	visible = false
	get_tree().paused = false
