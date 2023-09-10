extends HBoxContainer

@export var audio_bus : String = "Master";

func _ready():
	set_volume(%VolumeSlider.value);

func set_volume(value : float):
	var bus_index : int = AudioServer.get_bus_index(audio_bus);
	AudioServer.set_bus_volume_db(bus_index, linear_to_db(value));
