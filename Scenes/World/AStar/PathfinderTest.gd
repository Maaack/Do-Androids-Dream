extends Node2D

var update_move_indicator := true
var max_path_size := 20

func _find_nearest_tile(nearby_position : Vector2):
	return $AStarTileMap.get_nearest_tile_position(nearby_position)

func _reposition_move_indicator(destination: Vector2):
	if not update_move_indicator:
		return
	$PathHint.show()
	var end_tile = _find_nearest_tile(destination)
	$PathHint._set_indicator_position(end_tile)
	var path_points = $AStarTileMap.get_world_path_avoiding_points($ShepherdDummy.position, destination)
	if path_points.size() <2: 
		$PathHint.hide()
		return
	$PathHint.path_points = PoolVector2Array(path_points)

func _input(event):
	if event is InputEventMouseMotion:
		_reposition_move_indicator(event.position)
