extends Node

var current_song : AudioStreamPlayer = null;

func _ready():
	process_mode = Node.PROCESS_MODE_ALWAYS;

func set_bgm(music : AudioStream, fade_time : float = 0.0):
	if current_song != null:
		if music == current_song.stream:
			return;
	
	var new_song : AudioStreamPlayer = AudioStreamPlayer.new();
	add_child(new_song);
	
	new_song.stream = music;
	new_song.bus = "Music";
	new_song.play();
	
	if current_song != null:
		var vol_tween : Tween = create_tween().set_parallel();
		new_song.volume_db = linear_to_db(0.0);
		vol_tween.tween_property(current_song, "volume_db", linear_to_db(0.0), fade_time);
		vol_tween.tween_property(new_song, "volume_db", linear_to_db(1.0), fade_time);
		vol_tween.play();
	
	current_song = new_song;
