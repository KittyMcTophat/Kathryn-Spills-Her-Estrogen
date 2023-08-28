extends Control
class_name Textbox

signal dialogue_finished();

@export var character_print_time : float = 0.033;

func start_dialogue(dialogue : Dialogue):
	show_string("");
	get_tree().paused = true;
	$AnimationPlayer.play("Show");
	
	await $AnimationPlayer.animation_finished;
	
	for s in dialogue.text_sequence:
		show_string(s);
		await %AdvanceButton.pressed;
		if visible_ratio_tween != null && visible_ratio_tween.is_running():
			visible_ratio_tween.custom_step(displayed_string_length * character_print_time);
			await %AdvanceButton.pressed;
	
	end_dialogue();

var visible_ratio_tween : Tween = null;
var displayed_string_length : int = -1;

func show_string(string : String):
	if visible_ratio_tween != null:
		visible_ratio_tween.kill();
	visible_ratio_tween = create_tween();
	
	%RichTextLabel.text = string;
	displayed_string_length = %RichTextLabel.get_parsed_text().length();
	
	%RichTextLabel.visible_ratio = 0.0;
	visible_ratio_tween.tween_property(%RichTextLabel, "visible_ratio",\
	1.0, displayed_string_length * character_print_time);

func end_dialogue():
	get_tree().paused = false;
	$AnimationPlayer.play("Hide");
	dialogue_finished.emit();
