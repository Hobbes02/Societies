class_name Chunk
extends Node2D

signal player_entered(chunk_name: String)

const WORLD_DATA_DIR: String = "res://world/ldtk/societies/simplified/"

const ENTITY_NAME_TO_SCENE: Dictionary = {
	"small_house": preload("res://objects/buildings/houses/small_house.tscn"), 
	"left_house": preload("res://objects/buildings/houses/house_left_addon.tscn"), 
	"right_house": preload("res://objects/buildings/houses/house_right_addon.tscn"), 
	"three_story_house": preload("res://objects/buildings/houses/house_three_stories.tscn"), 
	"two_side_house": preload("res://objects/buildings/houses/house_two_addons.tscn"), 
	"bake_shop": preload("res://objects/buildings/bake_shop.tscn"), 
	"post_office": preload("res://objects/buildings/post_office.tscn"), 
	"shop": preload("res://objects/buildings/shop.tscn"), 
	"npc": preload("res://objects/npc/npc.tscn"), 
	"door": preload("res://objects/buildings/doors/door.tscn")
}

var chunk_dir: String = "chunk_0"
var collision_file_path: String = "collisions.csv"
var data_file_path: String = "data.json"

var chunk_data: Dictionary = {}

var chunk_size: Vector2 = Vector2.ZERO

var layer_visuals: Sprite2D
var collider: StaticBody2D
var collision_template: CollisionShape2D : 
	set(new_value):
		collision_template = new_value
		collision_offset = Vector2(
			collision_template.shape.size.x / 2, 
			collision_template.shape.size.y / 2
		)
var player_collider: CollisionShape2D
var entity_container: Node2D

var collision_offset: Vector2


func _ready() -> void:
	if chunk_dir.begins_with("chunk_"):
		layer_visuals = $LayerVisuals
		collider = $Collider
		collision_template = $Collider/CollisionTemplate
		entity_container = $Entities
		player_collider = $PlayerDetector/CollisionShape2D
	
	if len(chunk_data) < 1:
		load_chunk_data()
	load_chunk_visual()
	load_chunk_collisions()
	global_position = Vector2(
		chunk_data.get("x", 0), 
		chunk_data.get("y", 0)
	)
	place_entities()


func load_chunk_data() -> void:
	var file = FileAccess.open(WORLD_DATA_DIR + chunk_dir + "/" + data_file_path, FileAccess.READ)
	var string_content: String = file.get_as_text()
	file.close()
	
	chunk_data = str_to_var(string_content)


func place_entities() -> void:
	var entities: Dictionary = chunk_data.entities
	
	for entity_type in entities.keys():
		for entity in entities[entity_type]:
			if not ENTITY_NAME_TO_SCENE.has(entity.id):
				continue
			
			var entity_node: Node = ENTITY_NAME_TO_SCENE[entity.id].instantiate()
			entity_node.set_meta("iid", entity.iid)
			entity_node.global_position = Vector2(
				entity.x, 
				entity.y + collision_offset.y - 1
			)
			
			for field_name in entity.customFields.keys():
				if field_name not in entity_node:
					continue
				entity_node.set(field_name, entity.customFields[field_name])
			
			entity_container.add_child(entity_node)


func load_chunk_visual() -> void:
	layer_visuals.texture = load(WORLD_DATA_DIR + chunk_dir + "/_composite.png")
	chunk_size = Vector2(
		layer_visuals.texture.get_width(), 
		layer_visuals.texture.get_height()
	)


func load_chunk_collisions() -> void:
	var collision_data_res: Resource = load(WORLD_DATA_DIR + chunk_dir + "/" + collision_file_path)
	collision_data_res.parse_remove_empty_eol()
	
	var collision_data: Array = collision_data_res.records
	
	for y in range(len(collision_data)):
		for x in range(len(collision_data[y])):
			var value = collision_data[y][x]
			
			if value == 0:
				continue
			
			if (y != 0 and collision_data[y - 1][x] == 0) or (y < (len(collision_data) - 1) and collision_data[y + 1][x] == 0) or (x != 0 and collision_data[y][x - 1] == 0) or (x < (len(collision_data[y]) - 1) and collision_data[y][x + 1] == 0):
				var collision_shape: CollisionShape2D = collision_template.duplicate()
				collision_shape.global_position = Vector2(
					(self.global_position.x + (x * 8)) + collision_offset.x, 
					(self.global_position.y + (y * 8)) + collision_offset.y, 
				)
				collision_shape.disabled = false
				collision_shape.show()
				collider.add_child(collision_shape)
	collision_template.disabled = true
	collision_template.hide()
	
	if player_collider:
		player_collider.shape.size = chunk_size
		player_collider.global_position = Vector2(
			player_collider.global_position.x + chunk_size.x / 2, 
			player_collider.global_position.y + chunk_size.y / 2
		)


func _on_player_detector_body_entered(body: Node2D) -> void:
	player_entered.emit(chunk_dir)
