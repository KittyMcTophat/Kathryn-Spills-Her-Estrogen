extends Actor
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

@export var death_reset_time : float = 1.0;

func _physics_process(delta : float) -> void:
	# Return if no movement parameters are available
	if get_movement_params() == null:
		return
	
	# Set the gravity scale so that it properly applies when the Actor script does gravity calculations
	gravity_scale = get_movement_params().gravity_scale;
	
	super._physics_process(delta);
	
	# Process physics
	process_h_movement();
	process_jump();
	
	process_collisions();
	
	# Process visuals
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
	input_vector += Input.get_vector("move_left_analog", "move_right_analog", "move_up_analog", "move_down_analog");
	input_vector = input_vector.limit_length(1.0);
	
	var accel_amount : float = 0.0;
	if input_vector != Vector2.ZERO:
		accel_amount = get_movement_params().acceleration;
	else:
		accel_amount = get_movement_params().deceleration;
	
	# Convert to a 3d vector
	var target_local_velocity : Vector3 = Vector3(input_vector.x, 0.0, input_vector.y) * get_movement_params().max_speed;
	# Apply the camera's rotation to the target velocity
	target_local_velocity = target_local_velocity.rotated(Vector3.UP, $CameraPivot.rotation.y);
	local_velocity.x = move_toward(local_velocity.x, target_local_velocity.x, accel_amount * get_physics_process_delta_time());
	local_velocity.z = move_toward(local_velocity.z, target_local_velocity.z, accel_amount * get_physics_process_delta_time());
	
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

var coyote_time : float = 0.0;
var jump_buffer : float = 0.0;
func process_jump() -> void:
	if coyote_time > 0.0:
		coyote_time -= get_physics_process_delta_time();
	if jump_buffer > 0.0:
		jump_buffer -= get_physics_process_delta_time();
	
	if Input.is_action_just_pressed("jump"):
		jump_buffer = get_movement_params().jump_buffer_secs;
	
	if is_on_floor():
		coyote_time = get_movement_params().coyote_time_secs;
	elif !Input.is_action_pressed("jump"):
		local_velocity.y = move_toward(local_velocity.y, 0.0,\
		get_movement_params().decel_when_no_jump_key * get_physics_process_delta_time());
	
	if coyote_time > 0.0 && jump_buffer > 0.0:
		local_velocity.y = get_movement_params().jump_force;
		squash(jump_stretch, jump_stretch_time);
		jump_buffer = 0.0;
		coyote_time = 0.0;
		jumped.emit();

var was_on_floor_last_check : bool = true;
#var last_local_velocity : Vector3 = Vector3.ZERO;
func process_collisions() -> void:
	#last_local_velocity = local_velocity;
	
	#if get_slide_collision_count() > 0:
	#	if last_local_velocity.y - local_velocity.y < -2.0:
	#		squash(land_squash, land_squash_time);
	#		landed.emit();

	if is_on_floor() && !was_on_floor_last_check:
		squash(land_squash, land_squash_time);
		landed.emit();
	
	was_on_floor_last_check = is_on_floor();

@onready var anim_player : AnimationPlayer = $AnimationPlayer
func update_animation() -> void:
	if is_on_floor():
		if local_velocity.length() < 0.01:
			anim_player.speed_scale = 1.0;
			anim_player.play("Idle_B" if facing_back else "Idle");
		else:
			anim_player.speed_scale = local_velocity.length() / get_movement_params().max_speed;
			anim_player.play("Walk_B" if facing_back else "Walk");
	else:
		if velocity.y > 0.0:
			anim_player.speed_scale = 1.0;
			anim_player.play("Jump_B" if facing_back else "Jump");
		else:
			anim_player.speed_scale = 1.0;
			anim_player.play("Fall_B" if facing_back else "Fall");

var squash_tween : Tween = null;
func squash(amount : Vector3, time : float) -> void:
	$MeshPivot.scale = amount;
	if squash_tween != null:
		squash_tween.kill();
	squash_tween = $MeshPivot.create_tween();
	
	squash_tween.tween_property($MeshPivot, "scale", Vector3.ONE, time);

func die():
	Global.allow_pause = false;
	enable_movement = false;
	visible = false;
	$DeathSound.play();
	
	var num_corpses : int = 1;
	while (randi() % 10 != 0):
		num_corpses += 1;
	
	if num_corpses == 1:
		get_parent().add_child(make_corpse());
	else:
		for i in range(num_corpses):
			get_parent().add_child(make_corpse(true));
	
	var timer : Timer = Timer.new();
	add_child(timer);
	timer.wait_time = death_reset_time;
	timer.start()
	
	await timer.timeout;
	
	Global.fade_and_reload_scene();

func make_corpse(spread : bool = false, spread_angle : float = PI / 4.0) -> RigidBody3D:
	var corpse : RigidBody3D = RigidBody3D.new();
	corpse.collision_layer = self.collision_layer;
	corpse.collision_mask = self.collision_mask;
	
	corpse.position = self.position;
	corpse.basis = self.basis;
	corpse.linear_velocity = self.velocity;
	corpse.angular_velocity = Vector3(randf_range(-5.0, 5.0), randf_range(-5.0, 5.0), randf_range(-5.0, 5.0));
	corpse.process_mode = Node.PROCESS_MODE_ALWAYS;
	
	if spread:
		var direction : Vector2 = (Vector2.UP * randf()).rotated(randf_range(-PI, PI));
		corpse.linear_velocity = corpse.linear_velocity.rotated(Vector3(1.0, 0.0, 0.0), direction.x * spread_angle);
		corpse.linear_velocity = corpse.linear_velocity.rotated(Vector3(0.0, 0.0, 1.0), direction.y * spread_angle);
	
	for child in get_children():
		if (child is Node3D) && !(child is PlayerCamera):
			corpse.add_child(child.duplicate());
	
	return corpse;
