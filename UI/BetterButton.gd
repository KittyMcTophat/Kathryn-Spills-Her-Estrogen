@tool
extends MarginContainer
class_name BetterButton

signal pressed;

@export_multiline var text : String = "":
	set(value):
		text = value;
		if (!is_node_ready()):
			await ready;
		%Label.text = text;
@export var auto_focus : bool = false;

func _ready():
	%Button.pressed.connect(func(): pressed.emit());
	%Button.pressed.connect(_pressed);
	
	theme_changed.connect(set_inner_margins);
	set_inner_margins();
	
	if Engine.is_editor_hint():
		return;
	
	if auto_focus:
		focus_button();

# Empty method to be overridden
func _pressed():
	return;

func focus_button():
	%Button.grab_focus();

func unfocus_button():
	%Button.release_focus();

func set_inner_margins():
	for side in ["top", "bottom", "left", "right"]:
		var margin : int = self.get_theme_constant("margin_" + side);
		$InnerMarginContainer.add_theme_constant_override("margin_" + side, -margin);
