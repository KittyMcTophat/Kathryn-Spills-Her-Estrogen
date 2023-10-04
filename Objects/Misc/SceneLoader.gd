extends Node
class_name SceneLoader

@export var fade_color : Color = Color("#ffceff");
@export var fade_time : float = 0.75;

@export_file("*.tscn") var next_scene : String = "";

func change_scene():
	SceneManager.fade_to_scene(load(next_scene), fade_color, fade_time);
