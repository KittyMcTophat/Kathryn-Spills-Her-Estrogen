@tool
extends BetterButton
class_name LevelButton

@export_file("*.tscn") var level_path : String = "":
	set(value):
		level_path = value;
		if (Levels.level_names.has(level_path)):
			text = Levels.level_names[level_path];
		if (!is_node_ready()):
			await ready;
		%SceneLoader.next_scene = level_path;
