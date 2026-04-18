extends Node
var sfx_player: AudioStreamPlayer
func _ready() -> void:
	sfx_player = AudioStreamPlayer.new()
	sfx_player.bus = "SFX"
	sfx_player.volume_db = -10.0
	add_child(sfx_player)
	
	
func play_sfx(sfx: AudioStream) -> void:
	sfx_player.stream = sfx
	sfx_player.play()
	
