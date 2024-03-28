extends Node

var mods_folder_path : String = OS.get_executable_path().get_base_dir() + "/Mods"

func _ready():
	Log.print_info("ModLoader: Loading mods...");
	load_resource_packs();
	load_costumes();
	load_levels();

func load_resource_packs():
	var resources_folder_path : String = mods_folder_path + "/Resources";
	
	Log.print_info("ModLoader: Attempting to load resource packs from: " + resources_folder_path);
	if !DirAccess.dir_exists_absolute(resources_folder_path):
		Log.print_warn("ModLoader: Directory does not exist, resource packs not loaded");
		return;
	Log.print_info("ModLoader: Directory Found");
	
	var resource_pack_directory : DirAccess = DirAccess.open(resources_folder_path);
	Log.print_info("ModLoader: Contents: " + str(resource_pack_directory.get_files()));
	for file in resource_pack_directory.get_files():
		if (file.get_extension().to_lower() == "zip" ||
			file.get_extension().to_lower() == "pck"):
			Log.print_info("ModLoader: loading file " + file);
			ProjectSettings.load_resource_pack(resources_folder_path + "/" + file);
		else:
			Log.print_error("ModLoader: " + file + " is not a zip or pck");

func load_costumes():
	var costumes_folder_path : String = mods_folder_path + "/Costumes";

	Log.print_info("ModLoader: Attempting to load costumes from: " + costumes_folder_path);
	if !DirAccess.dir_exists_absolute(costumes_folder_path):
		Log.print_warn("ModLoader: Directory does not exist, costumes not loaded");
		return;
	Log.print_info("ModLoader: Directory Found");

	var custom_costumes_dir : DirAccess = DirAccess.open(costumes_folder_path);
	Log.print_info("ModLoader: Contents: " + str(custom_costumes_dir.get_files()));
	for file in custom_costumes_dir.get_files():
		# Only loading the jsons right now
		if file.get_extension().to_lower() != "json":
			continue;
		Log.print_info("ModLoader: Loading json: " + file);
		
		var file_acess : FileAccess = FileAccess.open(costumes_folder_path + "/" + file, FileAccess.READ);
		if file_acess == null:
			Log.print_error("ModLoader: Open file failed: " + str(file_acess.get_error()));
			continue;
		Log.print_info("ModLoader: contents of " + file + ": " + file_acess.get_as_text());
		
		var json_data = JSON.parse_string(file_acess.get_as_text());
		if json_data == null:
			Log.print_error("ModLoader: Malformed JSON");
			continue;
		
		if json_data is Array:
			for item in json_data:
				if item is Dictionary:
					load_costume_from_dictionary(item, costumes_folder_path);
		else:
			if json_data is Dictionary:
				load_costume_from_dictionary(json_data, costumes_folder_path);

func load_costume_from_dictionary(dict : Dictionary, image_find_base_dir : String):
	Log.print_info("ModLoader: Loading costume data: " + str(dict));
	var new_costume : Costume = Costume.new();
	
	if !dict.has("name"):
		Log.print_error("ModLoader: \"name\" key not found, load failed");
		return;
	if !dict.name is String:
		Log.print_error("ModLoader: \"name\" key corresponding value is not a string, load failed");
		return;
	new_costume.name = dict.name;
	
	if !dict.has("texture"):
		Log.print_error("ModLoader: \"texture\" key not found, load failed");
		return;
	if !dict.texture is String:
		Log.print_error("ModLoader: \"texture\" key corresponding value is not a string, load failed");
		return;
	var file_path : String = image_find_base_dir + "/" + dict.texture;
	if FileAccess.file_exists(file_path):
		var image : Image = Image.load_from_file(file_path);
		var texture : ImageTexture = ImageTexture.create_from_image(image);
		new_costume.texture = texture;
	else:
		Log.print_error("ModLoader: " + file_path + " does not exist");
	
	if !dict.has("icon_crop_rect"):
		Log.print_error("ModLoader: \"icon_crop_rect\" key not found, load failed");
		return;
	if !dict.icon_crop_rect is Array:
		Log.print_error("ModLoader: \"icon_crop_rect\" key corresponding value is not an array, load failed");
		return;
	if dict.icon_crop_rect.size() != 4:
		Log.print_error("ModLoader: \"icon_crop_rect\" array wrong size. Should be 4 elements. Load failed")
		return;
	for i in range(4):
		if dict.icon_crop_rect[i] < 0:
			Log.print_error("ModLoader: \"icon_crop_rect\" array contains negative elements. Load failed");
			return;
	var arr : Array = dict.icon_crop_rect;
	var crop_rect : Rect2i = Rect2i(arr[0], arr[1], arr[2], arr[3]);
	new_costume.crop_rect = crop_rect;
	
	Costumes.custom_costumes.append(new_costume);

func load_levels():
	var levels_folder_path : String = mods_folder_path + "/Levels";
	
	Log.print_info("ModLoader: Attempting to load custom levels from: " + levels_folder_path);
	if !DirAccess.dir_exists_absolute(mods_folder_path):
		Log.print_warn("ModLoader: Directory does not exist, custom levels not loaded");
		return;
	Log.print_info("ModLoader: Directory Found");
	
	var custom_levels_dir : DirAccess = DirAccess.open(levels_folder_path);
	Log.print_info("ModLoader: Contents: " + str(custom_levels_dir.get_files()));
	for file in custom_levels_dir.get_files():
		if (file.get_extension().to_lower() != "json"):
			continue;
		Log.print_info("ModLoader: Loading json: " + file);
		
		load_levels_from_file(file, levels_folder_path);

func load_levels_from_file(file : String, base_dir : String):
	var file_acess : FileAccess = FileAccess.open(base_dir + "/" + file, FileAccess.READ);
	if file_acess == null:
		Log.print_error("ModLoader: Open file failed: " + str(file_acess.get_error()));
		return;
	Log.print_info("ModLoader: contents of " + file + ": " + file_acess.get_as_text());
	
	var json_data = JSON.parse_string(file_acess.get_as_text());
	if json_data == null:
		Log.print_error("ModLoader: Malformed JSON");
		return;
	
	if (json_data is Dictionary):
		load_level_from_dictionary(json_data, base_dir);
		return;
	
	if (json_data is Array):
		for item in json_data:
			if (item is Dictionary):
				load_level_from_dictionary(item, base_dir);
			else:
				Log.print_error("ModLoader: Invalid Item in " + file + ": " + str(item));
		return;
	
	Log.print_error("ModLoader: Invalid data type in " + file + ": Must be an Array or a Dictionary");

func load_level_from_dictionary(dict : Dictionary, base_dir : String):
	Log.print_info("ModLoader: Loading level data: " + str(dict));
	
	if !dict.has("scene_path"):
		Log.print_error("ModLoader: \"scene_path\" key not found, load failed");
		return;
	if !dict.scene_path is String:
		Log.print_error("ModLoader: \"scene_path\" key corresponding value is not a string, load failed");
		return;
	var scene_path_full : String = base_dir + "/" + dict.scene_path;
	if !FileAccess.file_exists(scene_path_full):
		Log.print_error("ModLoader: file " + dict.scene_path + " does not exist, load failed");
		return;
	
	Levels.levels.append(scene_path_full);
	
	if !dict.has("level_name"):
		Log.print_warn("ModLoader: \"level_name\" key not found. The level can be played, but it will be displayed using its file name.");
		return;
	if !dict.level_name is String:
		Log.print_warn("ModLoader: \"level_name\" key corresponding value is not a string, name will not be set");
		return;

	Levels.level_names[scene_path_full] = dict.level_name;
