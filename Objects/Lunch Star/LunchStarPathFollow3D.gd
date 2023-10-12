extends PathFollow3D
class_name LunchStarPathFolow3D

signal launched();
signal acceleration_started();
signal launch_finished();

class LaunchSettings:
	var initial_velocity : float;
	var acceleration : float;
	var end_velocity : float;
	var total_distance : float;

# Passed in by lunch star when launching
var ls : LaunchSettings = null;

# Calculated when launched
var acceleration_distance : float = 0.0;

var acceleration_time : float = 0.0;
var total_launch_time : float = 0.0;
var initial_progress : float = 0.0;

var launch_timer : Timer = null;
var accel_timer : Timer = null;

func launch(_ls : LaunchSettings):
	self.ls = _ls;
	calculate_acceleration_distance();
	calculate_time();
	initial_progress = progress;
	
	setup_launch_timer();
	setup_accel_timer();
	
	launched.emit();

func calculate_acceleration_distance():
	var v_f_squared : float = ls.end_velocity * ls.end_velocity;
	var v_i_squared : float = ls.initial_velocity * ls.initial_velocity;
	
	var numerator : float = v_f_squared - v_i_squared;
	var denominator : float = 2 * ls.acceleration;
	
	if denominator != 0:
		acceleration_distance = absf(numerator / denominator);
	else:
		acceleration_distance = 0.0;

func calculate_time():
	if ls.acceleration == 0:
		acceleration_time = 0;
	else:
		acceleration_time = absf((ls.end_velocity - ls.initial_velocity) / (ls.acceleration));
	
	total_launch_time = (ls.total_distance - acceleration_distance) / ls.initial_velocity;
	total_launch_time += acceleration_time;

func setup_launch_timer():
	launch_timer = setup_timer();
	
	launch_timer.wait_time = total_launch_time;
	launch_timer.start();
	
	await launch_timer.timeout;
	
	launch_finished.emit();

func setup_accel_timer():
	accel_timer = setup_timer();
	
	accel_timer.wait_time = total_launch_time - acceleration_time;
	accel_timer.start();
	
	await accel_timer.timeout;
	
	acceleration_started.emit();

func setup_timer() -> Timer:
	var ret_timer = Timer.new();
	add_child(ret_timer);
	ret_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS;
	ret_timer.one_shot = true;
	return ret_timer;

func _physics_process(_delta):
	if launch_timer == null:
		return;
	
	progress = calculate_progress() + initial_progress;

func calculate_progress() -> float:
	if elapsed_time() < (total_launch_time - acceleration_time):
		return ls.initial_velocity * elapsed_time();
	elif elapsed_time() < total_launch_time && ls.acceleration != 0.0:
		var prog : float = ls.initial_velocity * (total_launch_time - acceleration_time);

		var accelerate_time_passed : float = (elapsed_time() - (total_launch_time - acceleration_time));
		var cur_velocity : float = move_toward(ls.initial_velocity, ls.end_velocity,
		absf(ls.acceleration) * accelerate_time_passed);
		var numerator : float = ((cur_velocity * cur_velocity) - (ls.initial_velocity * ls.initial_velocity));
		var denominator : float = (2.0 * ls.acceleration);
		prog += absf(numerator / denominator);
		
		return prog;
	else:
		return ls.total_distance;

func elapsed_time():
	return total_launch_time - launch_timer.time_left;
