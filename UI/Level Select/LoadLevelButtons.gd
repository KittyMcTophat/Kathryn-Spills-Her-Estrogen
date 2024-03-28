@tool
extends VBoxContainer

func _ready():
	var level_button_scene : PackedScene = load("res://UI/Level Select/level_button.tscn");
	
	for level in Levels.levels:
		var new_level_button : LevelButton = level_button_scene.instantiate();
		new_level_button.level_path = level;
		add_child(new_level_button);

	if Engine.is_editor_hint():
		return;
	
	find_next_valid_focus().grab_focus();
