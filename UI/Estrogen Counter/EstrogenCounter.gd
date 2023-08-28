extends MarginContainer
class_name EstrogenCounter

signal estrogen_changed(value : int);

var current_estrogen : int = 0:
	set(value):
		current_estrogen = value;
		update_text();
		estrogen_changed.emit(current_estrogen);
var max_estrogen : int = 0:
	set(value):
		max_estrogen = value;
		update_text();

func _ready():
	update_text();

func update_text() -> void:
	%Label.text = str(current_estrogen) + "/" + str(max_estrogen);
