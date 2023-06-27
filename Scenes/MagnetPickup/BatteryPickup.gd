extends Node2D

func _on_SheepPart_body_entered(body):
	if Engine.editor_hint:
		return
	
	if body.is_in_group("shepherds") and body.has_method("collect_battery"):
		if body.collect_battery():
			queue_free()
