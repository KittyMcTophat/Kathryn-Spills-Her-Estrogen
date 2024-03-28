extends Node

# Clean the string so that it doesn't look weird and waste space in the console
func clean_string(string : String) -> String:
	return string.replace("\n", "\\n");

func print_info(info : String):
	print_rich("[color=lightblue][INFO] " + clean_string(info) + "[/color]");

func print_warn(warning : String):
	print_rich("[color=yellow][WARN] " + clean_string(warning) + "[/color]");

func print_error(error : String):
	printerr("[ERROR] " + clean_string(error));
