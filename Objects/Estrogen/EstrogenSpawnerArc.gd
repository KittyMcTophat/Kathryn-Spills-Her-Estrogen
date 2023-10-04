@tool
extends Node3D
class_name EstrogenSpawnerArc

@export var radius : float = 2.0:
	set(value):
		radius = value;
		if Engine.is_editor_hint():
			regenerate_circle();

@export var amount : int = 8:
	set(value):
		if value >= 1:
			amount = value;
			if Engine.is_editor_hint():
				regenerate_circle();

@export var point_towards_center : bool = false:
	set(value):
		point_towards_center = value;
		if Engine.is_editor_hint():
			regenerate_circle();

@export_range(0.0, 360.0) var spread_degrees : float = 360.0:
	set(value):
		spread_degrees = clampf(value, 0.0, 360.0);
		spread_radians = deg_to_rad(spread_degrees);
		if Engine.is_editor_hint():
			regenerate_circle();

var spread_radians : float = 2.0 * PI;

func _ready():
	regenerate_circle();

func regenerate_circle():
	for child in get_children():
		child.queue_free();
	
	for i in range(amount):
		var new_estrogen : Estrogen = spawn_estrogen_number(i);
		
		add_child(new_estrogen);
		if point_towards_center:
			point_to_center(new_estrogen);

func spawn_estrogen_number(index : int) -> Estrogen:
	var spawn_point : Vector3 = Vector3(radius, 0.0, 0.0);
	spawn_point = spawn_point.rotated(Vector3.UP, ((spread_radians)/amount) * index);
	var new_estrogen : Estrogen = preload("res://Objects/Estrogen/Estrogen.tscn").instantiate();
	new_estrogen.position = spawn_point;
	return new_estrogen;

func point_to_center(estrogen : Estrogen):
	estrogen.rotate_z(-PI / 2.0);
	var angle : float = estrogen.position.signed_angle_to(Vector3.RIGHT, Vector3.DOWN);
	estrogen.rotate_y(angle);
