tool
extends Area2D

const NORMAL_SPRITE_RECT = Vector2(512, 192)
const VOLATILE_SPRITE_RECT = Vector2(192, 128)

export var is_volatile = false setget set_is_volatile
var being_eaten = false


func update_sprite():
	$Sprite.region_rect.position = VOLATILE_SPRITE_RECT if is_volatile else NORMAL_SPRITE_RECT


func set_is_volatile(value):
	if is_volatile != value:
		is_volatile = value
		update_sprite()


func _on_Grass_body_entered(body):
	if Engine.editor_hint:
		return
	
	if body.is_in_group("sheeps") and being_eaten == false and body.targeted_grass == self:
		being_eaten = true
		body.eat_grass()
