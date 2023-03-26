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
var extra_sheep_names : Array

func _ready():
	randomize()
	# Randomize the placement of the grass patches and obstacles.

func set_day_length(day_length : float):
	$"DayNightCycle".day_length = day_length

func reset_world():
	$"DayNightCycle".reset_time()
	for sheep in sheep_array:
		if is_instance_valid(sheep):
			sheep.queue_free()

func _get_random_sheep_position():
	var spawn_range_vector = Vector2(rand_range(-spawn_range,spawn_range),rand_range(-spawn_range,spawn_range))
	return shepherd_node.position + spawn_range_vector + spawn_offset

func add_sheep(sheep_name : String, sheep_position : Vector2 = _get_random_sheep_position()) -> Node2D:
	var sheep_instance = sheep_scene.instance()
	sheep_instance.position = sheep_position
	sheep_instance.sheep_name = sheep_name
	sheep_instance.connect("normal_grass_eaten", self, "_on_sheep_ate_normal_grass", [sheep_name])
	sheep_instance.connect("volatile_grass_eaten", self, "_on_sheep_ate_volatile_grass", [sheep_name])
	sheep_instance.connect("exploded", self, "_on_sheep_exploded", [sheep_name])
	sheep_instance.connect("assembled", self, "_on_sheep_assembled", [sheep_name])
	add_child(sheep_instance)
	sheep_array.append(sheep_instance)
	return sheep_instance

func assemble_sheep(sheep_name : String):
	var sheep_instance = add_sheep(sheep_name, shepherd_node.position + Vector2(0, 20))
	sheep_instance.assemble()

func _on_sheep_ate_normal_grass(sheep_name : String):
	emit_signal("sheep_ate_normal_grass", sheep_name)

func _on_sheep_ate_volatile_grass(sheep_name : String):
	emit_signal("sheep_ate_volatile_grass", sheep_name)

func _on_sheep_exploded(sheep_name : String):
	extra_sheep_names.append(sheep_name)
	emit_signal("sheep_exploded", sheep_name)

func _on_sheep_assembled(sheep_name : String):
	emit_signal("sheep_assembled", sheep_name)

func _on_Shepherd_parts_assembled():
	if extra_sheep_names.size() == 0:
		return
	var sheep_name = extra_sheep_names.pop_back()
	assemble_sheep(sheep_name)
