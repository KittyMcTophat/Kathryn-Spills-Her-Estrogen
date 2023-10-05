@tool
extends Path3D
class_name LunchStar

func _ready():
	curve_changed.connect(_on_curve_changed);
	_on_curve_changed();

func _on_curve_changed():
	if curve != null && curve.point_count > 0:
		if curve.get_point_position(0) != Vector3.ZERO:
			curve.set_point_position(0, Vector3.ZERO);
			return; # Since the change will call the function again anyway
	
	point_mesh_to_curve();

func point_mesh_to_curve():
	if curve != null && curve.get_baked_length() >= curve.bake_interval:
		$Meshes.basis = curve.sample_baked_with_rotation(curve.bake_interval, true, true).basis;
	else:
		$Meshes.basis = Basis.IDENTITY;

func get_path_follow() -> PathFollow3D:
	var path_follow : PathFollow3D = PathFollow3D.new();
	add_child(path_follow);
	path_follow.progress = curve.bake_interval;
	path_follow.loop = false;
	path_follow.use_model_front = true;
	return path_follow;
