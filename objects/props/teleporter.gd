extends Area2D

signal teleport(chunk_iid: String, new_player_position: Vector2)

var width: int = 0
var height: int = 0

var teleport_to: Dictionary = {}

@onready var shape: RectangleShape2D = $CollisionShape2D.shape


func _ready() -> void:
	$ReferenceRect.size = Vector2(width, height)
	shape.size = Vector2(width, height)
	$CollisionShape2D.position += shape.size / 2


func _on_body_entered(body: Node2D) -> void:
	if teleport_to == {}:
		return
	
	var chunk_to_teleport_to: Dictionary = Globals.chunks_data[teleport_to.levelIid]
	var entity_to_teleport_to: Dictionary = chunk_to_teleport_to.entities.teleporter[0]
	var entity_position = Vector2(
		entity_to_teleport_to.x + chunk_to_teleport_to.x, 
		entity_to_teleport_to.y + chunk_to_teleport_to.y
	)
	
	teleport.emit(teleport_to.levelIid, (body.global_position - self.global_position) + entity_position)
