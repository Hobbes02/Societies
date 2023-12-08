extends Node2D

const WORLD_DATA_DIR: String = "res://world/ldtk/societies/simplified/"

var chunk_dir: String = "chunk_0"
var collision_file_path: String = "collisions.csv"
var data_file_path: String = "data.json"

var chunk_data: Dictionary = {}

var chunk_size: Vector2 = Vector2.ZERO

@onready var visual_container: Node2D = $Visuals
@onready var layer_visual_template: Sprite2D = $Visuals/LayerVisualTemplate
@onready var collider: StaticBody2D = $Collider
@onready var collision_template: CollisionShape2D = $Collider/CollisionTemplate
@onready var player_collider: CollisionShape2D = $PlayerDetector/CollisionShape2D

@onready var collision_offset: Vector2 = Vector2(
	collision_template.shape.size.x / 2, 
	collision_template.shape.size.y / 2
)


func _ready() -> void:
	load_chunk_data()
	load_chunk_visual()
	load_chunk_collisions()
	global_position = Vector2(
		chunk_data.get("x", 0), 
		chunk_data.get("y", 0)
	)


func load_chunk_data() -> void:
	var file = FileAccess.open(WORLD_DATA_DIR + chunk_dir + "/" + data_file_path, FileAccess.READ)
	var string_content: String = file.get_as_text()
	file.close()
	
	chunk_data = str_to_var(string_content)


func load_chunk_visual() -> void:
	var file_paths: Array[String] = SaveManager.get_files_in_directory(WORLD_DATA_DIR + chunk_dir)
	var layer_img_paths: Array[String]
	
	for path in file_paths:
		if path.ends_with(".png") and (not path.begins_with("_")) and (not path.rstrip(".png").ends_with("-int")):
			layer_img_paths.append(WORLD_DATA_DIR + chunk_dir + "/" + path)
	
	for path in layer_img_paths:
		var layer_sprite: Sprite2D = layer_visual_template.duplicate()
		visual_container.add_child(layer_sprite)
		
		layer_sprite.texture = load(path)
		chunk_size = Vector2(layer_sprite.texture.get_width(), layer_sprite.texture.get_height())


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
	
	player_collider.shape.size = chunk_size
	player_collider.global_position = Vector2(
		player_collider.global_position.x + chunk_size.x / 2, 
		player_collider.global_position.y + chunk_size.y / 2
	)
