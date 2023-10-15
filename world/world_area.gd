extends Node2D

var id: int = -1

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera
@onready var camera_following_node: Node2D = player
@onready var tilemap: TileMap = $TileMap

func _ready() -> void:
	for node in get_tree().get_nodes_in_group("can_focus_camera"):
		if node.has_signal("focus_camera"):
			node.focus_camera.connect(_on_focus_camera)
		if node.has_signal("unfocus_camera"):
			node.unfocus_camera.connect(_on_unfocus_camera)
	
	camera.position_smoothing_enabled = false
	camera.global_position = camera_following_node.global_position
	camera.position_smoothing_enabled = true
	
	#                                                              jump height   jump distance   height
	id = Pathfinder.initialize(tilemap, 1, PathfindEntityStats.new(4,            8,              2))


func _on_focus_camera(node: Node2D) -> void:
	camera_following_node = node


func _on_unfocus_camera() -> void:
	camera_following_node = player


func _process(delta: float) -> void:
	camera.global_position = camera_following_node.global_position


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("debug"):
		if id != -1:
			var path = Pathfinder.find_path(id, $NPCs/NPC.global_position, get_global_mouse_position())
			print(path)
			$NPCs/NPC.pathfind(path)
