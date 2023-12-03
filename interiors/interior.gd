extends Node2D

@export var door_width: int = 8
@export var door_open_frame_length: float = 0.1

var door_opening: bool = false
var door_closing: bool = false

@onready var door: Sprite2D = $Door/CanvasGroup/Door
@onready var default_door_position: Vector2 = door.global_position
@onready var player: CharacterBody2D = $Player


func _ready() -> void:
	SceneManager.activate.connect(_on_scene_activated)
	
	var player_position: Vector2 = SaveManager.save_data.get("player_data", {}).get("scene_position", Vector2(0, 0))
	if player_position != Vector2(0, 0) and SaveManager.save_data.get("scene_data", {}).get("current_scene", "world/world") == get_node(".").scene_file_path.lstrip("res://").rstrip(".tscn"):
		player.global_position = player_position


func _on_scene_activated(node: Node) -> void:
	if node != self:
		return
	SceneManager.pause("game", false)


func _on_door_interactable_entered() -> void:
	open_door()


func _on_door_interactable_exited() -> void:
	close_door()


func open_door() -> void:
	door_opening = true
	door_closing = false
	for frame in abs((default_door_position.x - door_width) - door.global_position.x):
		if door_closing or not door_opening:
			break
		door.global_position.x -= 1
		await get_tree().create_timer(door_open_frame_length).timeout
	door_opening = false


func close_door() -> void:
	door_closing = true
	door_opening = false
	for frame in abs(default_door_position.x - door.global_position.x):
		if door_opening or not door_closing:
			break
		door.global_position.x += 1
		await get_tree().create_timer(door_open_frame_length).timeout
	door_closing = false
