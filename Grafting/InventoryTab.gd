extends Control

const ITEMS = [
	{
		"name": "『 Violin 』",
		"category": "Instrument",
		"description": "Its melodies carry an unsettling weight.",
		"icon": "res://Grafting/violin icon.png",
		"owned_check": "always"
	},
	{
		"name": "『 Saw 』",
		"category": "Graftable",
		"description": "An industrial bone saw grafted where the forearm once was.",
		"icon": "res://Grafting/saw icon.png",
		"owned_check": "sawObtained"
	},
	{
		"name": "『 Sledgehammer 』",
		"category": "Graftable",
		"description": "A sledgehammer welded to the leg socket.",
		"icon": "res://Grafting/sledgehammer icon.png",
		"owned_check": "sledgehammerObtained"
	},
	{
		"name": "『 Hose 』",
		"category": "Graftable",
		"description": "A thick rubber hose attached at to left arm.",
		"icon": "res://Grafting/Hose Icon.png",
		"owned_check": "hoseObtained"
	},
	{
		"name": "『 Potion 』",
		"category": "Consumable",
		"description": "A murky liquid in a cracked vial. Drinking it feels like a bad idea. It works anyway.",
		"icon": "res://images/potion.png",
		"owned_check": "always"
	},
	{
		"name": "『 Bandage 』",
		"category": "Consumable",
		"description": "Strips of cloth that have seen better days.",
		"icon": "res://images/bandage.png",
		"owned_check": "always"
	},
	{
		"name": "Broom",
		"category": "Graftable",
		"description": "A weathered broomstick. Sweeps the floor. Sweeps the enemy. No distinction is made.",
		"icon": "res://path/to/broom_icon.png",
		"owned_check": "broomObtained"
	},
	{
		"name": "Unicycle",
		"category": "Graftable",
		"description": "Looks absurd but is handy when slowed.",
		"icon": "res://path/to/unicycle_icon.png",
		"owned_check": "unicycleObtained"
	},
]

@onready var item_grid: GridContainer = $PopupBox/HBoxContainer/ScrollContainer/ItemGrid
@onready var detail_icon: TextureRect = $PopupBox/HBoxContainer/DetailPanel/MarginContainer/DetailContent/DetailIcon
@onready var detail_name: Label = $PopupBox/HBoxContainer/DetailPanel/MarginContainer/DetailContent/DetailName
@onready var detail_category: Label = $PopupBox/HBoxContainer/DetailPanel/MarginContainer/DetailContent/DetailCategory
@onready var detail_owned: Label = $PopupBox/HBoxContainer/DetailPanel/MarginContainer/DetailContent/DetailOwned
@onready var detail_description: Label = $PopupBox/HBoxContainer/DetailPanel/MarginContainer/DetailContent/DetailDescription
var selected_index: int = 0

func _ready() -> void:
	_populate_grid()
	_show_detail(0)
	_apply_styles()

func _populate_grid() -> void:
	if item_grid.get_child_count() > 0:
		return
	for i in ITEMS.size():
		var item = ITEMS[i]
		var owned = _is_owned(item["owned_check"])

		var btn = Button.new()
		btn.custom_minimum_size = Vector2(180, 180)
		btn.clip_contents = true

		# Card style
		var card_style = StyleBoxFlat.new()
		card_style.bg_color = Color(0.15, 0.15, 0.15, 1.0)
		card_style.corner_radius_top_left = 16
		card_style.corner_radius_top_right = 16
		card_style.corner_radius_bottom_left = 16
		card_style.corner_radius_bottom_right = 16
		btn.add_theme_stylebox_override("normal", card_style)
		var hover_style = card_style.duplicate()
		hover_style.bg_color = Color(0.22, 0.22, 0.22, 1.0)
		btn.add_theme_stylebox_override("hover", hover_style)

		# Icon
		var tex = TextureRect.new()
		tex.texture = load(item["icon"])
		tex.expand_mode = TextureRect.EXPAND_FIT_WIDTH_PROPORTIONAL
		tex.stretch_mode = TextureRect.STRETCH_KEEP_ASPECT_CENTERED
		tex.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
		tex.mouse_filter = Control.MOUSE_FILTER_IGNORE
		btn.add_child(tex)

		# Lock overlay for unowned
		if not owned:
			var overlay = ColorRect.new()
			overlay.color = Color(0, 0, 0, 0.6)
			overlay.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			overlay.mouse_filter = Control.MOUSE_FILTER_IGNORE
			btn.add_child(overlay)

			var lock = Label.new()
			lock.text = "🔒"
			lock.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
			lock.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
			lock.set_anchors_and_offsets_preset(Control.PRESET_FULL_RECT)
			lock.mouse_filter = Control.MOUSE_FILTER_IGNORE
			btn.add_child(lock)

		var idx = i
		btn.pressed.connect(func(): _on_item_pressed(idx))
		item_grid.add_child(btn)

func _on_item_pressed(idx: int) -> void:
	selected_index = idx
	_show_detail(idx)

func _show_detail(idx: int) -> void:
	var item = ITEMS[idx]
	var owned = _is_owned(item["owned_check"])

	detail_icon.texture = load(item["icon"])
	detail_name.text = item["name"]
	detail_category.text = item["category"].to_upper()
	detail_owned.text = "OWNED" if owned else "NOT OBTAINED"
	detail_owned.add_theme_color_override("font_color", 
		Color(0.3, 0.85, 0.3, 1.0) if owned else Color(0.5, 0.5, 0.5, 1.0))
	detail_description.text = item["description"]
	detail_icon.modulate = Color(1, 1, 1, 1) if owned else Color(0.4, 0.4, 0.4, 1)

func _is_owned(check: String) -> bool:
	if check == "always":
		return true
	return GraftGlobals.get(check)

func _apply_styles() -> void:
	# Text colors and sizes
	detail_name.add_theme_color_override("font_color", Color.WHITE)
	detail_name.add_theme_font_size_override("font_size", 38)

	detail_category.add_theme_color_override("font_color", Color(0.767, 0.995, 0.752, 0.996))
	detail_category.add_theme_font_size_override("font_size", 14)

	detail_description.add_theme_color_override("font_color", Color(0.8, 0.8, 0.8, 1.0))
	detail_description.add_theme_font_size_override("font_size", 18)
	
	detail_name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_category.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_owned.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	detail_description.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
