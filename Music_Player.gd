extends Node
var music_player: AudioStreamPlayer
func _ready() -> void:
	music_player = AudioStreamPlayer.new()
	music_player.bus = "Music"
	music_player.volume_db = -8.0
	add_child(music_player)

func play_music(music: AudioStream) -> void:
	music_player.stream = music
	music_player.play()

func stop_music() -> void:
	var tween = create_tween()
	tween.tween_property(music_player, "volume_db", -80.0, 1.0)

	tween.tween_callback(func():
		music_player.stop()
		music_player.volume_db = -8.0)
