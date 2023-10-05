@tool
extends Path3D
class_name LunchStar

@export_enum("Green", "Gold", "Rainbow") var lunch_star_type : String = "Green":
	set(value):
		lunch_star_type = value;
		reload_meshes();

@export var launch_speed : float = 7.0;
@export var deceleration : float = 1.0;
@export var end_velocity : float = 3.0;

func _ready():
	curve_changed.connect(_on_curve_changed);
	_on_curve_changed();
	reload_meshes();

func reload_meshes():
	for child in %"Outer Ring".get_children():
		child.queue_free();
	for child in %"Inner Ring".get_children():
		child.queue_free();

	var new_outer_ring : PackedScene = preload("res://Objects/Lunch Star/green_outer_ring.tscn");
	var new_inner_ring : PackedScene = preload("res://Objects/Lunch Star/inner_ring.tscn");
	match (lunch_star_type):
		"Gold":
			new_outer_ring = preload("res://Objects/Lunch Star/gold_outer_ring.tscn");
		"Rainbow":
			new_outer_ring = preload("res://Objects/Lunch Star/rainbow_outer_ring.tscn");
	
	%"Outer Ring".add_child(new_outer_ring.instantiate());
	%"Inner Ring".add_child(new_inner_ring.instantiate());

func _on_curve_changed():
	if curve != null && curve.point_count > 0:
		if curve.get_point_position(0) != Vector3.ZERO:
			curve.set_point_position(0, Vector3.ZERO);
			return; # Since the change will call the function again anyway
	
	point_mesh_to_curve();

func point_mesh_to_curve():
	if curve != null && curve.get_baked_length() >= curve.bake_interval:
		%Meshes.basis = curve.sample_baked_with_rotation(curve.bake_interval, true, true).basis;
	else:
		%Meshes.basis = Basis.IDENTITY;

func get_path_follow() -> LunchStarPathFolow3D:
	var path_follow : LunchStarPathFolow3D = LunchStarPathFolow3D.new();
	add_child(path_follow);
	# In the first bake_interval units of the curve, there's some wierdness
	# So we just skip over them
	path_follow.progress = curve.bake_interval;
	path_follow.loop = false;
	path_follow.use_model_front = true;
	return path_follow;

func launch_path_follow(path_follow : LunchStarPathFolow3D):
	# Play some animation
	var ls : LunchStarPathFolow3D.LaunchSettings = LunchStarPathFolow3D.LaunchSettings.new();
	ls.initial_velocity = launch_speed;
	ls.deceleration = deceleration;
	ls.end_velocity = end_velocity;
	# Since we skip the initial bake_interval units of the curve,
	# we have to subtract them from the distance
	ls.total_distance = curve.get_baked_length() - curve.bake_interval;
	path_follow.launch(ls);
