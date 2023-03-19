extends Node2D

signal sheep_ate_normal_grass(sheep_name)
signal sheep_ate_volatile_grass(sheep_name)
signal sheep_exploded(sheep_name)
signal sheep_assembled(sheep_name)

export(float, 0, 1000) var spawn_range : float = 200
export(Vector2) var spawn_offset : Vector2 = Vector2.ZERO

onready var shepherd_node = $Shepherd
var sheep_scene = preload("res://Scenes/Sheep/Sheep.tscn")
var sheep_array : Array = []

func _ready():
	randomize()
	# Randomize the placement of the grass patches and obstacles.

func reset_world():
	for sheep in sheep_array:
		if is_instance_valid(sheep):
			sheep.queue_free()

func add_sheep(sheep_name : String) -> void:
	var sheep_instance = sheep_scene.instance()
	var spawn_range_vector = Vector2(rand_range(-spawn_range,spawn_range),rand_range(-spawn_range,spawn_range))
	sheep_instance.position = shepherd_node.position + spawn_range_vector + spawn_offset
	sheep_instance.sheep_name = sheep_name
	sheep_instance.connect("normal_grass_eaten", self, "_on_sheep_ate_normal_grass", [sheep_name])
	sheep_instance.connect("volatile_grass_eaten", self, "_on_sheep_ate_volatile_grass", [sheep_name])
	sheep_instance.connect("exploded", self, "_on_sheep_exploded", [sheep_name])
	add_child(sheep_instance)
	sheep_array.append(sheep_instance)

func assemble_sheep(sheep_name : String):
	add_sheep(sheep_name)
	_on_sheep_assembled(sheep_name)

func _on_sheep_ate_normal_grass(sheep_name : String):
	emit_signal("sheep_ate_normal_grass", sheep_name)

func _on_sheep_ate_volatile_grass(sheep_name : String):
	emit_signal("sheep_ate_volatile_grass", sheep_name)

func _on_sheep_exploded(sheep_name : String):
	emit_signal("sheep_exploded", sheep_name)

func _on_sheep_assembled(sheep_name : String):
	emit_signal("sheep_assembled", sheep_name)
