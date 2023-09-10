@tool
extends MarginContainer

signal costume_picked();

@export var costume_icon : Texture = null:
	set(value):
		costume_icon = value;
		update_texture_rect();
@export var costume_texture : Texture = null:
	set(value):
		costume_texture = value;
@export_multiline var costume_name : String = "Kathryn":
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
	
	%TextureRect.texture = costume_icon;

func _on_button_pressed():
	Global.costume = costume_texture;
	costume_picked.emit();
