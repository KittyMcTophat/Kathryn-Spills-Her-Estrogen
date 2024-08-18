extends Node

signal window_mode_changed(value : int);

var allow_pause : bool = true;

var estrogen_counter : EstrogenCounter = null;
var pause_menu : PauseMenu = null;
var textbox : Textbox = null;
var textbox_canvas_layer : CanvasLayer = null;
var ui_canvas_layer : CanvasLayer = null;
var ui_control : Control = null;

func _ready() -> void:
	process_mode = Node.PROCESS_MODE_ALWAYS;
	
	ui_canvas_layer = CanvasLayer.new();
	ui_canvas_layer.name = "UICanvasLayer";
	add_child(ui_canvas_layer);
	ui_canvas_layer.layer = 10;
	
	ui_control = Control.new();
	ui_control.name = "UIControl";
	ui_canvas_layer.add_child(ui_control);
	ui_control.set_anchors_preset(Control.PRESET_FULL_RECT, true);
	
	estrogen_counter = preload("res://UI/Estrogen Counter/estrogen_counter.tscn").instantiate();
	ui_control.add_child(estrogen_counter);
	
	pause_menu = preload("res://UI/Pause Menu/pause_menu.tscn").instantiate();
	ui_control.add_child(pause_menu);
	
	textbox_canvas_layer = CanvasLayer.new();
	textbox_canvas_layer.name = "TextboxCanvasLayer";
	add_child(textbox_canvas_layer);
	textbox_canvas_layer.layer = 20;
	textbox = preload("res://UI/Textbox/textbox.tscn").instantiate();
	textbox_canvas_layer.add_child(textbox);
	
	randomize();

func _input(event):
	if event.is_action_pressed("toggle_fullscreen"):
		var mode : int = DisplayServer.window_get_mode();
		if mode == DisplayServer.WINDOW_MODE_FULLSCREEN:
			set_window_mode(DisplayServer.WINDOW_MODE_WINDOWED);
		else:
			set_window_mode(DisplayServer.WINDOW_MODE_FULLSCREEN);

func set_window_mode(mode : int):
	DisplayServer.window_set_mode(mode);
	window_mode_changed.emit(mode);
