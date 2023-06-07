extends Node

signal destination_reached
signal point_reached
signal move(direction)

export(float, 0, 1024) var point_proximity_margin : float = 1.0
var path : Array = [] setget set_path
var path_iter : int = 0
var is_active : bool = false

func set_path(value : Array):
	path = value
	path_iter = 0
	is_active = true

func get_current_point():
	if not is_active or path.size() == 0:
		return
	if path_iter >= path.size():
		path_iter = 0
	return path[path_iter]

func get_current_point_proximity(position : Vector2):
	var point = get_current_point()
	if point == null:
		return 0
	return (position - point).length()

func in_range_of_current_point(position : Vector2):
	return get_current_point_proximity(position) < point_proximity_margin

func _reset():
	path_iter = 0
	path = []
	is_active = false

func move_to_next_point(position : Vector2):
	if not is_active:
		return
	if in_range_of_current_point(position):
		emit_signal("point_reached")
		path_iter += 1
	if path_iter >= path.size():
		emit_signal("destination_reached")
		_reset()
		return
	var next_point = get_current_point()
	var move_direction = (next_point - position).normalized()
	emit_signal("move", move_direction)
	
