@tool
class_name NPC
extends Area2D

signal focus_camera(node: Node2D)
signal unfocus_camera()

const DialogueBalloon = preload("res://objects/dialogue_balloon/balloon.tscn")

@export var dialogue_resource: DialogueResource
@export var dialogue_start_title: String = "start"
@export var texture: Texture2D :
	set(new_value):
		texture = new_value
		$Sprite2D.texture = texture

var can_interact: bool = false
var failsafe_dialogue: DialogueResource = preload("res://dialogue/error_no_file.dialogue")
var dialogue_balloon

@onready var canvas_layer: CanvasLayer = $CanvasLayer


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	$Sprite2D.texture = texture
	DialogueManager.dialogue_ended.connect(_dialogue_ended)


func _input(event: InputEvent) -> void:
	if Engine.is_editor_hint():
		return
	if can_interact and event.is_action_pressed("interact"):
		can_interact = false
		dialogue_balloon = DialogueBalloon.instantiate()
		add_child(dialogue_balloon)
		get_tree().paused = true
		focus_camera.emit(self)
		if dialogue_resource == null or dialogue_start_title == "":
			dialogue_balloon.start(failsafe_dialogue, "start")
		else:
			dialogue_balloon.start(dialogue_resource, dialogue_start_title)


func _dialogue_ended(resource: DialogueResource) -> void:
	if resource != dialogue_resource:
		return
	get_tree().paused = false
	unfocus_camera.emit()
	dialogue_balloon.queue_free()
	dialogue_balloon = null


func _on_body_entered(body: Node2D) -> void:
	can_interact = true


func _on_body_exited(body: Node2D) -> void:
	can_interact = false
