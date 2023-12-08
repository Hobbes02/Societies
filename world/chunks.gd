extends Node2D

const WORLD_DATA_DIR: String = "res://world/ldtk/societies/simplified/"
const Chunk: PackedScene = preload("res://world/chunk.tscn")

var iid_to_name: Dictionary = {}  # keys are chunk iids, values are chunk names

# keys are chunk iids, values are array of neighbors formatted as [iid, direction]
var chunk_neighbors: Dictionary = {}

var loaded_chunk_iids: Array = []


func _ready() -> void:
	compile_chunk_data()
	
	load_chunks_around(iid_to_name.find_key("chunk_2"))


func load_chunks_around(chunk_iid: String) -> void:
	var neighbors = chunk_neighbors[chunk_iid]
	add_chunk(chunk_iid)
	
	for neighbor in neighbors:
		var iid = neighbor[0]
		
		if not iid_to_name.has(iid):
			continue
		
		add_chunk(iid)


func add_chunk(iid: String) -> void:
	var chunk = Chunk.instantiate()
	chunk.chunk_dir = iid_to_name[iid]
	loaded_chunk_iids.append(iid)
	call_deferred("add_child", chunk)


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
			else:
				continue
			if data.has("neighbourLevels"):
				chunk_neighbors[data.uniqueIdentifer] = []
				for neighbor_level in data.neighbourLevels:
					var iid = neighbor_level.levelIid
					var direction = neighbor_level.dir
					
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
