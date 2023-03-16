extends KinematicBody2D

export var walk_speed = 10 # speed of the sheep when walking
export var min_distance_with_nearby = 50 # minimum distance the sheep will try to keep with the others
export var center_factor = 1 # used to control the priority of the move to center direction
export var avoid_factor = 1 # used to control the priority of the move to avoid direction
export var avg_dir_factor = 1 # used to control the priority of the common direction
var direction = Vector2.ZERO
var nearby_sheep = []


func _physics_process(delta):
	move_and_slide(direction * walk_speed)


# will return a vector for the sheep to go to the center of mass of the group of nearby sheeps - Boids rules #1
func calc_direction_to_center_of_mass_nearby():
	var center = Vector2.ZERO
	for sheep in nearby_sheep:
		center += sheep.position
	center /= nearby_sheep.size()
	
	return position.direction_to(center)


# will return a vector for the sheep to keep some distance with each other to avoid collidiong - Boids rules #2
func calc_direction_to_avoid_colliding_nearby():
	var avoid = position
	for sheep in nearby_sheep:
		if position.distance_to(sheep.position) <= min_distance_with_nearby:
			avoid -= position.direction_to(sheep.position)
	
	return position.direction_to(avoid)


# will return a vector for the sheep to heads towards the same direction as the nearby sheeps - Boids rules #3
func calc_velocity_nearby():
	var avg_direction = Vector2.ZERO
	for sheep in nearby_sheep:
		avg_direction += sheep.direction
	avg_direction /= nearby_sheep.size()
	
	return avg_direction



func _on_DetectionArea_body_entered(body):
	if body.is_in_group("sheeps"):
		nearby_sheep.append(body)


func _on_DetectionArea_body_exited(body):
	if body.is_in_group("sheeps"):
		nearby_sheep.erase(body)


func _on_UpdateMovementTimer_timeout():
 direction = (
	calc_direction_to_center_of_mass_nearby() * center_factor
	+ calc_direction_to_avoid_colliding_nearby() * avoid_factor
	+ calc_velocity_nearby() * avg_dir_factor
).normalized()
