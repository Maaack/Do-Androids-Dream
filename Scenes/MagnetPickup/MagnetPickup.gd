extends Node2D

const TOTAL_FRAMES = 6

export(Array, Texture) var spritesheets : Array = []
export(int, 0) var max_frames : int = 6

func _on_SheepPart_body_entered(body):
	if Engine.editor_hint:
		return
	
	if body.is_in_group("shepherds") and body.has_method("collect_magnet"):
		if body.collect_magnet():
			queue_free()
