@tool
extends MeshInstance3D

func _ready():
	var num_costumes : int = 0;
	while ResourceLoader.exists("res://Characters/Kathryn/costume" + str(num_costumes) + ".png"):
		num_costumes += 1;
	
	(get_surface_override_material(0) as StandardMaterial3D).uv1_scale.x = (1.0 / float(num_costumes));
	(get_surface_override_material(0) as StandardMaterial3D).uv1_offset.x = Global.costume * (1.0 / float(num_costumes));
