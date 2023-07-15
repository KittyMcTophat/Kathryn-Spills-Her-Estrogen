extends CharacterBody3D
class_name Kathryn

signal jumped();
signal landed();

@export var grounded : MovementParams = null;
@export var midair_rising : MovementParams = null;
@export var midair_falling : MovementParams = null;

@export var turn_time : float = 0.2;
var facing_left : bool = false;
var facing_back : bool = false;

@export var jump_stretch : Vector3 = Vector3(0.9, 1.05, 0.9);
@export var jump_stretch_time : float = 0.3;
@export var land_squash : Vector3 = Vector3(1.1, 0.9, 1.1);
@export var land_squash_time : float = 0.3;

var squash_tween : Tween = null;
func squash(amount : Vector3, time : float) -> void:
	$MeshPivot.scale = amount;
	if squash_tween != null:
		squash_tween.kill();
	squash_tween = $MeshPivot.create_tween();
	
	squash_tween.tween_property($MeshPivot, "scale", Vector3.ONE, time);

var last_velocity : Vector3 = Vector3.ZERO;
func _physics_process(delta : float) -> void:
	# Return if no movement parameters are available
	if get_movement_params() == null:
		return
	
	# Apply the gravity.
	if not is_on_floor():
		velocity += PhysicsServer3D.body_get_direct_state(get_rid()).total_gravity\
		* delta * get_movement_params().gravity_scale;
	
	# Apply horzontal movement
	process_h_movement();
	
	process_jump();
	
	last_velocity = velocity;
	
	move_and_slide();
	
	process_collisions();
	
	update_animation();

func get_movement_params() -> MovementParams:
	# Figure out what set of movement parameters to use
	if is_on_floor():
		return grounded;
	else:
		if velocity.y > 0.0:
			return midair_rising;
		else:
			return midair_falling;

var turn_tween : Tween = null;
func process_h_movement() -> void:
	var input_vector : Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down");
	var accel_amount : float = 0.0;
	if input_vector != Vector2.ZERO:
		accel_amount = get_movement_params().acceleration;
	else:
		accel_amount = get_movement_params().deceleration;
	
	# Convert to a 3d vector
	var target_velocity : Vector3 = Vector3(input_vector.x, 0.0, input_vector.y) * get_movement_params().max_speed;
	# Apply the camera's rotation to the target velocity
	target_velocity = target_velocity.rotated(Vector3.UP, get_viewport().get_camera_3d().global_rotation.y);
	velocity.x = move_toward(velocity.x, target_velocity.x, accel_amount * get_physics_process_delta_time());
	velocity.z = move_toward(velocity.z, target_velocity.z, accel_amount * get_physics_process_delta_time());
	
	# Flip her around if needed
	if (input_vector.x > 0.1 && facing_left) || (input_vector.x < -0.1 && !facing_left):
		if turn_tween != null:
			turn_tween.kill();
		turn_tween = $MeshPivot.create_tween();
		
		if input_vector.x > 0.0:
			turn_tween.tween_property($MeshPivot, "extra_rotation", Vector3.ZERO, turn_time);
			facing_left = false;
		else:
			# Pi is negative because the flip looks better that way
			turn_tween.tween_property($MeshPivot, "extra_rotation", Vector3(0.0, -PI, 0.0), turn_time);
			facing_left = true;
	if (input_vector.y < -0.1 && !facing_back) || (input_vector.y > 0.1 && facing_back):
		facing_back = !facing_back;

@onready var coyote_time_timer : Timer = $CoyoteTime;
@onready var jump_buffer_timer : Timer = $JumpBuffer;
func process_jump() -> void:
	if Input.is_action_just_pressed("jump"):
		jump_buffer_timer.start();
	
	if is_on_floor():
		coyote_time_timer.start();
	elif !Input.is_action_pressed("jump"):
		velocity.y = move_toward(velocity.y, 0.0,\
		get_movement_params().decel_when_no_jump_key * get_physics_process_delta_time());
	
	if coyote_time_timer.time_left > 0.0 && jump_buffer_timer.time_left > 0.0:
		velocity.y = get_movement_params().jump_force;
		squash(jump_stretch, jump_stretch_time);
		jump_buffer_timer.stop();
		coyote_time_timer.stop();
		jumped.emit();

func process_collisions() -> void:
	if get_slide_collision_count() > 0:
		if last_velocity.y - velocity.y < -1.0:
			squash(land_squash, land_squash_time);
			landed.emit();

@onready var anim_player : AnimationPlayer = $AnimationPlayer
func update_animation() -> void:
	if is_on_floor():
		if velocity.length() < 0.01:
			anim_player.speed_scale = 1.0;
			anim_player.play("Idle_B" if facing_back else "Idle");
		else:
			anim_player.speed_scale = velocity.length() / get_movement_params().max_speed;
			anim_player.play("Walk_B" if facing_back else "Walk");
	else:
		if velocity.y > 0.0:
			anim_player.speed_scale = 1.0;
			anim_player.play("Jump_B" if facing_back else "Jump");
		else:
			anim_player.speed_scale = 1.0;
			anim_player.play("Fall_B" if facing_back else "Fall");
