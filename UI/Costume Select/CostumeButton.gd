@tool
extends BetterButton
class_name CostumeButton

signal costume_picked();

@export var costume : Costume = null:
	set(value):
		costume = value;
		if (!is_node_ready()):
			await ready;
		update_costume();

func update_costume():
	if costume == null:
		return;
	%CostumeName.text = costume.name;
	
	var atlas_tex : AtlasTexture = AtlasTexture.new();
	atlas_tex.atlas = costume.texture;
	atlas_tex.region = costume.crop_rect;
	%CostumeImage.texture = atlas_tex;

func _ready():
	super._ready();
	
	text = "";

func _pressed():
	Costumes.current_costume = costume;
	costume_picked.emit();
