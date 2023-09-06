extends Node3D
class_name PointAtCamera

@export var extra_rotation : Vector3 = Vector3.ZERO;

func _physics_process(_delta):
	if (get_viewport().get_camera_3d() == null):
		return;
	look_at(get_viewport().get_camera_3d().global_position, get_parent_node_3d().global_transform.basis.y);
	
	transform.basis.y = Vector3.UP;
	transform.basis.x = -transform.basis.z.cross(transform.basis.y);
	transform.basis = transform.basis.orthonormalized();
	
	rotation += extra_rotation + Vector3(0.0, PI, 0.0);
