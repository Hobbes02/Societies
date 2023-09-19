extends Node2D

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
