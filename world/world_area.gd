extends Node2D

var retrival_pos: Vector2
var tile_pos: Vector2i
var tile_data: TileData
var tiles: int = 1
var tile_type_data_layer: String = "tile_type"
var tile_type: int
@onready var tile_map: TileMap = $TileMap

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	retrival_pos = $Player.tile_pos
	tile_pos = tile_map.local_to_map(retrival_pos)
	tile_data = tile_map.get_cell_tile_data(tiles, tile_pos)
	if tile_data:
		tile_type = tile_data.get_custom_data(tile_type_data_layer)
	else:
		print("tile_data returned null")
		tile_type = 0

func _on_player_get_tile_data() -> void:
	$Player.at_feet_tile = tile_type
