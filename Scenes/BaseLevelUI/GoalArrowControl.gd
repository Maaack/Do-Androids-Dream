tool
extends Control

enum Directions {
	UP,
	RIGHT,
	DOWN,
	LEFT
}

export(Directions) var direction : int = Directions.UP setget set_direction

func set_direction(value : int):
	direction = value
	if is_visible_in_tree():
		match(direction):
			Directions.UP:
				set_anchors_and_margins_preset(Control.PRESET_CENTER_TOP)
			Directions.RIGHT:
				set_anchors_and_margins_preset(Control.PRESET_CENTER_RIGHT)
			Directions.DOWN:
				set_anchors_and_margins_preset(Control.PRESET_CENTER_BOTTOM)
			Directions.LEFT:
				set_anchors_and_margins_preset(Control.PRESET_CENTER_LEFT)
		$GoalArrow.direction = direction

func point_to(value : Vector2):
	var direction_map = {
		Directions.UP : Vector2.UP,
		Directions.RIGHT : Vector2.RIGHT,
		Directions.DOWN : Vector2.DOWN,
		Directions.LEFT : Vector2.LEFT,
	}
	var closest_direction : int = 0
	var closest_angle : float = PI * 2
	for key in direction_map:
		if abs(value.angle_to(direction_map[key])) < closest_angle:
			closest_angle = abs(value.angle_to(direction_map[key]))
			closest_direction = key
	self.direction = closest_direction

func _ready():
	self.direction = direction
