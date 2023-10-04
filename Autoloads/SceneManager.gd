extends Node

signal fade_in_started();
signal fade_in_finished();
signal fade_out_started();
signal fade_out_finished();

var canvas_layer : CanvasLayer = null;
var fade_color_rect : ColorRect = null;

func _ready():
	canvas_layer = CanvasLayer.new();
	canvas_layer.layer = 20;
	add_child(canvas_layer);
	
	fade_color_rect = ColorRect.new();
	fade_color_rect.name = "FadeColorRect";
	fade_color_rect.color = Color.TRANSPARENT;
	canvas_layer.add_child(fade_color_rect);
	fade_color_rect.set_anchors_preset(Control.PRESET_FULL_RECT, true);
	fade_color_rect.visible = false;
	
	process_mode = Node.PROCESS_MODE_ALWAYS;

func fade_and_reload_scene(fade_color : Color = Color("#ffceff"), time : float = 0.75, pause : bool = true, reset_estrogen : bool = true) -> void:
	print("Reloading scene: ", get_tree().current_scene.scene_file_path);
	function_call_with_fade(get_tree().reload_current_scene, fade_color, time, pause, reset_estrogen);
	print("Reloaded scene!");

func fade_to_scene_path(scene : String, fade_color : Color = Color("#ffceff"), time : float = 0.75, pause : bool = true, reset_estrogen : bool = true) -> void:
	print("Loading scene: ", scene);
	function_call_with_fade(get_tree().change_scene_to_file.bind(scene), fade_color, time, pause, reset_estrogen);
	print("Loaded scene!");

func fade_to_scene(scene : PackedScene, fade_color : Color = Color("#ffceff"), time : float = 0.75, pause : bool = true, reset_estrogen : bool = true) -> void:
	print("Loading scene: ", scene);
	function_call_with_fade(get_tree().change_scene_to_packed.bind(scene), fade_color, time, pause, reset_estrogen);
	print("Loaded scene!");

func function_call_with_fade(function : Callable, fade_color : Color = Color("#ffceff"), time : float = 0.75, pause : bool = true, reset_estrogen : bool = true) -> void:
	if pause:
		pause_stuff();
	
	# Sets the color to a transparent version of the fade color
	# So that only the alpha property changes in the tween
	fade_color_rect.color = Color(fade_color, 0.0);
	fade_color_rect.visible = true;
	
	var fade_in_tween : Tween = create_tween();
	fade_in_tween.tween_property(fade_color_rect, "color", fade_color, time / 2.0);
	fade_in_started.emit();
	
	await fade_in_tween.finished;
	fade_in_finished.emit();
	
	
	if reset_estrogen:
		Global.estrogen_counter.current_estrogen = 0;
		Global.estrogen_counter.max_estrogen = 0;
	function.call();
	
	if pause:
		unpause_stuff();
	
	var fade_out_tween : Tween = create_tween();
	fade_out_tween.tween_property(fade_color_rect, "color", Color(fade_color, 0.0), time / 2.0);
	fade_out_started.emit();
	
	await fade_out_tween.finished;
	fade_out_finished.emit();
	
	
	fade_color_rect.visible = false;

func pause_stuff() -> void:
	Global.allow_pause = false;
	get_tree().paused = true;

func unpause_stuff() -> void:
	Global.allow_pause = true;
	get_tree().paused = false;
