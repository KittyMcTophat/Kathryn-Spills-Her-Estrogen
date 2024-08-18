extends CharacterBody3D
class_name GravityObject

@export var enable_movement : bool = true;

@export var orient_with_gravity : bool = true;
@export var reorientation_lerp_multiplier : float = 10.0;
@export var friction : float = 0.5;

# If in a zero gravity area, uses the last non-zero gravity
@export var keep_last_gravity : bool = true;
@export var gravity_scale : float = 1.0;

var gravity : Vector3 = Vector3.ZERO;

var _cached_velocity : Vector3 = Vector3.ZERO;
var local_velocity : Vector3 = Vector3.ZERO:
	set(value):
		velocity = global_transform.basis * value;
		_cached_velocity = velocity;
		local_velocity = value;
	get:
		if _cached_velocity != velocity:
			_cached_velocity = velocity;
			local_velocity = global_transform.basis.transposed() * velocity;
		return local_velocity;

var horizontal_velocity : Vector3 = Vector3.ZERO:
	set(value):
		var new_local_velocity : Vector3 = Vector3.ZERO;
		new_local_velocity.y = local_velocity.y;
		new_local_velocity.x = value.x;
		new_local_velocity.z = value.z;
		local_velocity = new_local_velocity;
	get:
		horizontal_velocity = local_velocity;
		horizontal_velocity.y = 0.0;
		return horizontal_velocity;

func _physics_process(_delta : float):
	if !enable_movement:
		return;
	
	update_gravity();
	
	apply_gravity_to_velocity();
	
	apply_friction();
	
	if (orient_with_gravity):
		orient_actor_with_gravity();

func update_gravity() -> void:
	var state : PhysicsDirectBodyState3D = PhysicsServer3D.body_get_direct_state(get_rid());
	if (!state.get_total_gravity().is_zero_approx() || !keep_last_gravity):
		gravity = state.get_total_gravity() * gravity_scale;

func apply_gravity_to_velocity() -> void:
	velocity += gravity * get_physics_process_delta_time();
	if (!gravity.is_zero_approx()):
		set_up_direction(-gravity);
	move_and_slide();

func apply_friction() -> void:
	if (is_on_floor()):
		horizontal_velocity = horizontal_velocity.lerp(Vector3.ZERO, friction * get_physics_process_delta_time());

func orient_actor_with_gravity() -> void:
	var new_basis : Basis = align_basis_with_gravity(global_transform.basis, gravity);
	if (!is_zero_approx(new_basis.determinant())):
		global_transform.basis = global_transform.basis.slerp(new_basis,\
		get_physics_process_delta_time() * reorientation_lerp_multiplier);

func align_basis_with_gravity(old_basis : Basis, grav : Vector3) -> Basis:
	old_basis.y = -grav;
	old_basis.x = -old_basis.z.cross(-grav);
	return old_basis.orthonormalized();
