extends KinematicBody2D
class_name Sheep

signal normal_grass_eaten
signal volatile_grass_eaten
signal exploded
signal assembled
signal powered
signal starved
signal pathing

onready var animation_tree = $AnimationTree
onready var animation_state = animation_tree.get("parameters/playback")

export var walk_speed = 10 # speed of the sheep when walking
export var min_distance_with_nearby = 50 # minimum distance the sheep will try to keep with the others
export var center_factor = 1 # priority of the move to center direction
export var avoid_factor = 1 # priority of the move to avoid direction
export var avg_dir_factor = 1 # priority of the common direction
export var grass_factor = 10 # priority of the direction to targeted grass patch
export var shepherd_factor = 3 # priority of the direction to shepherd
export var shepherd_avoid_factor = 5 # priority of the direction to avoid getting to close to the shepherd
export var magnet_factor = 15 # priority of the sheep to follow the magnet
export var poisoned_sheep_avoid_factor = 40 # priority of the direction to avoid getting to close to the shepherd
export var laziness = 3
export var wait_time : float = 5
export var wait_time_randomness : float = 2
export(int) var daily_food_required : int = 2
export(bool) var hunger_meter_visible : bool = true
export(bool) var powered : bool = true setget set_powered
var hunger = 0 # number of grass patches the sheep need to eat -> 0 means it's full and does not need to eat anymore
var direction = Vector2.ZERO # direction to move to
var velocity = Vector2.ZERO
var nearby_sheep = [] # list of sheeps which are in the detection area
var nearby_grass = [] # list of grass patches which are in the detection area
var targeted_grass # the grass patch the sheep is targetting and going to
var shepherd # the shepherd (if in range)
var next_path_point_to_shepherd
export(String) var sheep_name : String setget set_sheep_name
var custom_sheep_name : String setget set_custom_sheep_name
export(Color) var collar_color : Color setget set_collar_color
var is_moving : bool = true
var is_poisoned : bool = false

func _set_blend_positions(input_vector : Vector2):
	animation_tree.set("parameters/Idle/blend_position", input_vector)
	animation_tree.set("parameters/Walk/blend_position", input_vector)
	animation_tree.set("parameters/Run/blend_position", input_vector)
	animation_tree.set("parameters/Explode/blend_position", input_vector)
	animation_tree.set("parameters/Eat/blend_position", input_vector)
	animation_tree.set("parameters/PowerUp/blend_position", input_vector.x)
	animation_tree.set("parameters/PoweredDown/blend_position", input_vector.x)

func _walk(delta):
	if not is_moving:
		return
	var walk_mod = 1.0
	if direction.length() < laziness:
		$WalkingStreamCycler2D.stop()
		animation_state.travel("Idle")
		return
	elif direction.length() > 2.5 * laziness:
		animation_state.travel("Run")
		walk_mod *= 2
	else:
		animation_state.travel("Walk")
	var input_vector = direction.normalized()
	_set_blend_positions(input_vector)
	move_and_slide(input_vector * walk_speed * walk_mod * delta)
	$WalkingStreamCycler2D.play()

func _physics_process(delta):
	_walk(delta)

func is_hungry() -> bool:
	return powered and hunger > 0

func _update_sheep_name():
	if is_inside_tree():
		$NameLabel.text = get_readable_name()

func set_sheep_name(new_value : String):
	sheep_name = new_value
	_update_sheep_name()

func get_readable_name() -> String:
	if custom_sheep_name != "":
		return custom_sheep_name
	return sheep_name

func set_custom_sheep_name(new_value : String):
	custom_sheep_name = new_value
	_update_sheep_name()

func set_collar_color(new_value : Color):
	collar_color = new_value
	if is_inside_tree():
		$CollarSprite.modulate = collar_color

# will return a vector for the sheep to go to the center of mass of the group of nearby sheeps - Boids rules #1
func calc_direction_to_center_of_mass_nearby():
	var center = Vector2.ZERO
	for sheep in nearby_sheep:
		if sheep.powered:
			center += sheep.position
	center /= nearby_sheep.size()
	
	return position.direction_to(center) * center_factor


