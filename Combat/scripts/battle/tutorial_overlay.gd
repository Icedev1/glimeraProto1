extends CanvasLayer

signal next_pressed
@onready var _title_label: Label = %Title
@onready var _body_label: Label = %Body
@onready var _next_btn: Button = %NextBtn
@onready var _spotlight: ColorRect = %Spotlight
@onready var _spotlight2: ColorRect = %Spotlight2

const SPOTLIGHT_PADDING: float = 32.0


func _ready() -> void:
	_next_btn.pressed.connect(func(): next_pressed.emit())
	_spotlight.hide()
	_spotlight2.hide()
	hide()


func _input(event: InputEvent) -> void:
	# Only advance when a popup with a visible Next button is showing.
	if not visible or not _next_btn.visible:
		return
	if event.is_action_pressed("graft_select"):
		next_pressed.emit()
		get_viewport().set_input_as_handled()


## higlight null = no highlight .
func show_step(title: String, body: String, show_next: bool, highlight = null) -> void:
	visible = true
	_title_label.text = title
	_body_label.text = body
	_next_btn.visible = show_next

	_spotlight.hide()
	_spotlight2.hide()

	if highlight is Control:
		_set_spotlight_rect(_spotlight, (highlight as Control).get_global_rect())
	elif highlight is Array:
		if highlight.size() > 0 and highlight[0] is Control:
			_set_spotlight_rect(_spotlight, (highlight[0] as Control).get_global_rect())
		if highlight.size() > 1 and highlight[1] is Control:
			_set_spotlight_rect(_spotlight2, (highlight[1] as Control).get_global_rect())

func _set_spotlight_rect(spot: ColorRect, rect: Rect2) -> void:
	spot.global_position = rect.position - Vector2.ONE * SPOTLIGHT_PADDING
	spot.size = rect.size + Vector2.ONE * SPOTLIGHT_PADDING * 2.0
	var mat := spot.material as ShaderMaterial
	if mat:
		mat.set_shader_parameter("inner_size", rect.size)
		mat.set_shader_parameter("outer_size", spot.size)
	spot.show()
