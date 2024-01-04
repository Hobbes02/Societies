class_name Interior
extends Chunk

@onready var player: Player = $Player


func _ready() -> void:
	chunk_dir = "interior_1"
	
	layer_visuals = $Visuals
	entity_container = $EntityContainer
	collider = $Collider
	collision_template = $Collider/CollisionTemplate
	
	if len(chunk_data) < 1:
		load_chunk_data()
	load_chunk_visual()
	load_chunk_collisions()
	place_entities()
	
	if chunk_data.has("entities") and chunk_data.entities.has("door") and len(chunk_data.entities.door) > 0:
		player.global_position = Vector2(
			chunk_data.entities.door[0].x, 
			chunk_data.entities.door[0].y
		)
