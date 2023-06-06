extends TileMap
class_name AStarTileMap

const CARDINAL_DIRECTIONS := [
	Vector2.UP, 
	Vector2.DOWN,
	Vector2.LEFT,
	Vector2.RIGHT,
	]
const DIAGONAL_DIRECTIONS := [
	Vector2.RIGHT + Vector2.UP,
	Vector2.RIGHT + Vector2.DOWN,
	Vector2.LEFT + Vector2.UP,
	Vector2.LEFT + Vector2.DOWN,
	]
enum ConnectPointModes {
	CARDINAL_ONLY,
	DIAGONAL_ONLY,
	ALL,
}

export(ConnectPointModes) var connect_point_mode : int = ConnectPointModes.CARDINAL_ONLY
# The amount of tiles one can go into the negatives
export(Vector2) var point_offset = Vector2(pow(2,10), pow(2,10))

var astar := AStar2D.new()

func _ready() -> void:
	update()

func is_in_bounds(point_position : Vector2) -> bool:
	var point_position_offset = point_position + point_offset
	return point_position_offset.x >= 0 and point_position_offset.y >= 0

func get_point_index(point_position: Vector2) -> int:
	if not is_in_bounds(point_position):
		print('Error: AStarTileMap positions cannot be less than 0 on any axis')
		return 0
	var point_position_offset = point_position + point_offset
	# Cantor pairing function
	var a := int(point_position_offset.x)
	var b := int(point_position_offset.y)
	var result = (a + b) * (a + b + 1) / 2 + b
	if result < 0:
		print("(%d + %d) * (%d + %d + 1) / 2 + %d = %d" % [a, b, a, b, b, result])
	return result

func connect_neighboring_points(cell_vector : Vector2 , directions : Array, bidirectional : bool = true):
	var center_point_index := get_point_index(cell_vector)
	if not astar.has_point(center_point_index):
		return
	for direction in directions:
		var neighbor_vector = cell_vector + direction
		if not is_in_bounds(neighbor_vector):
			continue
		var neighbor_point_index = get_point_index(neighbor_vector)
		if neighbor_point_index != center_point_index and astar.has_point(neighbor_point_index):
			astar.connect_points(center_point_index, neighbor_point_index, bidirectional)

func connect_cardinals(cell_vector : Vector2) -> void:
	connect_neighboring_points(cell_vector, CARDINAL_DIRECTIONS)

func connect_diagonals(cell_vector : Vector2) -> void:
	connect_neighboring_points(cell_vector, DIAGONAL_DIRECTIONS)

func connect_all(cell_vector : Vector2) -> void:
	connect_neighboring_points(cell_vector, CARDINAL_DIRECTIONS)
	connect_neighboring_points(cell_vector, DIAGONAL_DIRECTIONS)

func create_pathfinding_points(points : Array, point_weight : float = 1.0) -> void:
	astar.clear()
	for point_vector in points:
		if get_cellv(point_vector) == INVALID_CELL: 
			continue
		astar.add_point(get_point_index(point_vector), point_vector, point_weight)
	for point_vector in points:
		match(connect_point_mode):
			ConnectPointModes.CARDINAL_ONLY:
				connect_cardinals(point_vector)
			ConnectPointModes.DIAGONAL_ONLY:
				connect_diagonals(point_vector)
			ConnectPointModes.ALL:
				connect_all(point_vector)

func set_path_length(point_path: Array, max_distance: int) -> Array:
	if max_distance < 0: 
		return point_path
	point_path.resize(min(point_path.size(), max_distance))
	return point_path

func update() -> void:
	create_pathfinding_points(get_used_cells())

func set_points_disabled(points : Array, disabled : bool = true) -> void:
	for point_vector in points:
		var point_index := get_point_index(point_vector)
		if astar.has_point(point_index):
			astar.set_point_disabled(point_index, disabled)

func get_astar_path(start_cell: Vector2, end_cell: Vector2, max_distance := -1) -> Array:
	if not astar.has_point(get_point_index(start_cell)) or not astar.has_point(get_point_index(end_cell)):
		return []
	var astar_path := astar.get_point_path(get_point_index(start_cell), get_point_index(end_cell))
	return set_path_length(astar_path, max_distance)

func get_astar_path_avoiding_points(start_cell: Vector2, end_cell: Vector2, avoid_cells : Array = [], max_distance := -1) -> Array:
	set_points_disabled(avoid_cells)
	var astar_path := get_astar_path(start_cell, end_cell, max_distance)
	set_points_disabled(avoid_cells, false)
	return astar_path

func get_grid_distance(distance: Vector2) -> float:
	var vec := world_to_map(distance).abs().floor()
	return vec.x + vec.y

func get_half_cell_size() -> Vector2:
	return cell_size / 2

func map_to_world_path(path : Array):
	var world_path := []
	var half_cell_size = get_half_cell_size()
	for cell_vector in path:
		world_path.append(map_to_world(cell_vector) + half_cell_size)
	return world_path

func get_world_path_avoiding_points(start_position: Vector2, end_position: Vector2, avoid_positions : Array = [], max_distance := -1) -> Array:
	var start_cell := world_to_map(start_position)
	var end_cell := world_to_map(end_position)
	var avoid_cells := []
	for avoid_position in avoid_positions:
		avoid_cells.append(world_to_map(avoid_position))
	var astar_path := get_astar_path_avoiding_points(start_cell, end_cell, avoid_cells, max_distance)
	return map_to_world_path(astar_path)

func get_nearest_tile_position(check_position : Vector2):
	return map_to_world(world_to_map(check_position)) + get_half_cell_size()
