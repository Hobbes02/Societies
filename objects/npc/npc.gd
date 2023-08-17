extends Area2D

const DialogueBalloon = preload("res://objects/dialogue_balloon/balloon.tscn")

@export var dialogue_resource: DialogueResource
@export var dialogue_start_title: String

var can_interact: bool = false
var failsafe_dialogue: DialogueResource = preload("res://dialogue/error_no_file.dialogue")


func _input(event: InputEvent) -> void:
	if can_interact and event.is_action_pressed("interact"):
		can_interact = false
		var balloon = DialogueBalloon.instantiate()
		add_child(balloon)
		if dialogue_resource == null or dialogue_start_title == "":
			balloon.start(failsafe_dialogue, "start")
		else:
			balloon.start(dialogue_resource, dialogue_start_title)


func _on_body_entered(body: Node2D) -> void:
	can_interact = true


func _on_body_exited(body: Node2D) -> void:
	can_interact = false
