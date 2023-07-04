extends Node2D

signal sheep_ate_normal_grass(sheep_instance)
signal sheep_ate_volatile_grass(sheep_instance)
signal sheep_exploded(sheep_instance)
signal sheep_assembled(sheep_instance)
signal sheep_powered(sheep_instance)
signal sheep_joined(sheep_instance)
signal sheep_starved(sheep_instance)
signal sheep_part_collected
signal magnet_collected
signal battery_collected
signal repeller_collected
signal shepherd_entered_area(area_name)

export(float, 0, 1000) var spawn_range : float = 200
export(Vector2) var spawn_offset : Vector2 = Vector2.ZERO
export(float, 0, 1) var sheep_path_visible_probability : float = 0
export(Color) var charge_color : Color

onready var shepherd_node = $YSort/Shepherd
var sheep_scene = preload("res://Scenes/Sheep/Sheep.tscn")
var sheep_part_scene = preload("res://Scenes/SheepPart/SheepPart.tscn")
var sheep_instances : Array = []
var current_sheep_names : Array = []
var extra_sheep_names : Array = []

func _connect_sheep_signals(sheep_instance : Sheep):
	sheep_instance.connect("normal_grass_eaten", self, "_on_sheep_ate_normal_grass", [sheep_instance])
	sheep_instance.connect("volatile_grass_eaten", self, "_on_sheep_ate_volatile_grass", [sheep_instance])
	sheep_instance.connect("exploded", self, "_on_sheep_exploded", [sheep_instance])
	sheep_instance.connect("assembled", self, "_on_sheep_assembled", [sheep_instance])
	sheep_instance.connect("powered", self, "_on_sheep_powered", [sheep_instance])
	sheep_instance.connect("starved", self, "_on_sheep_starved", [sheep_instance])
	sheep_instance.connect("pathing", self, "_on_sheep_pathing", [sheep_instance])

func _name_sheep(sheep_instance : Sheep):
	var sheep_name = extra_sheep_names.pop_back()
	sheep_instance.sheep_name = sheep_name
	sheep_instance.collar_color = SheepConstants.COLORS[randi() % SheepConstants.COLORS.size()]
	current_sheep_names.append(sheep_name)

func _ready():
	randomize()
	extra_sheep_names = SheepConstants.NAMES.duplicate()
	extra_sheep_names.shuffle()

func set_day_length(day_length : float):
	$"DayNightCycle".day_length = day_length

func reset_day():
	$"DayNightCycle".reset_time()
	for sheep in sheep_instances:
		if is_instance_valid(sheep):
			sheep.reset_hunger()
			sheep.wake()

func reset_world(target_sheep_count : int = 1):
	for sheep in sheep_instances:
		if is_instance_valid(sheep):
			sheep.queue_free()
	sheep_instances.empty()
	$SheepParts.load_scenes()
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

func add_sheep(sheep_position : Vector2 = _get_random_sheep_position(), powered : bool = true) -> Node2D:
	var sheep_instance = sheep_scene.instance()
	sheep_instance.position = sheep_position
	sheep_instance.powered = powered
	_name_sheep(sheep_instance)
	_connect_sheep_signals(sheep_instance)
	$YSort.call_deferred("add_child", sheep_instance)
	sheep_instances.append(sheep_instance)
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

func get_powered_sheep_count():
	var powered_sheep : int = 0
	for sheep in sheep_instances:
		powered_sheep += int(sheep.powered)
	return powered_sheep

func get_powered_sheep():
	var powered_sheep_instances : Array = []
	for sheep_instance in sheep_instances:
		if sheep_instance.powered:
			powered_sheep_instances.append(sheep_instance)
	return powered_sheep_instances

func snooze_sheep():
	var powered_sheep_instances : Array = get_powered_sheep()
	for powered_sheep in powered_sheep_instances:
		powered_sheep.snooze()

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

func move_shepherd(direction : Vector2, manual : bool = true):
	if manual:
		$PathManager2D.reset()
	if direction != Vector2.ZERO:
		direction = direction.normalized()
	$"%Shepherd".move_vector = direction

func toggle_shepherd_equipped():
	$"%Shepherd".toggle_equipped()

func swap_shepherd_equipped():
	$"%Shepherd".swap()

func get_shepherd():
	return $"%Shepherd"

func set_shepherd_destination(destination : Vector2):
	destination *= $"%Shepherd".get_current_zoom()
	destination += $"%Shepherd".position
	var start_tile = $AStarTileMap.get_nearest_tile_position($"%Shepherd".position)
	var destination_tile = $AStarTileMap.get_nearest_tile_position(destination)
	var path_points = $AStarTileMap.get_world_path_avoiding_points($"%Shepherd".position, destination_tile)
	$PathsSpawner.add_path(path_points, start_tile, destination_tile)
	$PathManager2D.path = path_points
	
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

func _on_sheep_powered(sheep_instance : Sheep):
	emit_signal("sheep_powered", sheep_instance)

func _on_sheep_starved(sheep_instance : Sheep):
	emit_signal("sheep_starved", sheep_instance)

func _on_sheep_pathing(sheep_instance : Sheep):
	var sheep_tile_position = $AStarTileMap.get_nearest_tile_position(sheep_instance.position)
	var target_position = $"%Shepherd".position
	if $"%Shepherd".is_repeller_active():
		target_position = sheep_instance.position + (sheep_instance.position - target_position)
	var shepherd_tile_position = $AStarTileMap.get_nearest_tile_position(target_position)
	var path_points = $AStarTileMap.get_world_path_avoiding_points(sheep_tile_position, shepherd_tile_position)
	if path_points.size() < 2:
		sheep_instance.next_path_point_to_shepherd = target_position
		return
	if $"%Shepherd".is_magnet_active() and randf() < sheep_path_visible_probability:
		var sheep_color = sheep_instance.collar_color
		sheep_color.a = 0.5
		$PathsSpawner.add_path(path_points, sheep_tile_position, shepherd_tile_position, sheep_color)
	if $"%Shepherd".is_battery_equipped() and not sheep_instance.powered:
		$PathsSpawner.add_path(path_points, shepherd_tile_position, sheep_tile_position, charge_color)
	sheep_instance.next_path_point_to_shepherd = path_points[1]

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

func _on_UnpoweredSheepArea2D_shepherd_entered():
	emit_signal("shepherd_entered_area", "unpowered_sheep")

func _on_WatchersGateArea2D_shepherd_entered():
	emit_signal("shepherd_entered_area", "watchers_gate")

func _on_Shepherd_magnet_collected():
	emit_signal("magnet_collected")

func _on_Shepherd_battery_collected():
	emit_signal("battery_collected")

func _on_Shepherd_repeller_collected():
	emit_signal("repeller_collected")

func _on_PathManager2D_move(direction):
	move_shepherd(direction, false)

func _on_PathManager2D_destination_reached():
	move_shepherd(Vector2.ZERO, false)

func _on_SheepParts_add_sheep_part(part_position):
	add_sheep_part(part_position)

func _on_SheepParts_add_unpowered_sheep(sheep_position):
	add_sheep(sheep_position, false)
