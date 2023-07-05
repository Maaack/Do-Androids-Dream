tool
extends Control

enum Direction {
	UP,
	RIGHT,
	DOWN,
	LEFT
}

export(Direction) var direction : int = Direction.UP setget set_direction

func set_direction(value : int):
	direction = value
	if is_visible_in_tree():
		match(direction):
			Direction.UP:
				set_anchors_and_margins_preset(Control.PRESET_CENTER_TOP)
			Direction.RIGHT:
				set_anchors_and_margins_preset(Control.PRESET_CENTER_RIGHT)
			Direction.DOWN:
				set_anchors_and_margins_preset(Control.PRESET_CENTER_BOTTOM)
			Direction.LEFT:
				set_anchors_and_margins_preset(Control.PRESET_CENTER_LEFT)
		$GoalArrow.direction = direction

func _ready():
	self.direction = direction
