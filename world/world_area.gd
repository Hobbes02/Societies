extends Node2D

func _ready() -> void:
	pass


func _process(delta: float) -> void:
	$TileMap.local_to_map($Player.tile_pos)
