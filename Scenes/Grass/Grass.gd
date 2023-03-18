extends Area2D


var being_eaten = false


# Called when the node enters the scene tree for the first time.
func _ready():
	pass # Replace with function body.


# Called every frame. 'delta' is the elapsed time since the previous frame.
#func _process(delta):
#	pass


func _on_Grass_body_entered(body):
	if body.is_in_group("sheeps") and being_eaten == false and body.targeted_grass == self:
		being_eaten = true
		body.eat_grass()
