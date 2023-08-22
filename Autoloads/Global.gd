extends Node

var catgirl_mode : bool = true;
var allow_pause : bool = true;

var estrogen_counter : EstrogenCounter = null;
var fade_color_rect : ColorRect = null;
var pause_menu : PauseMenu = null;
var ui_control : Control = null;

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS;
	
	var canv_layer : CanvasLayer = CanvasLayer.new();
	add_child(canv_layer);
	canv_layer.layer = 99;
	
	ui_control = Control.new();
	canv_layer.add_child(ui_control);
	ui_control.set_anchors_preset(Control.PRESET_FULL_RECT, true);
	
	estrogen_counter = preload("res://UI/Estrogen Counter/estrogen_counter.tscn").instantiate();
	ui_control.add_child(estrogen_counter);
	
	pause_menu = preload("res://UI/Pause Menu/pause_menu.tscn").instantiate();
	ui_control.add_child(pause_menu);
	
	fade_color_rect = ColorRect.new();
	fade_color_rect.color = Color.TRANSPARENT;
	canv_layer.add_child(fade_color_rect);
	fade_color_rect.set_anchors_preset(Control.PRESET_FULL_RECT, true);

func fade_and_reload_scene(fade_color : Color = Color("#ffceff"), time : float = 0.75, pause : bool = true, reset_estrogen : bool = true) -> void:
	function_call_with_fade(get_tree().reload_current_scene, fade_color, time, pause, reset_estrogen);

func fade_to_scene_path(scene : String, fade_color : Color = Color("#ffceff"), time : float = 0.75, pause : bool = true, reset_estrogen : bool = true) -> void:
	function_call_with_fade(get_tree().change_scene_to_file.bind(scene), fade_color, time, pause, reset_estrogen);

func fade_to_scene(scene : PackedScene, fade_color : Color = Color("#ffceff"), time : float = 0.75, pause : bool = true, reset_estrogen : bool = true) -> void:
	function_call_with_fade(get_tree().change_scene_to_packed.bind(scene), fade_color, time, pause, reset_estrogen);

func function_call_with_fade(function : Callable, fade_color : Color = Color("#ffceff"), time : float = 0.75, pause : bool = true, reset_estrogen : bool = true) -> void:
	if pause:
		pause_stuff();
	
	# Sets the color to a transparent version of the fade color
	# So that only the alpha property changes in the tween
	fade_color_rect.color = Color(fade_color, 0.0);
	
	var fade_in_tween : Tween = create_tween();
	fade_in_tween.tween_property(fade_color_rect, "color", fade_color, time / 2.0);
	await fade_in_tween.finished;
	
	if reset_estrogen:
		estrogen_counter.current_estrogen = 0;
		estrogen_counter.max_estrogen = 0;
	function.call();
	
	if pause:
		unpause_stuff();
	
	var fade_out_tween : Tween = create_tween();
	fade_out_tween.tween_property(fade_color_rect, "color", Color(fade_color, 0.0), time / 2.0);
	await fade_out_tween.finished;

func pause_stuff() -> void:
	allow_pause = false;
	get_tree().paused = true;

func unpause_stuff() -> void:
	allow_pause = true;
	get_tree().paused = false;
