class_name Destination
extends Area2D


func _on_body_entered(body: Node2D) -> void:
	if body.has_method("arrive_at_destination"):
		body.arrive_at_destination()
