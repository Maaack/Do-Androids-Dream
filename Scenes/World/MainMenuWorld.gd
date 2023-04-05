extends Node2D

export(float, 0, 1000) var spawn_range : float = 200
export(Vector2) var spawn_offset : Vector2 = Vector2.ZERO

onready var camera_node = $Camera2D

var sheep_scene = preload("res://Scenes/Sheep/Sheep.tscn")

func _add_sheep():
	var sheep_instance = sheep_scene.instance()
	var spawn_range_vector = Vector2(rand_range(-spawn_range,spawn_range),rand_range(-spawn_range,spawn_range))
	sheep_instance.position = camera_node.position + spawn_range_vector + spawn_offset
	add_child(sheep_instance)
	

func _on_SheepTimer_timeout():
	_add_sheep()

func _ready():
	_add_sheep()
