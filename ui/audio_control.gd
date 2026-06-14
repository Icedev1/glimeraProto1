extends HSlider

@export var audio_bus_name: String
var audio_bus_id

func _ready() -> void:
	audio_bus_id = AudioServer.get_bus_index(audio_bus_name)
	#sets sound
	if AudioServer.get_bus_volume_db(audio_bus_id) == 1:
		AudioServer.set_bus_volume_db(audio_bus_id, 0.5)
	else:
		AudioServer.set_bus_volume_db(audio_bus_id, AudioServer.get_bus_volume_db(audio_bus_id))
		
	if AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")) == 1:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), 1.0)
	else:
		AudioServer.set_bus_volume_db(AudioServer.get_bus_index("Master"), AudioServer.get_bus_volume_db(AudioServer.get_bus_index("Master")))
	
	value = db_to_linear(AudioServer.get_bus_volume_db(audio_bus_id))

func _on_value_changed(value: float) -> void:
	var db = linear_to_db(value)
	AudioServer.set_bus_volume_db(audio_bus_id, db)
