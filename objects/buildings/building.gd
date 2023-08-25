extends Node2D

@export var interior: PackedScene

var can_enter: bool = false

@export var animation_player: AnimationPlayer


func _input(event: InputEvent) -> void:
	if can_enter and event.is_action_pressed("interact"):
		# TODO: Save game
		get_tree().change_scene_to_packed(interior)


func _on_doorway_body_entered(body: Node2D) -> void:
	animation_player.play("open_door")
	can_enter = true


func _on_doorway_body_exited(body: Node2D) -> void:
	animation_player.play_backwards("open_door")
	can_enter = false
