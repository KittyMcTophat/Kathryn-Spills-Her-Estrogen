extends Node3D

@export var max_x_rotation : float = PI / 4.0;
@export var min_x_rotation : float = -PI / 4.0;
@export var horizontal_rot_speed : float = PI / 1.4;
@export var vertical_rot_speed : float = PI / 4.0;

func _process(delta):
	var vertical_rot_input : float = Input.get_axis("camera_up", "camera_down");
	vertical_rot_input += Input.get_axis("camera_up_analog", "camera_down_analog");
	vertical_rot_input = clampf(vertical_rot_input, -1.0, 1.0);
	rotation.x += vertical_rot_input * vertical_rot_speed * delta;
	rotation.x = clampf(rotation.x, min_x_rotation, max_x_rotation);
	
	var horizontal_rot_input : float = Input.get_axis("camera_left", "camera_right");
	horizontal_rot_input += Input.get_axis("camera_left_analog", "camera_right_analog");
	horizontal_rot_input = clampf(horizontal_rot_input, -1.0, 1.0);
	rotation.y -= horizontal_rot_input * horizontal_rot_speed * delta;
