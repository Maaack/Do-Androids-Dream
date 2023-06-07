extends Node2D

signal sheep_ate_normal_grass(sheep_instance)
signal sheep_ate_volatile_grass(sheep_instance)
signal sheep_exploded(sheep_instance)
signal sheep_assembled(sheep_instance)
signal sheep_starved(sheep_instance)
signal sheep_part_collected
signal magnet_collected
signal shepherd_entered_area(area_name)

export(float, 0, 1000) var spawn_range : float = 200
export(Vector2) var spawn_offset : Vector2 = Vector2.ZERO

onready var shepherd_node = $YSort/Shepherd
var sheep_scene = preload("res://Scenes/Sheep/Sheep.tscn")
var sheep_part_scene = preload("res://Scenes/SheepPart/SheepPart.tscn")
var sheep_instances : Array = []
var current_sheep_names : Array = []
var extra_sheep_names : Array = []

func _ready():
	randomize()
	extra_sheep_names = SheepConstants.NAMES.duplicate()
	extra_sheep_names.shuffle()

func set_day_length(day_length : float):
	$"DayNightCycle".day_length = day_length

func reset_day():
	$"DayNightCycle".reset_time()
	for sheep in sheep_instances:
		if is_instance_valid(sheep) and sheep.has_method("reset_hunger"):
			sheep.reset_hunger()

func reset_world(target_sheep_count : int = 1):
	for sheep in sheep_instances:
		if is_instance_valid(sheep):
			sheep.queue_free()
	for i in range(target_sheep_count):
		add_sheep()
	reset_day()

func get_sheep_instance(sheep_name : String):
	var matched_sheep : Node2D
	for sheep_instance in sheep_instances:
		if sheep_instance.sheep_name == sheep_name:
			return sheep_instance

func _on_sheep_death(sheep_name : String, drop_rate : float = 0.5):
	var matched_sheep : Node2D = get_sheep_instance(sheep_name)
	if randf() < drop_rate:
		add_sheep_part(matched_sheep.position)
	sheep_instances.erase(matched_sheep)
	extra_sheep_names.push_front(sheep_name)
	current_sheep_names.erase(sheep_name)

func _get_random_sheep_position():
	var spawn_range_vector = Vector2(rand_range(-spawn_range,spawn_range),rand_range(-spawn_range,spawn_range))
	return shepherd_node.position + spawn_range_vector + spawn_offset

func add_sheep(sheep_position : Vector2 = _get_random_sheep_position()) -> Node2D:
	var sheep_name = extra_sheep_names.pop_back()
	var sheep_instance = sheep_scene.instance()
	sheep_instance.position = sheep_position
	sheep_instance.sheep_name = sheep_name
	sheep_instance.connect("normal_grass_eaten", self, "_on_sheep_ate_normal_grass", [sheep_instance])
	sheep_instance.connect("volatile_grass_eaten", self, "_on_sheep_ate_volatile_grass", [sheep_instance])
	sheep_instance.connect("exploded", self, "_on_sheep_exploded", [sheep_instance])
	sheep_instance.connect("assembled", self, "_on_sheep_assembled", [sheep_instance])
	sheep_instance.connect("starved", self, "_on_sheep_starved", [sheep_instance])
	$YSort.call_deferred("add_child", sheep_instance)
	sheep_instances.append(sheep_instance)
	current_sheep_names.append(sheep_name)
	return sheep_instance

func add_sheep_part(sheep_part_position : Vector2) -> Node2D:
	var sheep_part_instance = sheep_part_scene.instance()
	sheep_part_instance.position = sheep_part_position
	$SheepParts.add_child(sheep_part_instance)
	return sheep_part_instance

func assemble_sheep():
	var sheep_instance = add_sheep(shepherd_node.position + Vector2(0, 20))
	if not sheep_instance.is_visible_in_tree():
		yield(sheep_instance, "ready")
	sheep_instance.assemble()

