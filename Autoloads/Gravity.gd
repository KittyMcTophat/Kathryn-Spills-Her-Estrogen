extends Node

signal gravity_changed(value : Vector3);

func set_gravity(value : Vector3):
	var tmp_node3d : Node3D = Node3D.new()
	add_child(tmp_node3d);
	await get_tree().physics_frame;
	PhysicsServer3D.area_set_param(tmp_node3d.get_world_3d().space, PhysicsServer3D.AREA_PARAM_GRAVITY_VECTOR, value.normalized());
	PhysicsServer3D.area_set_param(tmp_node3d.get_world_3d().space, PhysicsServer3D.AREA_PARAM_GRAVITY, value.length());
	tmp_node3d.queue_free();
	gravity_changed.emit(value);
