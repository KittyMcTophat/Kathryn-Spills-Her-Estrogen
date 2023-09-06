extends CharacterBody3D
class_name Actor

@export var orient_with_gravity : bool = true;
@export var reorientation_lerp_multiplier : float = 10.0;
@export var friction : float = 0.5;

# If in a zero gravity area, uses the last non-zero gravity
@export var keep_last_gravity : bool = true;

var gravity_scale : float = 1.0;
var gravity : Vector3 = Vector3.ZERO;
var local_velocity : Vector3 = Vector3.ZERO:
	set(value):
		velocity = global_transform.basis * value;
		local_velocity = value;
	get:
		local_velocity = global_transform.basis.transposed() * velocity;
		return local_velocity;

func _physics_process(delta : float):
	var state : PhysicsDirectBodyState3D = PhysicsServer3D.body_get_direct_state(get_rid());
	if (!state.get_total_gravity().is_zero_approx() || !keep_last_gravity):
		gravity = state.get_total_gravity();
	
	velocity += gravity * gravity_scale * delta;
	if (!gravity.is_zero_approx()):
		set_up_direction(-gravity);
	move_and_slide();
	
	if (is_on_floor()):
		velocity = velocity.lerp(Vector3.ZERO, friction * delta);
	
	if (orient_with_gravity):
		var new_basis : Basis = align_with_gravity(global_transform.basis, gravity);
		if (!is_zero_approx(new_basis.determinant())):
			global_transform.basis = global_transform.basis.slerp(new_basis, delta * reorientation_lerp_multiplier);

func align_with_gravity(xform : Basis, grav : Vector3):
	xform.y = -grav;
	xform.x = -xform.z.cross(-grav);
	return xform.orthonormalized();
