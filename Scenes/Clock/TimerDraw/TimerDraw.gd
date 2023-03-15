tool
extends ReferenceRect

var circle_color : Color
var current_value : float = 0.0
var total_value : float = 1.0
var max_angle : float = 359.99


func draw_circle_arc_poly(center, radius, angle_from, angle_to, color):
	var point_count = int(radius)
	var points_arc = PoolVector2Array()
	var colors = PoolColorArray([color])

	points_arc.push_back(center)

	for i in range(point_count + 1):
		var angle_point = deg2rad(angle_from + i * (angle_to - angle_from) / point_count - 90)
		points_arc.push_back(center + Vector2(cos(angle_point), sin(angle_point)) * radius)

	draw_polygon(points_arc, colors)

func _draw():
	var center_point = Vector2(get_size().x, get_size().y) / 2.0
	var radius = get_size().x / 2
	var current_angle = min(current_value / total_value * 360.0, max_angle)
	draw_circle_arc_poly(center_point, radius, current_angle, max_angle, circle_color)
