extends PanelContainer

@onready var vbox := $VBoxContainer

var label_pool: Array = []

func _ready() -> void:
	position = Vector2(50, 500)
	ObjectiveManager.objectives_updated.connect(_refresh)
	ObjectiveManager.layer_advanced.connect(_on_layer_advanced)
	_refresh()

func _refresh() -> void:
	for child in vbox.get_children():
		if child.name != "Header":
			child.free()
	label_pool.clear()

	var objectives = ObjectiveManager.get_current_objectives()
	for obj in objectives:
		var label = Label.new()
		label.autowrap_mode = TextServer.AUTOWRAP_WORD
		label.custom_minimum_size.x = 260
		if obj["done"]:
			label.text = "✓ " + obj["text"]
			label.add_theme_color_override("font_color", Color(0.78, 0.74, 0.66, 0.4))
			label.add_theme_font_size_override("font_size", 16)
		else:
			label.text = "○ " + obj["text"]
			label.add_theme_color_override("font_color", Color.from_string("#C7BDA8", Color.WHITE))
			label.add_theme_font_size_override("font_size", 24)
		label.modulate.a = 0.0
		vbox.add_child(label)
		label_pool.append(label)

	# Fade each label in with a small stagger
	for i in range(label_pool.size()):
		var tween = create_tween()
		tween.tween_interval(i * 0.1)
		tween.tween_property(label_pool[i], "modulate:a", 1.0, 1.0)

func _on_layer_advanced(_layer: int) -> void:
	var tween = create_tween()
	tween.tween_property(self, "modulate:a", 0.0, 0.4)
	tween.tween_callback(_refresh)
	tween.tween_property(self, "modulate:a", 1.0, 0.4)
