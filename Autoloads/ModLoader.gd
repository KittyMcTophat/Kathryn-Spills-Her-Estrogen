extends Node

var mods_folder_path : String = OS.get_executable_path().get_base_dir() + "/Mods"

func _ready():
	print("ModLoader: Loading mods...");
	load_resource_packs();
	load_costumes();
	load_levels();

func load_resource_packs():
	var resources_folder_path : String = mods_folder_path + "/Resources";
	
	print("ModLoader: Attempting to load resource packs from: " + resources_folder_path);
	if !DirAccess.dir_exists_absolute(resources_folder_path):
		print("ModLoader: Directory does not exist, resource packs not loaded");
		return;
	print("ModLoader: Directory Found");
	
	var resource_pack_directory : DirAccess = DirAccess.open(resources_folder_path);
	print("ModLoader: Contents: ", resource_pack_directory.get_files());
	for file in resource_pack_directory.get_files():
		if (file.get_extension().to_lower() == "zip" ||
			file.get_extension().to_lower() == "pck"):
			print("ModLoader: loading file ", file);
			ProjectSettings.load_resource_pack(resources_folder_path + "/" + file);
		else:
			print("ModLoader: ", file, " is not a zip or pck");

func load_costumes():
	var costumes_folder_path : String = mods_folder_path + "/Costumes";

	print("ModLoader: Attempting to load costumes from: ", costumes_folder_path);
	if !DirAccess.dir_exists_absolute(costumes_folder_path):
		print("ModLoader: Directory does not exist, costumes not loaded");
		return;
	print("ModLoader: Directory Found");

	var custom_costumes_dir : DirAccess = DirAccess.open(costumes_folder_path);
	print("ModLoader: Contents: ", custom_costumes_dir.get_files());
	for file in custom_costumes_dir.get_files():
		# Only loading the jsons right now
		if file.get_extension().to_lower() != "json":
			continue;
		print("\nModLoader: Loading json: ", file);
		
		var file_acess : FileAccess = FileAccess.open(costumes_folder_path + "/" + file, FileAccess.READ);
		if file_acess == null:
			print("ModLoader: Open file failed: ", file_acess.get_error());
			continue;
		print("ModLoader: contents of ", file, ": ", file_acess.get_as_text());
		
		var json_data = JSON.parse_string(file_acess.get_as_text());
		if json_data == null:
			print("ModLoader: Malformed JSON");
			continue;
		
		if json_data is Array:
			for item in json_data:
				if item is Dictionary:
					load_costume_from_dictionary(item, costumes_folder_path);
		else:
			if json_data is Dictionary:
				load_costume_from_dictionary(json_data, costumes_folder_path);

func load_costume_from_dictionary(dict : Dictionary, image_find_base_dir : String):
	print("ModLoader: Loading costume data: ", dict);
	var new_costume : Costume = Costume.new();
	
	if !dict.has("name"):
		print("ModLoader: \"name\" key not found, load failed");
		return;
	if !dict.name is String:
		print("ModLoader: \"name\" key corresponding value is not a string, load failed");
		return;
	new_costume.name = dict.name;
	
	if !dict.has("texture"):
		print("ModLoader: \"texture\" key not found, load failed");
		return;
	if !dict.texture is String:
		print("ModLoader: \"texture\" key corresponding value is not a string, load failed");
		return;
	var file_path : String = image_find_base_dir + "/" + dict.texture;
	if FileAccess.file_exists(file_path):
		var image : Image = Image.load_from_file(file_path);
		var texture : ImageTexture = ImageTexture.create_from_image(image);
		new_costume.texture = texture;
	else:
		print("ModLoader: ", file_path, " does not exist");
	
	if !dict.has("icon_crop_rect"):
		print("ModLoader: \"icon_crop_rect\" key not found, load failed");
		return;
	if !dict.icon_crop_rect is Array:
		print("ModLoader: \"icon_crop_rect\" key corresponding value is not an array, load failed");
		return;
	if dict.icon_crop_rect.size() != 4:
		print("ModLoader: \"icon_crop_rect\" array wrong size. Should be 4 elements. Load failed")
		return;
	for i in range(4):
		if dict.icon_crop_rect[i] < 0:
			print("ModLoader: \"icon_crop_rect\" array contains negative elements. Load failed");
			return;
	var arr : Array = dict.icon_crop_rect;
	var crop_rect : Rect2i = Rect2i(arr[0], arr[1], arr[2], arr[3]);
	new_costume.crop_rect = crop_rect;
	
	Costumes.custom_costumes.append(new_costume);

func load_levels():
	#TODO: Implement custom level loader
	return;
	var levels_folder_path : String = mods_folder_path + "/Levels";
	
	print("ModLoader: Attempting to load levels from: ");
	pass;
