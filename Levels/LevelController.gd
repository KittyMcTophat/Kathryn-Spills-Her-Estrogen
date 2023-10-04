extends Node
class_name LevelController

@export var show_ui : bool = true;
@export var allow_pause : bool = true;
@export var set_gravity : bool = true;
@export var global_gravity : Vector3 = Vector3.DOWN * 9.8;

func _ready():
	Global.ui_control.visible = show_ui;
	Global.allow_pause = allow_pause;
	
	if set_gravity:
		Gravity.set_gravity(global_gravity);
