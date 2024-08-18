@tool
extends Node3D
class_name GravityBeam

@export var pushing : bool = false:
	set(value):
		pushing = value;
		if (!is_node_ready()):
			await tree_entered;
		%PushNodes.visible =  pushing;
		%PullNodes.visible = !pushing;

@export var gravity_strength : float = 9.8:
	set(value):
		gravity_strength = value;
		%GravityArea.gravity = gravity_strength;

func _physics_process(_delta):
	if (Engine.is_editor_hint() == true):
		return;
	var gravity_direction : Vector3;
	gravity_direction = global_transform.basis.y.normalized();
	if (!pushing):
		gravity_direction *= -1;
	%GravityArea.gravity_direction = gravity_direction;
