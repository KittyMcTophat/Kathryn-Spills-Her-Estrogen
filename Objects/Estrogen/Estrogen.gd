extends Node3D
class_name Estrogen

signal collected;

var is_collected : bool = false;

func _ready():
	Global.estrogen_counter.max_estrogen += 1;

func _physics_process(_delta):
	$RayCast3D.force_raycast_update();
	if $RayCast3D.is_colliding():
		$Shadow.global_position = $RayCast3D.get_collision_point();
		$Shadow.position += $RayCast3D.get_collision_normal() * 0.01;
		$Shadow.show();
	else:
		$Shadow.hide();

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
