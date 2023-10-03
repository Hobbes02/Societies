class_name Interactable
extends Area2D

signal interacted()
signal focus_camera(node: Node2D)
signal ended()

const DialogueBalloon = preload("res://objects/dialogue_balloon/balloon.tscn")

## Controls whether the game is paused when interacted with
@export var pauses_game: bool = true

## Custom dialogue variables unique to each node, even if they share a file
@export var context_keys: Array[String] = []
@export var context_values: Array = []

## DialogueResource to play when interacted
@export var dialogue_file: DialogueResource
## Dialogue title to start at
@export var title: String = ""

## Characters to center the camera on
@export var character_names: Array[String] = []
@export var character_nodes: Array[Node2D] = []

var can_interact: bool = false
var balloon


func _ready() -> void:
	DialogueManager.dialogue_ended.connect(_on_dialogue_ended)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact:
		can_interact = false
		DialogueGlobals.context = Utils.assemble_linked_lists(context_keys, context_values)
		balloon = DialogueBalloon.instantiate()
		add_child(balloon)
		balloon.center_node.connect(_on_balloon_center_node)
		balloon.start(dialogue_file, title, Utils.assemble_linked_lists(character_names, character_nodes))
		if pauses_game:
			get_tree().paused = true


func _on_dialogue_ended(resource: DialogueResource) -> void:
	if pauses_game:
		get_tree().paused = false
	ended.emit()
	balloon.queue_free()
	balloon = null
	await get_tree().create_timer(0.5).timeout
	can_interact = true


func _on_balloon_center_node(node: Node2D) -> void:
	focus_camera.emit(node)


func _on_body_entered(body: Node2D) -> void:
	can_interact = true


func _on_body_exited(body: Node2D) -> void:
	can_interact = false
