tool
extends Node2D

enum Direction {
	UP,
	RIGHT,
	DOWN,
	LEFT
}

export(Direction) var direction : int = Direction.UP setget set_direction

func set_direction(value : int):
	direction = value
	match(direction):
		Direction.UP:
			$AnimationPlayer.play("PointUp")
		Direction.RIGHT:
			$AnimationPlayer.play("PointRight")
		Direction.DOWN:
			$AnimationPlayer.play("PointDown")
		Direction.LEFT:
			$AnimationPlayer.play("PointLeft")
