extends KinematicBody2D


var walk_speed = 10
var direction = Vector2.ZERO
var nearby_sheep = []


func _physics_process(delta):
	move_and_slide(direction * walk_speed)


# will return a vector for the sheep to go to the center of mass of the group of nearby sheeps
func calc_direction_to_center_of_mass_nearby():
	var center = Vector2.ZERO
	for sheep in nearby_sheep:
		center += sheep.position
	center /= nearby_sheep.size()
	
	return position.direction_to(center)


func _on_DetectionArea_body_entered(body):
	if body.is_in_group("sheeps"):
		nearby_sheep.append(body)


func _on_DetectionArea_body_exited(body):
	if body.is_in_group("sheeps"):
		nearby_sheep.erase(body)


func _on_UpdateMovementTimer_timeout():
	direction = calc_direction_to_center_of_mass_nearby()
