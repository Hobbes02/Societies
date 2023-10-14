extends Node2D

const DIRECTION_UP: int = 0
const DIRECTION_DOWN: int = 2
const DIRECTION_LEFT: int = 3
const DIRECTION_RIGHT: int = 4


func generate_points(graph: AStar2D, tilemap: TileMap, layer: int, stats: PathfindEntityStats) -> AStar2D:
	var cells: Array = tilemap.get_used_cells(layer)
	
	for cell in cells:
		var above = Vector2i(cell.x, cell.y - 1)
		var type = get_cell_type(cells, cell, stats)
		
		if type != null and type != [0, 0]:
			graph = add_point(above, tilemap, graph)
			
			if type[0] == -1:
				var res = virtual_tile_raycast([cells], Vector2i(cell.x - 1, cell.y), 50, DIRECTION_DOWN)
				if res != null:
					graph = add_point(Vector2i(res.x, res.y - 1), tilemap, graph)
			if type[1] == -1:
				var res = virtual_tile_raycast([cells], Vector2i(cell.x + 1, cell.y), 50, DIRECTION_DOWN)
				if res != null:
					graph = add_point(Vector2i(res.x, res.y - 1), tilemap, graph)
	
	print("CREATED ", len(graph.get_point_ids()), " POINTS")
	
	return graph


func connect_points(graph: AStar2D, tilemap: TileMap, layer: int, stats: PathfindEntityStats) -> void:
	var tilemap_cells: Array = tilemap.get_used_cells(layer)
	var point_cells: Array = []
	var cell_size: Vector2 = tilemap.tile_set.tile_size
	
	for point in graph.get_point_ids():
		var point_cell = tilemap.local_to_map(tilemap.to_local(graph.get_point_position(point)))
		point_cells.append(Vector2i(point_cell.x, point_cell.y + 1))
	
	for i in range(len(graph.get_point_ids())):
		var id = graph.get_point_ids()[i]
		var point_cell = point_cells[i]
		
		# Find close right neighbor
		for j in range(1, 33):
			var c = Vector2i(point_cell.x + j, point_cell.y)
			
			if get_cell_type(tilemap_cells, c, stats) == null or not Vector2i(c.x, c.y + 1) in tilemap_cells:
				break
			if c in point_cells:
				graph.connect_points(id, graph.get_point_ids()[point_cells.find(c)])
				add_line(graph.get_point_position(id), graph.get_point_position(graph.get_point_ids()[point_cells.find(c)]))
				break
		
		# Find drop-down neighbor(s)
		var type = get_cell_type(tilemap_cells, point_cell, stats)
		if type[0] == -1:  # left drop-down
			var res = virtual_tile_raycast([tilemap_cells, point_cells], Vector2i(point_cell.x - 1, point_cell.y), 64, DIRECTION_DOWN)
			if res != null and res in point_cells:
				graph.connect_points(id, graph.get_point_ids()[point_cells.find(res)], graph.get_point_position(id).distance_to(graph.get_point_position(graph.get_point_ids()[point_cells.find(res)])) <= (stats.jump_height * tilemap.tile_set.tile_size.y))
				add_line(graph.get_point_position(id), graph.get_point_position(graph.get_point_ids()[point_cells.find(res)]))
		if type[1] == -1:  # right drop-down
			var res = virtual_tile_raycast([tilemap_cells, point_cells], Vector2i(point_cell.x + 1, point_cell.y), 64, DIRECTION_DOWN)
			if res != null and res in point_cells:
				graph.connect_points(id, graph.get_point_ids()[point_cells.find(res)], graph.get_point_position(id).distance_to(graph.get_point_position(graph.get_point_ids()[point_cells.find(res)])) <= (stats.jump_height * tilemap.tile_set.tile_size.y))
				add_line(graph.get_point_position(id), graph.get_point_position(graph.get_point_ids()[point_cells.find(res)]))


func add_point(cell: Vector2i, map: TileMap, graph: AStar2D) -> AStar2D:
	var pos = map.to_global(map.map_to_local(cell))
	if len(graph.get_point_ids()) > 0:
		if graph.get_point_position(graph.get_closest_point(pos)) == pos:
			return graph
	
	graph.add_point(graph.get_available_point_id(), pos)
	add_visual(cell, map)
	return graph


func add_visual(cell: Vector2i, map: TileMap) -> void:
	var r = $Reference.duplicate()
	r.global_position = map.to_global(map.map_to_local(cell))
	add_child(r)


func add_line(from: Vector2, to: Vector2) -> void:
	var l = $Line2D.duplicate()
	l.points = [from, to]
	add_child(l)


func virtual_tile_raycast(cell_arrays: Array[Array], start: Vector2i, distance: int, direction: int) -> Variant:
	for i in range(1, distance - 1):
		var cell: Vector2i = start
		match direction:
			DIRECTION_UP:
				cell.y = start.y - i
			DIRECTION_DOWN:
				cell.y = start.y + i
			DIRECTION_LEFT:
				cell.x = start.x - i
			DIRECTION_RIGHT:
				cell.x = start.x + i
		
		for cells in cell_arrays:
				if cell in cells:
					return cell
	
	return null


func get_cell_type(cells: Array[Vector2i], cell: Vector2i, stats: PathfindEntityStats) -> Variant:
	var res: Array = [0, 0]
	
	for i in range(1, stats.height + 1):
		if Vector2i(cell.x, cell.y - i) in cells:
			return null
	
	if Vector2i(cell.x - 1, cell.y - 1) in cells or Vector2i(cell.x - 1, cell.y - 2) in cells:
		res[0] = 1
	elif not Vector2i(cell.x - 1, cell.y) in cells:
		res[0] = -1
	
	if Vector2i(cell.x + 1, cell.y - 1) in cells or Vector2i(cell.x + 1, cell.y - 2) in cells:
		res[1] = 1
	elif not Vector2i(cell.x + 1, cell.y) in cells:
		res[1] = -1
	
	return res
