extends Node

signal about_to_save(reason: SaveReason)

enum SaveReason {
	UNKNOWN, 
	PAUSE, 
	QUIT, 
	CHANGE_SCENE
}

var DEFAULT_SAVE_DATA: Dictionary = {
	"slot_data": {
		"name": "Slot 1", 
		"area": "Start", 
		"progress": 0
	}, 
	"scene_data": {
		"current_scene": "world/world"
	}, 
	"player_data": {
		"world_position": Vector2(0, 0), 
		"scene_position": Vector2(0, 0), 
	}, 
	"tasks": {
		"completed_tasks": [], 
		"active_tasks": []
	}
}

var DEFAULT_SETTINGS_DATA: Dictionary = {
	"keybinds": {}, 
	"sound": {  # sound in dB
		"main": 0, 
		"sfx": 0, 
		"music": 0
	}, 
	"last_played_slot": -1
}

var slots: Array = []

var save_data: Dictionary = DEFAULT_SAVE_DATA.duplicate(true)
var settings_data: Dictionary = DEFAULT_SETTINGS_DATA.duplicate(true)

var current_save_slot: int = 0


func _ready() -> void:
	load_slot_data()
	load_settings_data()


func load_slot_data() -> void:
	var slot_files: Array[String] = get_files_in_directory("user://saves")
	
	for slot_file in slot_files:
		if not slot_file.ends_with(".societies"):
			continue
		var slot_data: Dictionary = get_data_as_dictionary("user://saves/" + slot_file).get("slot_data", {})
		slots.append({
			"name": slot_data.get("name", "Empty Slot"), 
			"area": slot_data.get("area", "Start"), 
			"progress": slot_data.get("progress", 0)
		})


func save_slot_data(slot_data: Dictionary, slot: int) -> void:
	if not (slot_data.has("name") and slot_data.has("area") and slot_data.has("progress")):
		return
	
	if slot < len(slots):
		slots[slot] = slot_data
	
	var slot_file_data: Dictionary = get_data_as_dictionary("user://saves/slot_" + str(slot) + ".societies")
	slot_file_data["slot_data"] = slot_data
	
	var file = FileAccess.open("user://saves/slot_" + str(slot) + ".societies", FileAccess.WRITE)
	file.store_string(var_to_str(slot_file_data))
	file.close()
	
	load_slot_data()


func save_game_data() -> void:
	var data_to_save: String = var_to_str(save_data)
	
	var file = FileAccess.open("user://saves/slot_" + str(current_save_slot) + ".societies", FileAccess.WRITE)
	file.store_string(data_to_save)
	file.close()


func load_game_data() -> void:
	save_data = get_data_as_dictionary("user://saves/slot_" + str(current_save_slot) + ".societies")


func save_settings_data() -> void:
	var data_to_save: String = var_to_str(settings_data)
	
	var file = FileAccess.open("user://settings.dat", FileAccess.WRITE)
	file.store_string(data_to_save)
	file.close()


func load_settings_data() -> void:
	settings_data = get_data_as_dictionary("user://settings.dat")


func get_data_as_dictionary(file_path: String) -> Dictionary:
	if not FileAccess.file_exists(file_path):
		return {}
	
	var file = FileAccess.open(file_path, FileAccess.READ)
	var data_as_string: String = file.get_as_text()
	file.close()
	return str_to_var(data_as_string)


func get_files_in_directory(path: String) -> Array[String]:
	var files: Array[String] = []
	var dir = DirAccess.open(path)
	dir.include_hidden = false
	dir.include_navigational = false
	dir.list_dir_begin()

	var file = dir.get_next()
	while file != "":
		files += [file]
		file = dir.get_next()

	return files


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			about_to_save.emit(SaveReason.QUIT)
			
			if SceneManager.active_scene != "Scenes/Menus":
				save_game_data()
			save_settings_data()
			
			get_tree().quit()
