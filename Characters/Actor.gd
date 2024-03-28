extends GravityObject
class_name Actor

@export var initial_state : String = "";
var state : ActorState = null;

var states : Dictionary = {};

func _ready():
	var nodes_to_check : Array[Node] = get_children();
	while !nodes_to_check.is_empty():
		for child in nodes_to_check[0].get_children():
			nodes_to_check.push_back(child);
			if child is ActorState:
				states[child.name.to_lower()] = child;
		nodes_to_check.pop_front();
	Log.print_info("Actor: " + str(self) + ": States loaded: " + str(states));
	
	await get_tree().process_frame;
	
	set_state(initial_state);

func set_state(new_state : String) -> void:
	if actor_state_is_valid():
		if new_state.to_lower() == state.name.to_lower():
			return;
		else:
			state.exit_state(self);
			state.state_exited.emit();
	if (!states.has(new_state.to_lower())):
		var message : String = "Invalid State: " + new_state + "On actor: " + name + " " + str(self);
		Log.print_error(message);
		OS.crash(message);
	state = states[new_state.to_lower()];
	state.enter_state(self);
	state.state_entered.emit();

func _process(delta : float):
	if actor_state_is_valid():
		state.state_process(delta, self);

func _physics_process(delta : float):
	super._physics_process(delta);
	
	if actor_state_is_valid():
		state.state_physics_process(delta, self);

func actor_state_is_valid() -> bool:
	return (state != null) && (is_instance_valid(state));
