extends Node
var music_player: AudioStreamPlayer
const NORMAL_VOLUME_DB := -3.0
const PAUSED_VOLUME_DB := -20.0

func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.process_mode = Node.PROCESS_MODE_ALWAYS
	music_player.bus = "Music"
	music_player.volume_db = -3.0
	add_child(music_player)

func play_music(music: AudioStream) -> void:
	if music_player.playing and music_player.stream == music:
		return
	var tween = create_tween()

	tween.tween_property(
		music_player,
		"volume_db",
		-80.0,
		1.0
	)

	tween.tween_callback(func():
		music_player.stream = music
		music_player.play()
	)

	tween.tween_property(
		music_player,
		"volume_db",
		-8.0,
		1.0
	)
func stop_music() -> void:
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", -80.0, 1.0)

	tween.tween_callback(func():
		music_player.stop()
		music_player.volume_db = -3.0)

func set_music_paused(paused: bool) -> void:
	var target_volume = PAUSED_VOLUME_DB if paused else NORMAL_VOLUME_DB

	var tween = create_tween()
	tween.tween_property(
		music_player,
		"volume_db",
		target_volume,
		0.3
	)
