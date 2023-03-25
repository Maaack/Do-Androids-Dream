extends Node2D

const TOTAL_FRAMES = 6

export(Array, Texture) var spritesheets : Array = []
export(int, 0) var max_frames : int = 6

func _on_SheepPart_body_entered(body):
	if Engine.editor_hint:
		return
	
	if body.is_in_group("shepherds") and body.has_method("collect_part"):
		if body.collect_part():
			queue_free()

func _ready():
	randomize()
	$Sprite.texture = spritesheets[randi() % spritesheets.size()]
	$Sprite.frame = randi() % max_frames
