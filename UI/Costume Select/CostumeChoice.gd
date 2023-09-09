@tool
extends MarginContainer

signal costume_picked();

@export var costume_id : int = 0:
	set(value):
		costume_id = value;
		update_texture_rect();
@export var costume_name : String = "Kathryn":
	set(value):
		costume_name = value;
		update_label();
@export var start_focused : bool = false;

func _ready():
	if start_focused:
		%Button.grab_focus();

func update_label():
	if !has_node("%Label"):
		await ready;
	%Label.text = costume_name;

func update_texture_rect():
	if !has_node("%TextureRect"):
		await ready;
	var new_tex : AtlasTexture = AtlasTexture.new();
	new_tex.atlas = load("res://Characters/Kathryn/Costumes/costume" + str(costume_id) + ".png");
	new_tex.region.size.x = new_tex.atlas.get_size().x;
	new_tex.region.size.y = new_tex.atlas.get_size().y / 4;
	
	%TextureRect.texture = new_tex;

func _on_button_pressed():
	Global.costume = costume_id;
	costume_picked.emit();