# will return a vector for the sheep to keep some distance with each other to avoid collidiong - Boids rules #2
func calc_direction_to_avoid_colliding_nearby():
	var avoid = position
	for sheep in nearby_sheep:
		if position.distance_to(sheep.position) <= min_distance_with_nearby:
			avoid -= position.direction_to(sheep.position) * (1 + (int(sheep.is_poisoned) * poisoned_sheep_avoid_factor))
	return position.direction_to(avoid) * avoid_factor


# will return a vector for the sheep to heads towards the same direction as the nearby sheeps - Boids rules #3
func calc_velocity_nearby():
	var avg_direction = Vector2.ZERO
	for sheep in nearby_sheep:
		avg_direction += sheep.direction.normalized()
	avg_direction /= nearby_sheep.size()
	
	return avg_direction * avg_dir_factor

func calc_direction_to_nearest_grass():
	if target_grass():
		return position.direction_to(targeted_grass.position) * grass_factor
	else:
		return Vector2.ZERO


# calculate direction to the shepherd (player), the shepherd.magnet_factor will cahnge depending iif the player is using the magnet or not
func calc_direction_to_shepherd():
	if shepherd:
		var final_factor = shepherd_factor
		if shepherd.is_magnet_active():
			final_factor += magnet_factor
		if next_path_point_to_shepherd == null:
			next_path_point_to_shepherd = shepherd.position
		return position.direction_to(next_path_point_to_shepherd) * final_factor
	else:
		return Vector2.ZERO


func calc_direction_to_avoid_colliding_shepherd():
	if shepherd and position.distance_to(shepherd.position) <= min_distance_with_nearby:
		return -position.direction_to(shepherd.position) * shepherd_avoid_factor
	else:
		return Vector2.ZERO


# will target the nearest grass patch in range if none is targeted and sheep is hungry
# return true if there is already a targeted patch or if the function targeted a new one otherwise flase
func target_grass():
	if hunger > 0 and nearby_grass.size() > 0:
		var closest_grass
		var closest_distance = 99999
		for grass in nearby_grass:
			var calc_dist_squared = position.distance_squared_to(grass.position)
			if calc_dist_squared < closest_distance:
				closest_grass = grass
				closest_distance = calc_dist_squared
		targeted_grass = closest_grass
		
	return targeted_grass != null

func _assemble_animation():
	animation_state.travel("Assemble")
	$AssemblyStreamPlayer2D.play()

func _power_up_animation():
	$AnimationTree.get("parameters/playback").travel("PowerUp")
	$PowerUpStreamPlayer2D.play()

func _powered_down_animation():
	$AnimationTree.get("parameters/playback").travel("PoweredDown")

func _eat_animation():
	$EatStreamPlayer2D.play()
	animation_state.travel("Eat")

func _stop_moving():
	is_moving = false
	$UpdateMovementTimer.paused = true
	$BahStreamCycler2D.stop()

func _start_moving():
	is_moving = true
	$UpdateMovementTimer.paused = false
	$BahStreamCycler2D.play()


func _explode():
	_stop_moving()
	is_poisoned = true
	animation_state.travel("Explode")
	emit_signal("exploded")
	$AnimationEventTimer.start(1)
	yield($AnimationEventTimer, "timeout")
	$CollisionShape2D.disabled = true
	$AnimationEventTimer.start(3)
	yield($AnimationEventTimer, "timeout")
	queue_free() # BOOM

func show_hunger_meter(show_name : bool = false):
	if not hunger_meter_visible:
		return
	if show_name:
		$HungerMeterAnimationPlayer.play("FadeInNOutWithName")
	else:
		$HungerMeterAnimationPlayer.play("FadeInNOut")

func _update_hunger(delta : int = 0) -> void:
	hunger += delta
	$HungerMeter/MeterSprite1.frame = int(hunger < 2)
	$HungerMeter/MeterSprite2.frame = int(hunger < 1)

