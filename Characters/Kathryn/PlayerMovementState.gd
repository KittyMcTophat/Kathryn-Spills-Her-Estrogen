extends ActorState
class_name PlayerMovementState

@export var movement_params : MovementParams = null;
@export var animation_name : String = "Idle";
@onready var anim_player : AnimationPlayer = get_node_or_null("%AnimationPlayer");

func enter_state(actor : Actor) -> void:
	actor.gravity_scale = movement_params.gravity_scale;
	update_animation(actor as Kathryn);

func state_physics_process(_delta : float, actor : Actor) -> void:
	process_h_movement(actor as Kathryn);
	process_jump(actor as Kathryn);
	update_animation(actor as Kathryn);
	change_state_if_needed(actor as Kathryn);

func update_animation(actor : Kathryn) -> void:
	if anim_player == null:
		return;
	
	anim_player.speed_scale = actor.local_velocity.length() / movement_params.max_speed;
	if actor.facing_back:
		anim_player.play(animation_name + "_B");
	else:
		anim_player.play(animation_name);

func process_h_movement(actor : Kathryn) -> void:
	var input_vector : Vector2 = actor.get_input_vector();
	
	var accel_amount : float = 0.0;
	if input_vector != Vector2.ZERO:
		accel_amount = movement_params.acceleration;
	else:
		accel_amount = movement_params.deceleration;
	
	# Convert to a 3d vector
	var target_local_velocity : Vector3 = Vector3(input_vector.x, 0.0, input_vector.y) * movement_params.max_speed;
	# Apply the camera's rotation to the target velocity
	target_local_velocity = target_local_velocity.rotated(Vector3.UP, %CameraPivot.rotation.y);
	var new_local_velocity = actor.local_velocity;
	new_local_velocity.x = move_toward(new_local_velocity.x, target_local_velocity.x, accel_amount * get_physics_process_delta_time());
	new_local_velocity.z = move_toward(new_local_velocity.z, target_local_velocity.z, accel_amount * get_physics_process_delta_time());
	actor.local_velocity = new_local_velocity;

func process_jump(actor : Kathryn) -> void:
	if actor.coyote_time > 0.0:
		actor.coyote_time -= get_physics_process_delta_time();
	if actor.jump_buffer > 0.0:
		actor.jump_buffer -= get_physics_process_delta_time();
	
	if Input.is_action_just_pressed("jump"):
		actor.jump_buffer = movement_params.jump_buffer_secs;
	
	if actor.is_on_floor():
		actor.coyote_time = movement_params.coyote_time_secs;
	elif !Input.is_action_pressed("jump"):
		actor.local_velocity.y = move_toward(actor.local_velocity.y, 0.0,\
		movement_params.decel_when_no_jump_key * get_physics_process_delta_time());
	
	if actor.coyote_time > 0.0 && actor.jump_buffer > 0.0:
		actor.local_velocity.y = movement_params.jump_force;
		actor._jumped();
		actor.jump_buffer = 0.0;
		actor.coyote_time = 0.0;

func change_state_if_needed(actor : Kathryn):
	if actor.is_on_floor() && actor.state.name != "JumpState":
		if actor.local_velocity.length() < 0.01:
			actor.set_state("IdleState");
		else:
			actor.set_state("WalkState");
	else:
		if actor.local_velocity.y < 0.01:
			actor.set_state("FallState");
