@tool
extends CharacterBody2D

signal focus_camera(node: Node2D)
signal unfocus_camera()

@export var npc_name: String = "Bobert"

@export var texture: Texture2D : 
	set(new_val):
		texture = new_val
		$Sprite2D.texture = new_val

@export var dialogue_resource: DialogueResource
@export var start_title: String = "start"

@export var character_names: Array[String] = []
@export var character_nodes: Array[Node2D] = []

@export var speed: float = 50.0

var jump_velocity: float = -225.0

var path: Array[PathfindTarget]
var current_point: int = -1

var gravity: int = ProjectSettings.get_setting("physics/2d/default_gravity")

var is_jumping: bool = false

@onready var interactable: Interactable = $Interactable
@onready var tile_center_marker: Marker2D = $TileCenterMarker


func _ready() -> void:
	if Engine.is_editor_hint():
		return
	set_physics_process(false)
	interactable.dialogue_file = dialogue_resource
	interactable.title = start_title
	interactable.character_names = character_names
	interactable.character_nodes = character_nodes
	interactable.show()


func _on_interactable_focus_camera(node: Node2D) -> void:
	focus_camera.emit(node)


func _on_interactable_ended() -> void:
	unfocus_camera.emit()


func next_point() -> void:
	current_point += 1
	
	if current_point == len(path):
		current_point = -1
		return


func _physics_process(delta: float) -> void:
	if Engine.is_editor_hint() or SceneManager.is_paused(self):
		return
	
	if not is_on_floor():
		velocity.y += gravity * delta
	if is_on_floor() and is_jumping:
		is_jumping = false
	
	if current_point != -1:
		var pos = tile_center_marker.global_position
		var target_pos = path[current_point].position
		
		match path[current_point].movement_type:
			PathfindTarget.TYPE_JUMP:
				if not is_jumping and pos.y >= target_pos.y:
					velocity.y = jump_velocity
					is_jumping = true
				if not (pos.x < target_pos.x + 2 and pos.x > target_pos.x - 2):
					velocity.x = speed if pos.x < target_pos.x else -speed
				else:
					velocity.x = 0
				if pos.distance_to(target_pos) < 4:
					next_point()
			PathfindTarget.TYPE_WALK:
				velocity.x = speed if pos.x < target_pos.x else -speed
				if pos.distance_to(target_pos) < 4:
					next_point()
	else:
		velocity.x = 0
	
	move_and_slide()


func pathfind(pathfinding_path: Array[PathfindTarget]) -> void:
	current_point = 0
	path = pathfinding_path
	next_point()


func _on_physics_start_timer_timeout() -> void:
	set_physics_process(true)
