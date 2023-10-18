extends Node2D

var id: int = -1

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera
@onready var camera_following_node: Node2D = player
@onready var tilemap: TileMap = $TileMap

@onready var pathfind_destinations: Node2D = $PathfindDestinations
@onready var npcs: Node2D = $NPCs


func _ready() -> void:
	for node in get_tree().get_nodes_in_group("can_focus_camera"):
		if node.has_signal("focus_camera"):
			node.focus_camera.connect(_on_focus_camera)
		if node.has_signal("unfocus_camera"):
			node.unfocus_camera.connect(_on_unfocus_camera)
	
	camera.position_smoothing_enabled = false
	camera.global_position = camera_following_node.global_position
	camera.position_smoothing_enabled = true
	
	SceneManager.activate.connect(_on_scene_activated)
	SceneManager.deactivate.connect(_on_scene_deactivated)
	
	#                                                              jump height   jump distance   height
	id = Pathfinder.initialize(tilemap, 1, PathfindEntityStats.new(4,            8,              2))


func _on_scene_activated(node: Node) -> void:
	if node != self:
		return
	camera.enabled = true

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
	
	if id != -1:
		var path = Pathfinder.find_path(id, npc.global_position, marker.global_position)
		if path:
			npc.pathfind(path)


func _on_focus_camera(node: Node2D) -> void:
	camera_following_node = node


func _on_unfocus_camera() -> void:
	camera_following_node = player


func _process(delta: float) -> void:
	camera.global_position = camera_following_node.global_position


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		pass
