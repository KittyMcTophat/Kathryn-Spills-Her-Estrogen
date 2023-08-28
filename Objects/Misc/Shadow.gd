extends Node3D

func _physics_process(_delta):
	$RayCast3D.force_raycast_update();
	if $RayCast3D.is_colliding():
		$Shadow.global_position = $RayCast3D.get_collision_point();
		$Shadow.position += $RayCast3D.get_collision_normal() * 0.01;
		$Shadow.show();
	else:
		$Shadow.hide();
