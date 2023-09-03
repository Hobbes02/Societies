extends Node2D

signal at_feet_tile_id
var tile_data: TileData
var tiles: int = 1
var tile_pos: Vector2i
var tile_type_data_layer: String = "tile_type"
var tile_id: int

@onready var tile_map: TileMap = $TileMap
@onready var player: CharacterBody2D = $Player


func _ready() -> void:
	pass


func _process(delta: float) -> void:
	pass


func _on_player_get_tile_data(retrival_pos: Vector2i) -> void:
#	gets the global coods of the tile at 'retrival_pos'
	tile_pos = tile_map.local_to_map(retrival_pos)
#	gets the data from the 'tiles' layer at the coords 'tile_pos'
	tile_data = tile_map.get_cell_tile_data(tiles, tile_pos)
#	checks if the tile actually has data
	if tile_data:
#		sets 'tile_id' to the custom data
		tile_id = tile_data.get_custom_data(tile_type_data_layer)
	else:
		tile_id = 0
	
	at_feet_tile_id.emit(tile_id)
