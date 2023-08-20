extends Resource
class_name MovementParams

@export_group("Physics")
@export var max_speed : float = 2.5;
@export var acceleration : float = 10.0;
@export var deceleration : float = 8.0;
@export var gravity_scale : float = 1.0;
@export var jump_force : float = 4.5;
@export_group("Input")
@export var decel_when_no_jump_key : float = 6.0;
@export var jump_buffer_secs : float = 0.15;
@export var coyote_time_secs : float = 0.2;
