extends Node
class_name LevelController

@export var show_ui : bool = true;
@export var set_gravity : bool = true;
@export var global_gravity : Vector3 = Vector3.DOWN * 9.8;

func _ready():
	Global.ui_control.visible = show_ui;
	
	if set_gravity:
		var tmp_node3d : Node3D = Node3D.new()
		add_child(tmp_node3d);
		await get_tree().physics_frame;
		PhysicsServer3D.area_set_param(tmp_node3d.get_world_3d().space, PhysicsServer3D.AREA_PARAM_GRAVITY_VECTOR, global_gravity.normalized());
		PhysicsServer3D.area_set_param(tmp_node3d.get_world_3d().space, PhysicsServer3D.AREA_PARAM_GRAVITY, global_gravity.length());
		tmp_node3d.queue_free();
