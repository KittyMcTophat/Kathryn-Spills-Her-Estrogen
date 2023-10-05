extends PathFollow3D
class_name LunchStarPathFolow3D

signal launched();
signal deceleration_started();
signal launch_finished();

class LaunchSettings:
	var initial_velocity : float;
	var deceleration : float;
	var end_velocity : float;
	var total_distance : float;

# Passed in by lunch star when launching
var ls : LaunchSettings = null;

# Calculated when launched
var deceleration_distance : float = 0.0;

var deceleration_time : float = 0.0;
var total_launch_time : float = 0.0;

var launch_timer : Timer = null;
var decel_timer : Timer = null;

func launch(_ls : LaunchSettings):
	self.ls = _ls;
	calculate_deceleration_distance();
	calculate_time();
	launched.emit();
	
	setup_launch_timer();
	setup_decel_timer();

func calculate_deceleration_distance():
	var v_f_squared : float = ls.end_velocity * ls.end_velocity;
	var v_i_squared : float = ls.initial_velocity * ls.initial_velocity;
	
	var numerator : float = v_f_squared - v_i_squared;
	var denominator : float = 2 * (-ls.deceleration);
	
	if denominator != 0:
		deceleration_distance = numerator / denominator;
	else:
		deceleration_distance = 0.0;

func calculate_time():
	if ls.deceleration == 0:
		deceleration_time = 0;
	else:
		deceleration_time = (ls.end_velocity - ls.initial_velocity) / (-ls.deceleration);
	
	total_launch_time = (ls.total_distance - deceleration_distance) / ls.initial_velocity;
	total_launch_time += deceleration_time;

func setup_launch_timer():
	launch_timer = setup_timer();
	
	launch_timer.wait_time = total_launch_time;
	launch_timer.start();
	
	await launch_timer.timeout;
	
	progress = ls.total_distance;
	launch_timer.queue_free();
	launch_timer = null;
	launch_finished.emit();

func setup_decel_timer():
	decel_timer = setup_timer();
	
	decel_timer.wait_time = total_launch_time - deceleration_time;
	decel_timer.start();
	
	await decel_timer.timeout;
	
	decel_timer.queue_free();
	decel_timer = null;
	deceleration_started.emit();

func setup_timer() -> Timer:
	var ret_timer = Timer.new();
	add_child(ret_timer);
	ret_timer.process_callback = Timer.TIMER_PROCESS_PHYSICS;
	ret_timer.one_shot = true;
	return ret_timer;

func _physics_process(delta):
	if launch_timer == null:
		return;
	
	progress = calculate_progress();

func calculate_progress() -> float:
	if elapsed_time() < (total_launch_time - deceleration_time):
		return ls.initial_velocity * elapsed_time();
	elif deceleration_time != 0:
		var prog : float = ls.initial_velocity * (total_launch_time - deceleration_time);

		var decelerate_time_passed : float = (elapsed_time() - (total_launch_time - deceleration_time));
		var cur_velocity : float = (ls.initial_velocity - (ls.deceleration * decelerate_time_passed));
		var numerator : float = ((cur_velocity * cur_velocity) - (ls.initial_velocity * ls.initial_velocity));
		var denominator : float = (2 * -ls.deceleration);
		prog += (numerator / denominator);
		
		return prog;
	else:
		return ls.total_distance;

func elapsed_time():
	return total_launch_time - launch_timer.time_left;
