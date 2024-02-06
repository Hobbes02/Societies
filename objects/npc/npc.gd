@tool
extends Node2D

signal focus_camera(node: Node2D)
signal unfocus_camera()

@export var npc_name: String = "Bobert"

@export var texture: Texture2D : 
	set(new_val):
		texture = new_val
		$Sprite2D.texture = new_val

@export var dialogue_resource: DialogueResource
@export var start_title: String = "start"

@export var character_names: Array[String] = []
@export var character_nodes: Array[Node2D] = []

@onready var interactable: Interactable = $Interactable


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	set_physics_process(false)
	interactable.dialogue_file = dialogue_resource
	interactable.title = start_title
	interactable.character_names = character_names
	interactable.character_nodes = character_nodes
	interactable.show()


func _on_interactable_focus_camera(node: Node2D) -> void:
	focus_camera.emit(node)


func _on_interactable_ended() -> void:
	unfocus_camera.emit()


func _on_physics_start_timer_timeout() -> void:
	set_physics_process(true)
