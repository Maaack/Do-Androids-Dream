tool
extends Area2D

signal shepherd_entered
signal sheep_entered(name)

export(Shape2D) var collider_shape : Shape2D setget set_collider_shape

func set_collider_shape(value : Shape2D) -> void:
	collider_shape = value
	$CollisionShape2D.shape = collider_shape

func _on_ShepherdDetectorArea2D_body_entered(body):
	if Engine.editor_hint:
		return
	if body.is_in_group("shepherds"):
		emit_signal("shepherd_entered")
	elif body.is_in_group("sheeps"):
		emit_signal("sheep_entered", body.sheep_name)
