extends Node2D

signal loaded()

const WORLD_DATA_DIR: String = "res://world/ldtk/societies/simplified/"
const Chunk: PackedScene = preload("res://world/chunk.tscn")

var iid_to_name: Dictionary = {}  # keys are chunk iids, values are chunk names

# keys are chunk iids, values are array of neighbors formatted as [iid, direction]
var chunk_neighbors: Dictionary = {}

var chunk_data: Dictionary = {} # keys are chunk iids, values are chunk data

var loaded_chunk_iids: Array = []
var loaded_chunk_iid: String = ""


func _ready() -> void:
	compile_chunk_data()
	
	SaveManager.about_to_save.connect(_save)


func config() -> void:
	load_chunks_around(iid_to_name.find_key(SaveManager.save_data.get("scene_data", {}).get("current_chunk", "chunk_0")))
	await loaded


func _save(reason: SaveManager.SaveReason) -> void:
	SaveManager.save_data.scene_data = SaveManager.save_data.get("scene_data", SaveManager.DEFAULT_SAVE_DATA.scene_data)
	SaveManager.save_data.scene_data.current_chunk = iid_to_name.get(loaded_chunk_iid, "chunk_0")


func load_chunks_around(chunk_iid: String) -> void:
	loaded_chunk_iid = chunk_iid
	var neighbors_to_load: Array = get_neighbors_to_load(chunk_iid)
	
	for chunk in loaded_chunk_iids:
		if chunk not in neighbors_to_load:
			remove_chunk(chunk)
	
	for neighbor in neighbors_to_load:
		add_chunk(neighbor)
	
	loaded.emit()


func get_neighbors_to_load(chunk_iid: String) -> Array:
	var neighbors: Array = [chunk_iid]
	
	for neighbor in chunk_neighbors[chunk_iid]:
		if (iid_to_name.has(neighbor[0])) and (neighbor[0] not in neighbors):
			neighbors.append(neighbor[0])
	
	return neighbors


func add_chunk(iid: String) -> void:
	if iid in loaded_chunk_iids or not iid_to_name.has(iid) or not chunk_data.has(iid):
		return
	
	var chunk = Chunk.instantiate()
	chunk.chunk_dir = iid_to_name[iid]
	chunk.chunk_data = chunk_data[iid]
	loaded_chunk_iids.append(iid)
	chunk.name = iid
	call_deferred("add_child", chunk)
	
	chunk.player_entered.connect(func(chunk_name: String):
		if chunk_name in iid_to_name.values():
			load_chunks_around(iid_to_name.find_key(chunk_name))
			SceneManager.level_history.append(iid_to_name[iid])
	)


func remove_chunk(iid: String) -> void:
	if iid not in loaded_chunk_iids:
		return
	
	for chunk in get_children():
		if chunk.name == iid:
			chunk.queue_free()
			loaded_chunk_iids.erase(iid)


func compile_chunk_data() -> void:
	var chunk_dirs: Array = SaveManager.get_files_in_directory(WORLD_DATA_DIR)
	
	for dir in chunk_dirs:
		if FileAccess.file_exists(WORLD_DATA_DIR + dir + "/data.json"):
			var file = FileAccess.open(WORLD_DATA_DIR + dir + "/data.json", FileAccess.READ)
			var data = str_to_var(file.get_as_text())
			file.close()
			
			if typeof(data) != TYPE_DICTIONARY:
				continue
			
			if data.has("uniqueIdentifer"):
				iid_to_name[data.uniqueIdentifer] = dir
				chunk_data[data.uniqueIdentifer] = data
			else:
				continue
			if data.has("neighbourLevels"):
				chunk_neighbors[data.uniqueIdentifer] = []
				for neighbor_level in data.neighbourLevels:
					var iid = neighbor_level.levelIid
					var direction = neighbor_level.dir
					
					if direction not in ["<", ">"]:
						chunk_neighbors[data.uniqueIdentifer].append([iid, direction])
	
	var new_chunk_neighbors: Dictionary = {}
	for main_iid in chunk_neighbors.keys():
		var neighbors = chunk_neighbors[main_iid]
		var neighbors_to_add: Array = []
		new_chunk_neighbors[main_iid] = []
		
		for n in neighbors:
			new_chunk_neighbors[main_iid].append(n)
			if n[1] in ["e", "w"]:
				for o in chunk_neighbors[n[0]]:
					if o[1] in ["n", "s"]:
						new_chunk_neighbors[main_iid].append([o[0], o[1] + n[1]])
	chunk_neighbors = new_chunk_neighbors.duplicate(true)
