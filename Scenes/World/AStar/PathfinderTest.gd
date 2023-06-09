extends Node2D

export(float) var move_time : float = 0.5
export(int) var max_path_size : int = 30

func _find_nearest_tile(nearby_position : Vector2):
	return $AStarTileMap.get_nearest_tile_position(nearby_position)

func _reposition_move_indicator(destination: Vector2):
	$PathHint.show()
	var end_tile = _find_nearest_tile(destination)
	$PathHint.end_position = end_tile
	var path_points = $AStarTileMap.get_world_path_avoiding_points($ShepherdDummy.position, destination)
	if path_points.size() < 2 or path_points.size() > max_path_size: 
		$PathHint.hide()
		return
	$PathHint.path_points = PoolVector2Array(path_points)

func _move_pc_to_position(destination : Vector2):
	var path_points = $AStarTileMap.get_world_path_avoiding_points($ShepherdDummy.position, destination)
	if path_points.size() < 2 or path_points.size() > max_path_size: 
		return
	$PathManager2D.path = path_points

func _get_camera_center():
	return $"%Camera2D".global_position - ($"%Camera2D".get_viewport_rect().size / 2)

func _input(event):
	if event is InputEventMouseMotion:
		_reposition_move_indicator(event.position + _get_camera_center())
	if event is InputEventMouseButton:
		if event.pressed:
			_move_pc_to_position(event.position + _get_camera_center())

func _process(_delta):
	$PathManager2D.move_to_next_point($ShepherdDummy.position)

func _on_PathManager2D_move(direction):
	$ShepherdDummy.position += direction

func _on_PathManager2D_point_reached():
	pass

func _on_PathManager2D_destination_reached():
	print("destination reached")
