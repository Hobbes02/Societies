extends Area2D

var width: int = 0
var height: int = 0

@onready var collision_shape: CollisionShape2D = $CollisionShape2D
@onready var collision_rectangle_shape: RectangleShape2D = collision_shape.shape
@onready var texture: NinePatchRect = $Texture


func _ready() -> void:
	collision_rectangle_shape.size = Vector2(width, height)
	collision_shape.global_position += Vector2(width / 2, height / 2)
	texture.size = Vector2(width, height)



func _on_body_entered(body: Node2D) -> void:
	if body is Player:
		body.is_touching_ladder = true
		print("->")


func _on_body_exited(body: Node2D) -> void:
	if body is Player:
		print("<-")
		body.is_touching_ladder = false
		body.current_move_state = body.MoveStates.Walk
