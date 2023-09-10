extends TabContainer

func _ready():
	tab_changed.connect(focus_first_in_current_tab.unbind(1));

func change_tab(value : int):
	current_tab = clampi(value, 0, get_tab_count() - 1);

func _process(_delta):
	if Input.is_action_just_pressed("move_tab_left"):
		change_tab(current_tab - 1);
	elif Input.is_action_just_pressed("move_tab_right"):
		change_tab(current_tab + 1);

func focus_first_in_current_tab():
	await get_tree().process_frame;
	var focusable_child : Control = find_next_valid_focus();
	if focusable_child != null:
		focusable_child.grab_focus();
