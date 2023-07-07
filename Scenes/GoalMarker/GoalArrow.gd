tool
extends Node2D

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
				$AnimationPlayer.play("PointUp")
			Directions.RIGHT:
				$AnimationPlayer.play("PointRight")
			Directions.DOWN:
				$AnimationPlayer.play("PointDown")
			Directions.LEFT:
				$AnimationPlayer.play("PointLeft")
