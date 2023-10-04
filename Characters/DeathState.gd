extends ActorState
class_name DeathState

@export var spread : bool = true;
@export var spread_angle : float = PI / 4.0;
@export var wide_spread_angle : float = PI;

@export var min_corpses : int = 1;
@export var max_corpses : int = 20;
@export var wide_spread_threshold : int = 15;

var num_corpses : int = -1;

func enter_state(actor : Actor):
	Global.allow_pause = false;
	actor.enable_movement = false;
	actor.visible = false;
	
	num_corpses = randi_range(min_corpses, max_corpses);
	
	for i in range(num_corpses):
		actor.get_parent().add_child(make_corpse(actor));

func make_corpse(actor : Actor) -> RigidBody3D:
	var corpse : RigidBody3D = RigidBody3D.new();
	corpse.collision_layer = actor.collision_layer;
	corpse.collision_mask = actor.collision_mask;
	
	corpse.position = actor.position;
	corpse.basis = actor.basis;
	corpse.linear_velocity = actor.velocity;
	corpse.angular_velocity = Vector3(randf_range(-5.0, 5.0), randf_range(-5.0, 5.0), randf_range(-5.0, 5.0));
	corpse.process_mode = Node.PROCESS_MODE_ALWAYS;
	
	if spread:
		var direction : Vector2 = (Vector2.UP * randf()).rotated(randf_range(-PI, PI));
		var _spread_angle : float = spread_angle;
		if num_corpses >= wide_spread_threshold:
			_spread_angle = wide_spread_angle;
		corpse.linear_velocity = corpse.linear_velocity.rotated(Vector3(1.0, 0.0, 0.0), direction.x * _spread_angle);
		corpse.linear_velocity = corpse.linear_velocity.rotated(Vector3(0.0, 0.0, 1.0), direction.y * _spread_angle);
	
	for child in actor.get_children():
		if (child is Node3D) && !(child is PlayerCamera):
			corpse.add_child(child.duplicate());
	
	return corpse;
