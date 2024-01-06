extends Node2D

@export var interior: String = ""

@export_group("New Building Settings")
@export var door_width: int = 8
@export var door_open_frame_length: float = 0.1

var can_enter: bool = false
var door_opening: bool = false
var door_closing: bool = false


@onready var door: Sprite2D = $CanvasGroup/Door
@onready var default_door_position: Vector2 = door.global_position
@onready var interactable: Area2D = $Doorway


func _ready() -> void:
	interactable.scene_data_to_pass["chunk_dir"] = interior


func _on_doorway_interacted() -> void:
	SaveManager.about_to_save.emit(SaveManager.SaveReason.CHANGE_SCENE)


func _on_doorway_entered() -> void:
	await open_door()


func _on_doorway_exited() -> void:
	await close_door()


func open_door() -> void:
	door_opening = true
	door_closing = false
	for frame in abs((default_door_position.x - door_width) - door.global_position.x):
		if (door_closing or not door_opening) or (door.global_position.x <= default_door_position.x - door_width):
			break
		door.global_position.x -= 1
		await get_tree().create_timer(door_open_frame_length).timeout
	door_opening = false


func close_door() -> void:
	door_closing = true
	door_opening = false
	for frame in abs(default_door_position.x - door.global_position.x):
		if (door_opening or not door_closing) or (door.global_position.x > default_door_position.x):
			break
		door.global_position.x += 1
		await get_tree().create_timer(door_open_frame_length).timeout
	door_closing = false

