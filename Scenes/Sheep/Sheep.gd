extends KinematicBody2D

export var walk_speed = 10 # speed of the sheep when walking
export var min_distance_with_nearby = 50 # minimum distance the sheep will try to keep with the others
export var center_factor = 1 # priority of the move to center direction
export var avoid_factor = 1 # priority of the move to avoid direction
export var avg_dir_factor = 1 # priority of the common direction
export var grass_factor = 10 # priority of the direction to targeted grass patch
export var shepherd_factor = 3 # priority of the direction to shepherd
export var shepherd_avoid_factor = 5 # priority of the direction to avoid getting to close to the shepherd
var hunger = 2 # number of grass patches the sheep need to eat -> 0 means it's full and does not need to eat anymore
var direction = Vector2.ZERO # direction to move to
var nearby_sheep = [] # list of sheeps which are in the detection area
var nearby_grass = [] # list of grass patches which are in the detection area
var targeted_grass # the grass patch the sheep is targetting and going to
var shepherd # the shepherd (if in range)
var sheep_name : String 

func _physics_process(_delta):
	move_and_slide(direction * walk_speed)


# will return a vector for the sheep to go to the center of mass of the group of nearby sheeps - Boids rules #1
func calc_direction_to_center_of_mass_nearby():
	var center = Vector2.ZERO
	for sheep in nearby_sheep:
		center += sheep.position
	center /= nearby_sheep.size()
	
	return position.direction_to(center) * center_factor


# will return a vector for the sheep to keep some distance with each other to avoid collidiong - Boids rules #2
func calc_direction_to_avoid_colliding_nearby():
	var avoid = position
	for sheep in nearby_sheep:
		if position.distance_to(sheep.position) <= min_distance_with_nearby:
			avoid -= position.direction_to(sheep.position)
	
	return position.direction_to(avoid) * avoid_factor


# will return a vector for the sheep to heads towards the same direction as the nearby sheeps - Boids rules #3
func calc_velocity_nearby():
	var avg_direction = Vector2.ZERO
	for sheep in nearby_sheep:
		avg_direction += sheep.direction
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
		return position.direction_to(shepherd.position) * shepherd_factor * shepherd.magnet_factor
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
	if hunger > 0 and targeted_grass == null and nearby_grass.size() > 0:
		var closest
		var distance = 99999
		for grass in nearby_grass:
			var calc_dist = position.distance_to(grass.position)
			if calc_dist < distance:
				closest = grass
				distance = calc_dist
		targeted_grass = closest
		
	return targeted_grass != null
		


func eat_grass():
	# play eating animation
	# wait a certain amount of time
	if targeted_grass.is_volatile:
		queue_free() # BOOM
	else:
		hunger -= 1
	
	targeted_grass.queue_free()
	targeted_grass = null


func _on_DetectionArea_body_entered(body):
	if body.is_in_group("sheeps"):
		nearby_sheep.append(body)
	elif body.is_in_group("shepherds"):
		shepherd = body


func _on_DetectionArea_body_exited(body):
	if body.is_in_group("sheeps"):
		nearby_sheep.erase(body)
	elif body.is_in_group("shepherds"):
		shepherd = null


func _on_UpdateMovementTimer_timeout():
	direction = (
		calc_direction_to_center_of_mass_nearby() +
		calc_direction_to_avoid_colliding_nearby() +
		calc_velocity_nearby() +
		calc_direction_to_nearest_grass() +
		calc_direction_to_shepherd() + 
		calc_direction_to_avoid_colliding_shepherd()
	).normalized()


func _on_DetectionArea_area_entered(area):
	if area.is_in_group("grass"):
		nearby_grass.append(area)


func _on_DetectionArea_area_exited(area):
	if area.is_in_group("grass"):
		nearby_grass.erase(area)
		if area == targeted_grass:
			targeted_grass = null
