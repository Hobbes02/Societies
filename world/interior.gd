class_name Interior
extends Chunk

var focus_after_unpause: Node2D

@onready var player: Player = $Player
@onready var camera: Camera2D = $Camera
@onready var camera_following_node: Variant = player


func _ready() -> void:
	print("INTERIOR LOADED AS ", chunk_dir)
	
	# load scene data
	if SceneManager.scene_history[-1] == "res://ui/menus/menus.tscn" and SaveManager.save_data.get("scene_data", SaveManager.DEFAULT_SAVE_DATA.scene_data).get("current_scene", SaveManager.DEFAULT_SAVE_DATA.scene_data.current_scene) == "world/interior":
		chunk_dir = SaveManager.save_data.get("scene_data", SaveManager.DEFAULT_SAVE_DATA.scene_data).get("other_scene_level", "chunk_0")
		player.global_position = SaveManager.save_data.get("player_data", {}).get("scene_position", player.global_position)
	
	SceneManager.level_history.append(chunk_dir)
	
	layer_visuals = $Visuals
	entity_container = $EntityContainer
	collider = $Collider
	collision_template = $Collider/CollisionTemplate
	
	if len(chunk_data) < 1:
		load_chunk_data()
	load_chunk_visual()
	load_chunk_collisions()
	place_entities()
	
	camera.position_smoothing_enabled = false
	camera.enabled = false
	
	# place the player at the correct door
	if chunk_data.has("entities") and chunk_data.entities.has("door") and len(chunk_data.entities.door) > 0:
		for door in chunk_data.entities.door:
			if ((door.get("customFields", {}).get("leads_to", null) == null)\
			and SceneManager.level_history[-2].begins_with("chunk")) or\
			(door.get("customFields", {}).get("leads_to", null) == \
			SceneManager.level_history[-2]):
				player.global_position = Vector2(
					door.x, 
					door.y + 6
				)
	
	for node in get_tree().get_nodes_in_group("can_focus_camera"):
		if node.has_signal("focus_camera"):
			node.focus_camera.connect(_on_focus_camera)
		if node.has_signal("unfocus_camera"):
			node.unfocus_camera.connect(_on_unfocus_camera)

	camera.global_position = camera_following_node.global_position
	camera.enabled = true
	camera.position_smoothing_enabled = true
	
	SceneManager.unpaused.connect(_on_unpaused)
	SaveManager.about_to_save.connect(_save)
	
	SceneManager.pause("player", false)
	SceneManager.pause("game", false)
	print("FINISHED LOADING AS ", chunk_dir)


func _on_unpaused(layer: String) -> void:
	if layer == "game" and focus_after_unpause != null:
		_on_focus_camera(focus_after_unpause)


func _save(reason: SaveManager.SaveReason) -> void:
	SaveManager.save_data.scene_data = SaveManager.save_data.get("scene_data", SaveManager.DEFAULT_SAVE_DATA.scene_data)
	SaveManager.save_data.scene_data.other_scene_level = chunk_dir


func _on_focus_camera(node: Node2D) -> void:
	if SceneManager.is_paused("game"):
		focus_after_unpause = node
		return
	
	camera_following_node = node


func _on_unfocus_camera() -> void:
	if SceneManager.is_paused("game"):
		focus_after_unpause = player
		return
	
	camera_following_node = player


func _process(delta: float) -> void:
	if camera_following_node != null:
		camera.global_position = camera_following_node.global_position
