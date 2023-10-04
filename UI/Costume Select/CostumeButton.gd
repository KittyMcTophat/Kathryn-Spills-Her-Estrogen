@tool
extends MarginContainer
class_name CostumeButton

signal costume_picked();

@export var costume : Costume = null:
	set(value):
		costume = value;
		update_costume();

func update_costume():
	if costume == null:
		return;
	%Label.text = costume.name;
	
	var atlas_tex : AtlasTexture = AtlasTexture.new();
	atlas_tex.atlas = costume.texture;
	atlas_tex.region = costume.crop_rect;
	%TextureRect.texture = atlas_tex;

func focus():
	%Button.grab_focus();

func _on_button_pressed():
	Costumes.current_costume = costume;
	costume_picked.emit();