func get_sheep_count():
	return sheep_instances.size()

func get_hungry_sheep():
	var hungry_sheep_instances : Array = []
	for sheep_instance in sheep_instances:
		if sheep_instance.is_hungry():
			hungry_sheep_instances.append(sheep_instance)
	return hungry_sheep_instances

func starve_hungry_sheep():
	var hungry_sheep_instances : Array = get_hungry_sheep()
	for hungry_sheep in hungry_sheep_instances:
		hungry_sheep.starve()

func move_shepherd(direction : Vector2):
	if direction != Vector2.ZERO:
		direction = direction.normalized()
	$"%Shepherd".move_vector = direction

func toggle_shepherd_magnet():
	$"%Shepherd".toggle_magnet()

func set_shepherd_destination(destination : Vector2):
	destination *= $"%Shepherd".get_current_zoom()
	$PathManager2D.path = $AStarTileMap.get_world_path_avoiding_points($"%Shepherd".position, $"%Shepherd".position + destination)

func _process(delta):
	$PathManager2D.move_to_next_point($"%Shepherd".position)

func _on_sheep_ate_normal_grass(sheep_instance : Sheep):
	emit_signal("sheep_ate_normal_grass", sheep_instance)

func _on_sheep_ate_volatile_grass(sheep_instance : Sheep):
	emit_signal("sheep_ate_volatile_grass", sheep_instance)

func _on_sheep_exploded(sheep_instance : Sheep):
	_on_sheep_death(sheep_instance.sheep_name, 0.25)
	emit_signal("sheep_exploded", sheep_instance)

func _on_sheep_assembled(sheep_instance : Sheep):
	emit_signal("sheep_assembled", sheep_instance)

func _on_sheep_starved(sheep_instance : Sheep):
	_on_sheep_death(sheep_instance.sheep_name, 1)
	emit_signal("sheep_starved", sheep_instance)

func _on_Shepherd_parts_assembled():
	if extra_sheep_names.size() == 0:
		return
	assemble_sheep()

func _on_Shepherd_part_collected():
	emit_signal("sheep_part_collected")

func _on_WestLandDetectorArea2D_shepherd_entered():
	emit_signal("shepherd_entered_area", "west_lands")

func _on_FirstCampDetectorArea2D_shepherd_entered():
	emit_signal("shepherd_entered_area", "first_camp")

func _on_SecondCampDetectorArea2D_shepherd_entered():
	emit_signal("shepherd_entered_area", "second_camp")

func _on_WellFedHintDetectorArea2D_shepherd_entered():
	emit_signal("shepherd_entered_area", "well_fed_hint")

func _on_FinalCampDetectorArea2D_shepherd_entered():
	emit_signal("shepherd_entered_area", "final_camp")

func _on_CrossroadsArea2D_shepherd_entered():
	emit_signal("shepherd_entered_area", "crossroads")

func _on_AlphaPastureArea2D_shepherd_entered():
	emit_signal("shepherd_entered_area", "alpha_pasture")

func _on_BetaPastureArea2D_shepherd_entered():
	emit_signal("shepherd_entered_area", "beta_pasture")

func _on_DeltaPastureArea2D_shepherd_entered():
	emit_signal("shepherd_entered_area", "delta_pasture")

func _on_BarrenLimitArea2D_shepherd_entered():
	emit_signal("shepherd_entered_area", "barren_limit")

func _on_VolatilePasturesArea2D_shepherd_entered():
	emit_signal("shepherd_entered_area", "volatile_pastures")

func _on_WindingCircuitArea2D_shepherd_entered():
	emit_signal("shepherd_entered_area", "winding_circuit")

func _on_Shepherd_magnet_collected():
	emit_signal("magnet_collected")

func _on_PathManager2D_move(direction):
	move_shepherd(direction)

func _on_PathManager2D_destination_reached():
	move_shepherd(Vector2.ZERO)
