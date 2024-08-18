extends Area3D

@export var pause_delay : float = 0.5;

func _body_entered(body : Node3D):
	if (body is GravityObject):
		await get_tree().create_timer(pause_delay).timeout;
		body.horizontal_velocity = Vector3.ZERO;
