extends MeshInstance3D

func _ready():
	(get_surface_override_material(0) as StandardMaterial3D).albedo_texture = Global.costume;
