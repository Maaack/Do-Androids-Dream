tool
extends Area2D

export var is_volatile = false setget set_is_volatile
var being_eaten = false

func set_is_volatile(value):
	if is_volatile != value:
		is_volatile = value
		$VolatileSprite.show()

func _on_Grass_body_entered(body):
	if Engine.editor_hint:
		return
	
	if body.is_in_group("sheeps") and being_eaten == false and body.targeted_grass == self:
		being_eaten = true
		body.eat_grass()

func _ready():
	var frame : int = randi() % 3
	$NormalSprite.frame = frame
	$VolatileSprite.frame = frame
