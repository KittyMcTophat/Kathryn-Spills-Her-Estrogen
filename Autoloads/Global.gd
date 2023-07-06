extends Node

var catgirl_mode : bool = true;

var fade_color_rect : ColorRect = null;

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS;
	
	var canv_layer : CanvasLayer = CanvasLayer.new();
	add_child(canv_layer);
	canv_layer.layer = 99;
	
	fade_color_rect = ColorRect.new();
	fade_color_rect.color = Color.TRANSPARENT;
	canv_layer.add_child(fade_color_rect);
	fade_color_rect.set_anchors_preset(Control.PRESET_FULL_RECT, true);

func fade_to_scene(scene : PackedScene, fade_color : Color = Color("#ffceff"), time : float = 0.75) -> void:
	pause_stuff();
	
	# Sets the color to a transparent version of the fade color
	# So that only the alpha property changes in the tween
	fade_color_rect.color = Color(fade_color, 0.0);
	
	var fade_in_tween : Tween = create_tween();
	fade_in_tween.tween_property(fade_color_rect, "color", fade_color, time / 2.0);
	await fade_in_tween.finished;
	
	get_tree().change_scene_to_packed(scene);
	
	var fade_out_tween : Tween = create_tween();
	fade_out_tween.tween_property(fade_color_rect, "color", Color(fade_color, 0.0), time / 2.0);
	await fade_out_tween.finished;
	
	unpause_stuff();

func pause_stuff() -> void:
	get_tree().paused = true;

func unpause_stuff() -> void:
	get_tree().paused = false;
