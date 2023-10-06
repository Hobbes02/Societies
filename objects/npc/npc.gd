@tool
extends CharacterBody2D

signal focus_camera(node: Node2D)
signal unfocus_camera()

@export var texture: Texture2D : 
	set(new_val):
		texture = new_val
		$Sprite2D.texture = new_val

@export var dialogue_resource: DialogueResource
@export var start_title: String = "start"

@export var character_names: Array[String] = []
@export var character_nodes: Array[Node2D] = []

@export var speed: float = 100.0
@export var jump_velocity: float = -900.0

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

var pathfind_destination: Destination
var is_jumping: bool = false

@onready var rays: Dictionary = {
	"left_jump": $Rays/LeftJump, 
	"left_feet": $Rays/LeftFeet, 
	"left_head": $Rays/LeftHead, 
	"right_jump": $Rays/RightJump, 
	"right_feet": $Rays/RightFeet, 
	"right_head": $Rays/RightHead, 
	"jump": $Rays/JumpDetector
}
@onready var interactable: Interactable = $Interactable


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	set_physics_process(false)
	interactable.dialogue_file = dialogue_resource
	interactable.title = start_title
	interactable.character_names = character_names
	interactable.character_nodes = character_nodes
	$Rays.show()
	interactable.show()


func _on_interactable_focus_camera(node: Node2D) -> void:
	focus_camera.emit(node)


func _on_interactable_ended() -> void:
	unfocus_camera.emit()


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint():
		return
	
	if not is_on_floor():
		velocity.y += gravity * delta
	
	if pathfind_destination.global_position.x > global_position.x:  # to the right
		velocity.x = speed
	elif pathfind_destination.global_position.x < global_position.x:  # to the left
		velocity.x = -speed
	if not is_jumping:
		if velocity.x > 1 and (rays.right_feet.is_colliding() or rays.right_head.is_colliding()) and (not rays.right_jump.is_colliding()) and (not rays.jump.is_colliding()):
			velocity.y = jump_velocity
			is_jumping = true
		elif velocity.x < 1 and (rays.left_feet.is_colliding() or rays.left_head.is_colliding()) and (not rays.right_jump.is_colliding()) and (not rays.jump.is_colliding()):
			velocity.y = jump_velocity
			is_jumping = true
	move_and_slide()


func arrive_at_destination() -> void:
	# called by the destination we arrive at
	set_physics_process(false)


func pathfind(destination: Destination) -> void:
	pathfind_destination = destination
	set_physics_process(true)


func _on_land_detector_body_entered(body: Node2D) -> void:
	is_jumping = false
