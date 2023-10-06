@tool
class_name Interactable
extends Area2D

signal interacted()
signal focus_camera(node: Node2D)
signal ended()

const DialogueBalloon = preload("res://objects/dialogue_balloon/balloon.tscn")

enum INTERACTIONS {
	DIALOGUE = 0, 
	ANIMATION = 1, 
	SHOW_NODE = 2, 
	CHANGE_SCENE = 3, 
	NOTHING = 4
}

@export_enum("Dialogue:0", "Animation:1", "Show Node:2", "Change Scene:3", "Nothing:4") var interaction_type: int = 0
@export var pauses_game: bool = true

# Dialogue
@export_group("Dialogue")

@export var context_keys: Array[String] = ["times_interacted"]
@export var context_values: Array = [0]

@export var dialogue_file: DialogueResource
@export var title: String = "start"

@export var character_names: Array[String] = []
@export var character_nodes: Array[Node2D] = []

var can_interact: bool = false
var balloon: CanvasLayer
var context: Dictionary

# Animation
@export_group("Animation")
@export var animation_player: AnimationPlayer
@export var animation: String

@export var play_backwards: bool = false
@export var alternate_direction: bool = false

# Show Node
@export_group("Show Node")
@export var node: Node

# Change Scene
@export_group("Change Scene")
@export_file var scene_path: String


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	if interaction_type == INTERACTIONS.DIALOGUE:
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
		await get_tree().create_timer(0.2).timeout
		context = Utils.assemble_linked_lists(context_keys, context_values)


func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if event.is_action_pressed("interact") and can_interact:
		if pauses_game and interaction_type != INTERACTIONS.CHANGE_SCENE:
			get_tree().paused = true
		match interaction_type:
			INTERACTIONS.DIALOGUE:
				can_interact = false
				DialogueGlobals.context = context
				context.times_interacted += 1
				balloon = DialogueBalloon.instantiate()
				add_child(balloon)
				balloon.center_node.connect(_on_balloon_center_node)
				balloon.start(dialogue_file, title, Utils.assemble_linked_lists(character_names, character_nodes))
			INTERACTIONS.ANIMATION:
				if animation_player.has_animation(animation):
					if play_backwards:
						animation_player.play_backwards(animation)
					else:
						animation_player.play(animation)
					if alternate_direction:
						play_backwards = not play_backwards
				else:
					print("INVALID ANIMATION")
			INTERACTIONS.SHOW_NODE:
				node.show()
			INTERACTIONS.CHANGE_SCENE:
				get_tree().change_scene_to_file(scene_path)


func _on_dialogue_ended(resource: DialogueResource) -> void:
	if Engine.is_editor_hint():
		return
	if pauses_game:
		get_tree().paused = false
	ended.emit()
	balloon.queue_free()
	balloon = null
	await get_tree().create_timer(0.5).timeout
	can_interact = true


func _on_balloon_center_node(node: Node2D) -> void:
	if Engine.is_editor_hint():
		return
	focus_camera.emit(node)


func _on_body_entered(body: Node2D) -> void:
	if Engine.is_editor_hint():
		return
	can_interact = true


func _on_body_exited(body: Node2D) -> void:
	if Engine.is_editor_hint():
		return
	can_interact = false

