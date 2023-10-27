extends Node

signal about_to_save()

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


func save() -> void:
	verify_directory()
	
	about_to_save.emit()
	
	for frame in WAIT_BETWEEN_SIGNAL_AND_SAVE:
		await get_tree().process_frame
	
	var data_to_save = var_to_str(save_data)
	
	var file = FileAccess.open(save_dir + file_name, FileAccess.WRITE)
	file.store_string(data_to_save)
	file.close()


func load_data() -> Variant:
	if not FileAccess.file_exists(save_dir + file_name):
		return null
	
	var file = FileAccess.open(save_dir + file_name, FileAccess.READ)
	var raw_data = file.get_as_text()
	file.close()
	
	if "func " in raw_data:
		print("POSSIBLY MALICIOUS FILE!")
		return
	
	return str_to_var(raw_data)


func verify_directory() -> void:
	DirAccess.make_dir_absolute(save_dir)
