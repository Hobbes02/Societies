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
	TASK = 4, 
	NOTHING = 5
}

## Type of interaction. After choosing a type, change its settings in the sections below
@export_enum("Dialogue:0", "Animation:1", "Show Node:2", "Change Scene:3", "Task:4", "Nothing:5") var interaction_type: int = 0

## Controls whether the game is paused after interacting
@export var pauses_game: bool = false

# Dialogue
@export_group("Dialogue")

## Context is a set of special dialogue variables passed only when this specific Interactable runs
@export var context_keys: Array[String] = ["times_interacted"]
## Context is a set of special dialogue variables passed only when this specific Interactable runs
@export var context_values: Array = [0]

## DialogueResource file to run
@export var dialogue_file: DialogueResource

## Dialogue title to start on
@export var title: String = "start"

## Characters to center the camera on while speaking
@export var character_names: Array[String] = []
## Characters to center the camera on while speaking
@export var character_nodes: Array[Node2D] = []

var can_interact: bool = false
var balloon: CanvasLayer
var context: Dictionary

# Animation
@export_group("Animation")

## AnimationPlayer to play the animation through
@export var animation_player: AnimationPlayer

## Animation to play
@export var animation: String

## Whether the animation should play forwards or backwards
@export var play_backwards: bool = false

## If [code]true[/code], animation will switch direction every time it's interacted with.
@export var alternate_direction: bool = false

# Show Node
@export_group("Show Node")

## Node to show
@export var node: Node

# Change Scene
@export_group("Change Scene")

## Scene path to change to
@export_file var scene_path: String

# Complete Task
@export_group("Task")

## The name of the task to be completed
@export var task_name: String

## How to modify the task
@export_enum("Complete:0", "Assign:1", "Remove:2") var modify_type: int = 0


func _ready() -> void:
	if interaction_type == INTERACTIONS.DIALOGUE:
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
		await get_tree().create_timer(0.2).timeout
		context = Utils.assemble_linked_lists(context_keys, context_values)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact and not SceneManager.is_paused(self, 3):
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
			INTERACTIONS.TASK:
				match modify_type:
					0:  # Complete
						Tasks.complete_task(task_name)
					1:  # Assign
						Tasks.assign_task(task_name)
					2:  # Remove
						Tasks.remove_task(task_name)


func _on_dialogue_ended(resource: DialogueResource) -> void:
	if pauses_game:
		get_tree().paused = false
	ended.emit()
	balloon.queue_free()
	balloon = null
	await get_tree().create_timer(0.5).timeout
	if has_overlapping_bodies():
		can_interact = true


func _on_balloon_center_node(node: Node2D) -> void:
	focus_camera.emit(node)


func _on_body_entered(body: Node2D) -> void:
	can_interact = true


func _on_body_exited(body: Node2D) -> void:
	can_interact = false

