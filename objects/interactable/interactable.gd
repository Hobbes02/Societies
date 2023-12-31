class_name Interactable
extends Area2D

## Emitted when the interact key is pressed and the action is started
signal interacted()
## Emmitted when a node enters the interaction area
signal entered()
## Emmited when a node exits the interaction area
signal exited()
## Emmited when a dialogue balloon requests a node to be focused
signal focus_camera(node: Node2D)
## Emitted when the dialogue finishes
signal ended()

enum INTERACTIONS {
	DIALOGUE = 0, ## Triggers dialogue using a Dialogue Balloon. Write the dialogue in the "Dialogue" top panel
	ANIMATION = 1, ## Triggers any animation in any AnimationPlayer node
	SHOW_NODE = 2, ## Shows node on interact
	CHANGE_SCENE = 3, ## Changes the scene. If using Change Scene, Pauses Game has no effect
	TASK = 4, ## Changes the status of a task
	NOTHING = 5 ## Does nothing. Meant to be handled through custom code
}

## Type of interaction. After choosing a type, change its settings in the sections below
@export var interaction_type: INTERACTIONS = INTERACTIONS.DIALOGUE

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
@export_group("Change Scene", "scene_")

## Scene path to change to
@export_file var scene_path: String

## Data to pass to the root node of the scene we're changing to
@export var scene_data_to_pass: Dictionary = {}

## If true, passes the data before adding the scene, otherwise, passes after the scene is ready
@export var scene_pass_data_before_instatiate: bool = false

# Complete Task
@export_group("Task")

## The name of the task to be completed
@export var task_name: String

## How to modify the task
@export_enum("Complete:0", "Assign:1", "Remove:2") var modify_type: int = 0

var trigger_body: Node

@onready var balloon: CanvasLayer = $Balloon


func _ready() -> void:
	if interaction_type == INTERACTIONS.DIALOGUE:
		DialogueManager.dialogue_ended.connect(_on_dialogue_ended)
		await get_tree().create_timer(0.2).timeout
		context = Utils.assemble_linked_lists(context_keys, context_values)


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("interact") and can_interact and not SceneManager.is_paused("interaction", ["game"]):
		interacted.emit()
		match interaction_type:
			INTERACTIONS.DIALOGUE:
				can_interact = false
				DialogueGlobals.context = context
				context.times_interacted += 1
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
				SceneManager.change_scene(scene_path, true, true, null, scene_data_to_pass, scene_pass_data_before_instatiate)
			INTERACTIONS.TASK:
				match modify_type:
					0:  # Complete
						Tasks.complete_task(task_name)
					1:  # Assign
						Tasks.assign_task(task_name)
					2:  # Remove
						Tasks.remove_task(task_name)
		if pauses_game and interaction_type != INTERACTIONS.CHANGE_SCENE:
			SceneManager.pause("player", true)


func _on_dialogue_ended(resource: DialogueResource) -> void:
	if pauses_game:
		SceneManager.pause("player", false)
	ended.emit()
	await get_tree().create_timer(0.5).timeout
	if has_overlapping_bodies():
		can_interact = true


func _on_balloon_center_node(node: Node2D) -> void:
	focus_camera.emit(node)


func _on_body_entered(body: Node2D) -> void:
	trigger_body = body
	entered.emit()
	can_interact = true


func _on_body_exited(body: Node2D) -> void:
	exited.emit()
	can_interact = false

