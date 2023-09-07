extends Node
class_name EstrogenTracker

@export var target_estrogen : int = 0;

signal target_estrogen_reached();
signal max_estrogen_collected();

func _ready():
	Global.estrogen_counter.estrogen_changed.connect(_estrogen_count_changed);

func _estrogen_count_changed(value : int):
	if Global.estrogen_counter.max_estrogen == value:
		max_estrogen_collected.emit();
	if Global.estrogen_counter.current_estrogen == target_estrogen:
		target_estrogen_reached.emit();