func _finish_eating(grass_was_volatile : bool = false):
	targeted_grass.queue_free()
	targeted_grass = null
	_update_hunger(-1)
	if grass_was_volatile:
		emit_signal("volatile_grass_eaten")
		_explode()
	elif hunger == 0:
		emit_signal("normal_grass_eaten")

func starve():
	set_powered(false)
	emit_signal("starved")

func eat_grass():
	var grass_was_volatile : bool = targeted_grass.is_volatile
	# play eating animation
	_stop_moving()
	_eat_animation()
	# wait a certain amount of time
	$AnimationEventTimer.start(0.5)
	yield($AnimationEventTimer, "timeout")
	show_hunger_meter()
	$AnimationEventTimer.start(1.5)
	yield($AnimationEventTimer, "timeout")
	_start_moving()
	_finish_eating(grass_was_volatile)

func assemble():
	_stop_moving()
	_assemble_animation()
	
func _finish_assembly():
	if is_moving:
		return
	emit_signal("assembled")
	_start_moving()

func _power_up():
	_power_up_animation()
	if is_visible_in_tree():
		$CheckChargeTimer.stop()

func _finish_power_up():
	if is_moving:
		return
	emit_signal("powered")
	_start_moving()

func _power_down():
	_stop_moving()
	_powered_down_animation()
	if is_visible_in_tree():
		$CheckChargeTimer.start()

func set_powered(value : bool):
	powered = value
	if powered:
		_power_up()
	else:
		_power_down()

func _charge_sheep():
	if powered:
		return
	set_powered(true)

func _on_FarDetectionArea_body_entered(body : Node2D):
	if body.is_in_group("sheeps"):
		nearby_sheep.append(body)
	elif body.is_in_group("shepherds"):
		shepherd = body

func _on_FarDetectionArea_body_exited(body):
	if body.is_in_group("sheeps"):
		nearby_sheep.erase(body)
	elif body.is_in_group("shepherds"):
		shepherd = null

func _on_NearDetectionArea_area_entered(area):
	if area.is_in_group("grass"):
		nearby_grass.append(area)

func _on_NearDetectionArea_area_exited(area):
	if area.is_in_group("grass"):
		nearby_grass.erase(area)
		if area == targeted_grass:
			targeted_grass = null

func _on_NearDetectionArea_body_entered(body):
	if body.is_in_group("shepherds") and body.has_signal("sheep_charged"):
		body.connect("sheep_charged", self, "_charge_sheep")

func _on_NearDetectionArea_body_exited(body):
	if body.is_in_group("shepherds") and body.is_connected("sheep_charged", self, "_charge_sheep"):
		body.disconnect("sheep_charged", self, "_charge_sheep")
			
func _update_direction():
	emit_signal("pathing")
	direction = (
		calc_direction_to_center_of_mass_nearby() +
		calc_direction_to_avoid_colliding_nearby() +
		calc_velocity_nearby() +
		calc_direction_to_nearest_grass() +
		calc_direction_to_shepherd() + 
		calc_direction_to_avoid_colliding_shepherd()
	)

func _on_UpdateMovementTimer_timeout():
	_update_direction()
	$UpdateMovementTimer.wait_time = wait_time + rand_range(-wait_time_randomness, wait_time_randomness)

func _on_CheckChargeTimer_timeout():
	if not powered and shepherd != null and shepherd.is_connected("sheep_charged", self, "_charge_sheep"):
		emit_signal("pathing")

func reset_hunger():
	hunger = daily_food_required
	_update_hunger()

func _get_plus_or_minus_one():
	return (randi() % 2) * 2 - 1

func _ready():
	reset_hunger()
	set_sheep_name(sheep_name)
	set_collar_color(collar_color)
	set_powered(powered)
	if not powered:
		var random_direction = _get_plus_or_minus_one()
		animation_tree.set("parameters/PoweredDown/blend_position", random_direction)
		animation_tree.set("parameters/PowerUp/blend_position", random_direction)

func _on_Sheep_mouse_entered():
	show_hunger_meter(true)
