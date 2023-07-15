extends Node3D

@export var extra_rotation : Vector3 = Vector3.ZERO;

func _process(_delta):
	var _scale : Vector3 = scale;
	var camera : Camera3D = get_viewport().get_camera_3d();
	global_rotation.y = camera.global_rotation.y;
	rotation += extra_rotation;
	scale = _scale;
