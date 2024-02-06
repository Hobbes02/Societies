extends Area2D

signal teleport(chunk_iid: String, new_player_position: Vector2)

var width: int = 0
var height: int = 0

var teleport_to: Dictionary = {}

@onready var shape: RectangleShape2D = $CollisionShape2D.shape


func _ready() -> void:
	shape.size = Vector2(width, height)


func _on_body_entered(body: Node2D) -> void:
	print(teleport_to)
	if teleport_to == {}:
		return
	
	teleport.emit(teleport_to.levelIid, body.position)
