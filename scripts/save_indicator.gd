extends CanvasLayer

@onready var panel = $PanelContainer
@onready var label = $PanelContainer/HBoxContainer/Label

func _ready():
	panel.visible = false
	await get_tree().process_frame
	SaveManager.save_started.connect(_on_save_started)
	SaveManager.save_completed.connect(_on_save_completed)

func _on_save_started():
	panel.visible = true
	panel.modulate.a = 1.0
	label.text = "✦ Saving..."

func _on_save_completed():
	await get_tree().create_timer(1.5).timeout
	var tween = create_tween()
	tween.tween_property(panel, "modulate:a", 0.0, 0.5)
	await tween.finished
	panel.visible = false
