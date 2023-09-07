extends Node
class_name DialogueStarter

signal dialogue_started();
signal dialogue_finished();

@export var on_ready : bool = false;
@export var only_on_first_load : bool = true;
@export var dialogue : Dialogue = null;

static var shown_dialogue : Dictionary = {};

func _ready():
	if on_ready:
		if only_on_first_load:
			if shown_dialogue.has(dialogue.resource_path):
				return;
		await get_tree().physics_frame;
		start_dialogue();

func start_dialogue():
	Global.textbox.start_dialogue(dialogue);
	dialogue_started.emit();
	shown_dialogue[dialogue.resource_path] = null;
	await Global.textbox.dialogue_finished;
	dialogue_finished.emit();
