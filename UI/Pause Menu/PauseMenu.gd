extends Control
class_name PauseMenu

var paused : bool = false;

func _ready():
	set_volume(%VolumeSlider.value);

func _process(_delta : float):
	if Input.is_action_just_pressed("pause"):
		if Global.allow_pause == false:
			return;
		if get_tree().paused == false && paused == false:
			pause();
		elif paused:
			unpause();

func pause():
	paused = true;
	get_tree().paused = true;
	
	$AnimationPlayer.play("Show");

func unpause(instant : bool = false):
	paused = false;
	get_tree().paused = false;
	
	# Unfocus any button that may be selected
	# Avoids letting the user press buttons during the hide animation
	grab_focus();
	release_focus();
	
	$AnimationPlayer.play("Hide");
	if instant:
		$AnimationPlayer.seek($AnimationPlayer.get_animation("Hide").length, true);

func _on_restart_button_pressed():
	unpause(true);
	
	Global.fade_and_reload_scene();

func set_volume(value : float):
	var master_volume : int = AudioServer.get_bus_index("Master");
	AudioServer.set_bus_volume_db(master_volume, linear_to_db(value));
