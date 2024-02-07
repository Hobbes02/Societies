extends Node2D

signal loaded()
signal teleport_player(new_position: Vector2)

const WORLD_DATA_DIR: String = "res://world/ldtk/societies/simplified/"
const Chunk: PackedScene = preload("res://world/chunk.tscn")

var iid_to_name: Dictionary = {}  # keys are chunk iids, values are chunk names

# keys are chunk iids, values are array of neighbors formatted as [iid, direction]
var chunk_neighbors: Dictionary = {}

var chunk_data: Dictionary = {}: # keys are chunk iids, values are chunk data
	set(new_value):
		chunk_data = new_value
		Globals.chunks_data = new_value

var loaded_chunk_iids: Array = []
var loaded_chunk_iid: String = ""

var loaded_chunk_nodes: Array[Node2D] = []

var current_chunk_iid: String


func _ready() -> void:
	compile_chunk_data()

	SaveManager.about_to_save.connect(_save)


func compute_parallax(camera_position: Vector2) -> void:
	for chunk in loaded_chunk_nodes:
		chunk.compute_parallax(camera_position)


func config() -> void:
	load_chunks_around(iid_to_name.find_key(SaveManager.save_data.get("scene_data", {}).get("current_chunk", "chunk_0")))
	await loaded


func _save(reason: SaveManager.SaveReason) -> void:
	SaveManager.save_data.scene_data = SaveManager.save_data.get("scene_data", SaveManager.DEFAULT_SAVE_DATA.scene_data)
	SaveManager.save_data.scene_data.current_chunk = iid_to_name.get(loaded_chunk_iid, "chunk_0")


func teleport_to_chunk(chunk_iid: String, new_player_position: Vector2) -> void:
	SceneManager.pause("game", true)
	load_chunks_around(chunk_iid)
	var current_chunk_position = Vector2(
		chunk_data[current_chunk_iid].x,
		chunk_data[current_chunk_iid].y
	)
	var new_chunk_position = Vector2(
		chunk_data[chunk_iid].x,
		chunk_data[chunk_iid].y
	)

	teleport_player.emit(new_player_position)
	SceneManager.pause("game", false)


func load_chunks_around(chunk_iid: String) -> void:
	current_chunk_iid = chunk_iid
	loaded_chunk_iid = chunk_iid
	var neighbors_to_load: Array = get_neighbors_to_load(chunk_iid)

	for chunk in loaded_chunk_iids:
		if chunk not in neighbors_to_load:
			remove_chunk(chunk)

	for neighbor in neighbors_to_load:
		if neighbor in loaded_chunk_iids:
			continue
		add_chunk(neighbor)

	loaded.emit()


func get_neighbors_to_load(chunk_iid: String) -> Array:
	var neighbors: Array = [chunk_iid]

	for neighbor in chunk_neighbors[chunk_iid]:
		if (iid_to_name.has(neighbor[0])) and (neighbor[0] not in neighbors):
			neighbors.append(neighbor[0])

	neighbors.sort_custom(
		func(a, b): 
			return int(iid_to_name[a][-2] + iid_to_name[a][-1]) > int(iid_to_name[b][-2] + iid_to_name[b][-1])
	)
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

	loaded_chunk_nodes.append(chunk)

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
			loaded_chunk_nodes.erase(chunk)
			chunk.queue_free()
			loaded_chunk_iids.erase(iid)


func compile_chunk_data() -> void:
	var chunk_dirs: Array = SaveManager.get_files_in_directory(WORLD_DATA_DIR)
	var new_chunk_data: Dictionary = {}

	for dir in chunk_dirs:
		if FileAccess.file_exists(WORLD_DATA_DIR + dir + "/data.json"):
			var file = FileAccess.open(WORLD_DATA_DIR + dir + "/data.json", FileAccess.READ)
			var data = str_to_var(file.get_as_text())
			file.close()

			if typeof(data) != TYPE_DICTIONARY:
				continue

			if data.has("uniqueIdentifer"):
				iid_to_name[data.uniqueIdentifer] = dir
				new_chunk_data[data.uniqueIdentifer] = data
			else:
				continue
			if data.has("neighbourLevels"):
				chunk_neighbors[data.uniqueIdentifer] = []
				for neighbor_level in data.neighbourLevels:
					var iid = neighbor_level.levelIid
					var direction = neighbor_level.dir

					if direction not in ["<", ">"]:
						chunk_neighbors[data.uniqueIdentifer].append([iid, direction])

	chunk_data = new_chunk_data.duplicate(true)
