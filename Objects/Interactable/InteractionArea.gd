extends Area3D
class_name InteractionArea

signal interacted();

@export var interactable_indicator : Node3D = null;

func _ready():
	var update_visibility : Callable = func():
		set_indicator_visibility(is_interactable());
	
	update_visibility.call();
	body_entered.connect(update_visibility.unbind(1));
	body_exited.connect(update_visibility.unbind(1));

func set_indicator_visibility(value : bool) -> void:
	if interactable_indicator == null:
		print("Visibility unchanged, no indicator was given.");
		return;
	if !is_instance_valid(interactable_indicator):
		print("Visibility unchanged, indicator was invalid.");
		return;
	interactable_indicator.visible = value;

func _process(delta):
	if Input.is_action_just_pressed("interact") && is_interactable():
		interacted.emit();

func is_interactable() -> bool:
	for body in get_overlapping_bodies():
		if body is Kathryn:
			return true;
	return false;
