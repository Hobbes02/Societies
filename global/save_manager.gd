extends Node

signal about_to_save()
signal just_loaded()

const WAIT_BETWEEN_SIGNAL_AND_SAVE: int = 4

var save_data: Dictionary = {
	"player_data": {
		"position": Vector2(0, 0)
	}, 
	"tasks": {
		
	}, 
	"settings": {
		
	}
}

var save_dir: String = "user://saves/"
var file_name: String = "save_data.dat"


func _ready() -> void:
	load_data()


func save() -> void:
	verify_directory()
	
	about_to_save.emit()
	
	for frame in WAIT_BETWEEN_SIGNAL_AND_SAVE:
		await get_tree().process_frame
	
	var data_to_save = var_to_str(save_data)
	
	var file = FileAccess.open(save_dir + file_name, FileAccess.WRITE)
	file.store_string(data_to_save)
	file.close()


func load_data():
	if not FileAccess.file_exists(save_dir + file_name):
		return
	
	var file = FileAccess.open(save_dir + file_name, FileAccess.READ)
	var raw_data = file.get_as_text()
	file.close()
	
	if "func " in raw_data:
		print("POSSIBLY MALICIOUS FILE!")
		return
	
	save_data = str_to_var(raw_data)
	
	for i in WAIT_BETWEEN_SIGNAL_AND_SAVE:
		await get_tree().process_frame
	
	just_loaded.emit()


func get_value(path: String, default: Variant) -> Variant:
	var segements = path.split("/")
	var parent_section = save_data
	
	for i in segements:
		if i == segements[-1] and parent_section and parent_section.has(i):
			return parent_section[i]
		if parent_section.has(i):
			parent_section = parent_section[i]
		else:
			break
	
	return default


func verify_directory() -> void:
	DirAccess.make_dir_absolute(save_dir)
