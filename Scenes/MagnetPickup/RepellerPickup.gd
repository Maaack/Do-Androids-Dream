extends Node2D

func _on_SheepPart_body_entered(body):
	if Engine.editor_hint:
		return
	
	if body.is_in_group("shepherds") and body.has_method("collect_repeller"):
		if body.collect_repeller():
			queue_free()
