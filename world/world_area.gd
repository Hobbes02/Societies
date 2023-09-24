extends Node2D

@onready var player: CharacterBody2D = $Player
@onready var camera: Camera2D = $Camera
@onready var camera_following_node: Node2D = player


func _ready() -> void:
	for node in get_tree().get_nodes_in_group("can_focus_camera"):
		if node.has_signal("focus_camera"):
			node.focus_camera.connect(_on_focus_camera)
		if node.has_signal("unfocus_camera"):
			node.unfocus_camera.connect(_on_unfocus_camera)


func _on_focus_camera(node: Node2D) -> void:
	camera_following_node = node


func _on_unfocus_camera() -> void:
	camera_following_node = player


func _process(delta: float) -> void:
	camera.global_position = camera_following_node.global_position
