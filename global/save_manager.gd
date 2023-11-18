extends Node

signal about_to_save()
signal just_loaded()

const WAIT_BETWEEN_SIGNAL_AND_SAVE: int = 8

const DEFAULT_SAVE_DATA: Dictionary = {
	"player_data": {
		"position": Vector2(735, 504)
	}, 
	"tasks": {
		
	}
}
const DEFAULT_GLOBAL_DATA: Dictionary = {
	"slots": {
		"0": {"id": "0"}, 
		"1": {"id": "1"}, 
		"last_played_slot": "none"
	}, 
	"settings": {
		"keybinds": {}
	}
}

var save_data: Dictionary = DEFAULT_SAVE_DATA

var global_data: Dictionary = DEFAULT_GLOBAL_DATA


var global_data_save_path: String = "user://global_save.dat"

var save_dir: String = "user://saves/"
var file_name: String = "save_slot_0.societies"

var current_slot: int = 0 :
	set(new_value):
		current_slot = new_value
		
		file_name = "save_slot_" + str(new_value) + ".societies"


func _ready() -> void:
	global_data = await load_data(global_data_save_path, DEFAULT_GLOBAL_DATA)
	just_loaded.emit()


func save(path: String, data: Dictionary) -> void:
	verify_directory()
	
	about_to_save.emit()
	
	for frame in WAIT_BETWEEN_SIGNAL_AND_SAVE:
		await get_tree().process_frame
	
	var data_to_save = var_to_str(data)
	
	var file = FileAccess.open(path, FileAccess.WRITE)
	file.store_string(data_to_save)
	file.close()


func load_data(path: String, default: Dictionary = {}) -> Dictionary:
	if not FileAccess.file_exists(path):
		var file = FileAccess.open(path, FileAccess.WRITE)
		file.store_string(var_to_str(default))
		file.close()
	
	var file = FileAccess.open(path, FileAccess.READ)
	var raw_data = file.get_as_text()
	file.close()
	
	for i in WAIT_BETWEEN_SIGNAL_AND_SAVE:
		await get_tree().process_frame
	
	var compiled_data = str_to_var(raw_data)
	
	return compiled_data if compiled_data else {}


func get_value(path: String, default: Variant, from: Dictionary = save_data) -> Variant:
	var segements = path.split("/")
	var parent_section = from
	
	for i in segements:
		if typeof(parent_section) == TYPE_ARRAY and i in "1 2 3 4 5 6 7 8 9 0".split(" ") and int(i) < len(parent_section):
			if i == segements[-1]:
				return parent_section[int(i)]
			else:
				parent_section = parent_section[int(i)]
		elif i == segements[-1] and parent_section and parent_section.has(i):
			return parent_section[i]
		if parent_section.has(i):
			parent_section = parent_section[i]
		else:
			break
	
	return default


func verify_directory() -> void:
	DirAccess.make_dir_absolute(save_dir)


func _notification(what: int) -> void:
	match what:
		NOTIFICATION_WM_CLOSE_REQUEST:
			save(global_data_save_path, global_data)
			await get_tree().create_timer(0.1).timeout
			save(save_dir + file_name, save_data)
			await get_tree().create_timer(0.1).timeout
			get_tree().quit()
