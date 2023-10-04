@tool
extends Node3D

@export_multiline var text : String = "Text":
	set(value):
		text = value;
		$SubViewport/Label.text = text;
		$SubViewport.render_target_update_mode = SubViewport.UPDATE_ONCE;

func _ready():
	$MeshInstance.set_surface_override_material(0, $MeshInstance.get_surface_override_material(0).duplicate());
	($MeshInstance.get_surface_override_material(0) as StandardMaterial3D).albedo_texture = $SubViewport.get_texture();
