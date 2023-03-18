extends Node2D


export(float, 0, 1000) var spawn_range : float = 200

onready var shepherd_node = $Shepherd
var sheep_scene = preload("res://Scenes/Sheep/Sheep.tscn")
var sheep_array : Array = []

func _ready():
	randomize()
	# Randomize the placement of the grass patches and obstacles.

func reset_world():
	for sheep in sheep_array:
		sheep.queue_free()

func add_sheep(sheep_name : String) -> void:
	var sheep_instance = sheep_scene.instance()
	var spawn_range_vector = Vector2(rand_range(-spawn_range,spawn_range),rand_range(-spawn_range,spawn_range))
	sheep_instance.position = shepherd_node.position + spawn_range_vector
	sheep_instance.sheep_name = sheep_name
	add_child(sheep_instance)
	sheep_array.append(sheep_instance)
