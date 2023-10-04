extends Node
class_name ActorState

signal state_entered();
signal state_exited();

func enter_state(_actor : Actor) -> void:
	return;

func exit_state(_actor : Actor) -> void:
	return;

func state_physics_process(_delta : float, _actor : Actor) -> void:
	return;

func state_process(_delta : float, _actor : Actor) -> void:
	return;

