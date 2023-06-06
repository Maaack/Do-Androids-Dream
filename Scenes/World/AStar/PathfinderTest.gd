extends Node2D

func _find_nearest_tile(nearby_position : Vector2):
	return $AStarTileMap.get_nearest_tile_position(nearby_position)

func _reposition_move_indicator(destination: Vector2):
	$PathHint.show()
	var end_tile = _find_nearest_tile(destination)
	$PathHint.set_indicator_position(end_tile)
	var path_points = $AStarTileMap.get_world_path_avoiding_points($ShepherdDummy.position, destination)
	if path_points.size() < 2: 
		$PathHint.hide()
		return
	$PathHint.path_points = PoolVector2Array(path_points)

func _input(event):
	if event is InputEventMouseMotion:
		_reposition_move_indicator(event.position)
