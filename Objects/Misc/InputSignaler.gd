extends Node
class_name InputSignaler

signal input_pressed();

@export var input : String = "";

func _input(event):
	if event.is_action_pressed(input):
		input_pressed.emit();
