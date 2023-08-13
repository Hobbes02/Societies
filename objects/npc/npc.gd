extends Area2D

const DialogueBalloon = preload("res://objects/dialogue_balloon/balloon.tscn")

@export var dialogue_resource: DialogueResource
@export var dialogue_start_title: String

var can_interact: bool = false


func _input(event: InputEvent) -> void:
	if can_interact and event.is_action_pressed("interact"):
		can_interact = false
		var balloon = DialogueBalloon.instantiate()
		add_child(balloon)
		balloon.start(dialogue_resource, dialogue_start_title)
		
		var args: Array = [0]
		while args[0] != dialogue_resource:
			args = await DialogueManager.dialogue_ended
		can_interact = true


func _on_body_entered(body: Node2D) -> void:
	can_interact = true


func _on_body_exited(body: Node2D) -> void:
	can_interact = false
