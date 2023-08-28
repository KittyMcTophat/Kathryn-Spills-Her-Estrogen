extends Node3D
class_name Estrogen

signal collected;

var is_collected : bool = false;

func _ready():
	Global.estrogen_counter.max_estrogen += 1;

func _on_collection_area_body_entered(body):
	if body is Kathryn:
		collect();

func collect():
	if is_collected:
		return
	is_collected = true;
	Global.estrogen_counter.current_estrogen += 1;
	$CollectAnimationPlayer.play("Collect");
	await $CollectAnimationPlayer.animation_finished;
	collected.emit();
	queue_free();
