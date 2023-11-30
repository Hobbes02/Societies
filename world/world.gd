extends Node2D

var graph_id: int = -1

var focus_after_unpause: Node2D

@onready var player: CharacterBody2D = $PlayerW
@onready var camera: Camera2D = $Camera
@onready var camera_following_node: Variant = player
@onready var tilemap: TileMap = $TileMap

@onready var pathfind_destinations: Node2D = $PathfindDestinations
@onready var npcs: Node2D = $NPCs


func _ready() -> void:
	for node in get_tree().get_nodes_in_group("can_focus_camera"):
		if node.has_signal("focus_camera"):
			node.focus_camera.connect(_on_focus_camera)
		if node.has_signal("unfocus_camera"):
			node.unfocus_camera.connect(_on_unfocus_camera)
	
	SceneManager.activate.connect(_on_scene_activated)
	SceneManager.deactivate.connect(_on_scene_deactivated)
	SceneManager.unpaused.connect(_on_unpaused)
	
	SaveManager.about_to_save.connect(_save)
	
	#                                                              jump height   jump distance   height
	graph_id = Pathfinder.initialize(tilemap, 1, PathfindEntityStats.new(4,            8,              2))


func _save(layer: String) -> void:
	if visible:
		SaveManager.save_data.player_data.world_position = player.global_position
		SaveManager.save_data.player_data.scene_position = player.global_position


func _on_unpaused(layer: String) -> void:
	if layer == "game" and focus_after_unpause != null:
		_on_focus_camera(focus_after_unpause)


func _on_scene_activated(node: Node) -> void:
	if node != self:
		return
	print("AAA")
	camera.position_smoothing_enabled = false
	camera.global_position = camera_following_node.global_position
	camera.enabled = true
	camera.position_smoothing_enabled = true
	SceneManager.pause("game", false)
	SaveManager.just_loaded.emit("world")
	
	player.global_position = SaveManager.get_value("player_data/world_position", player.global_position)


func _on_scene_deactivated(node: Node) -> void:
	if node != self:
		return
	camera.enabled = false


func npc_go(npc_name: String, destination: String) -> void:
	var marker: Marker2D
	var npc: CharacterBody2D
	
	for d in pathfind_destinations.get_children():
		if d.name == destination:
			marker = d
			break
	
	for n in npcs.get_children():
		if n.npc_name == npc_name:
			npc = n
			break
	
	if graph_id != -1:
		var path = Pathfinder.find_path(graph_id, npc.global_position, marker.global_position)
		if path:
			npc.pathfind(path)


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


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		print(player.anim_player.current_animation)
