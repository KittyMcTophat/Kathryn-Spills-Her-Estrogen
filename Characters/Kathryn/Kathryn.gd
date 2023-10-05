extends Actor
class_name Kathryn

signal jumped();
signal landed();

@export var turn_time : float = 0.2;
var facing_left : bool = false;
var facing_back : bool = false;

@export var jump_stretch : Vector3 = Vector3(0.9, 1.05, 0.9);
@export var jump_stretch_time : float = 0.3;
@export var land_squash : Vector3 = Vector3(1.1, 0.9, 1.1);
@export var land_squash_time : float = 0.3;

@export var death_reset_time : float = 1.0;

# Used by PlayerMovementState to share jump information between states
var coyote_time : float = 0.0;
var jump_buffer : float = 0.0;

func _physics_process(delta : float) -> void:
	super._physics_process(delta);
	
	process_flip();
	
	process_landing();

var turn_tween : Tween = null;
func process_flip() -> void:
	var input_vector : Vector2 = get_input_vector();
	
	# Flip her around if needed
	if (input_vector.x > 0.1 && facing_left) || (input_vector.x < -0.1 && !facing_left):
		if turn_tween != null:
			turn_tween.kill();
		turn_tween = $MeshPivot.create_tween();
		
		var target_rotation : Vector3 = Vector3.ZERO;
		if input_vector.x < 0.0:
			# Pi is negative because the flip looks better that way
			target_rotation = Vector3(0.0, -PI, 0.0);
		turn_tween.tween_property($MeshPivot, "extra_rotation", target_rotation, turn_time);
		facing_left = input_vector.x < 0.0;
	if (input_vector.y < -0.1 && !facing_back) || (input_vector.y > 0.1 && facing_back):
		facing_back = !facing_back;

func get_input_vector() -> Vector2:
	var input_vector : Vector2 = Input.get_vector("move_left", "move_right", "move_up", "move_down");
	input_vector += Input.get_vector("move_left_analog", "move_right_analog", "move_up_analog", "move_down_analog");
	return input_vector.limit_length(1.0);

var was_on_floor_last_check : bool = true;
func process_landing() -> void:
	if is_on_floor() && !was_on_floor_last_check:
		squash(land_squash, land_squash_time);
		landed.emit();
	
	was_on_floor_last_check = is_on_floor();

func _jumped() -> void:
	jumped.emit();
	squash(jump_stretch, jump_stretch_time);
	set_state("JumpState");

var squash_tween : Tween = null;
func squash(amount : Vector3, time : float) -> void:
	$MeshPivot.scale = amount;
	if squash_tween != null:
		squash_tween.kill();
	squash_tween = $MeshPivot.create_tween();
	
	squash_tween.tween_property($MeshPivot, "scale", Vector3.ONE, time);

func die():
	MusicManager.set_bgm(null);
	set_state("DeathState");
	await get_tree().create_timer(death_reset_time, false).timeout;
	SceneManager.fade_and_reload_scene();
