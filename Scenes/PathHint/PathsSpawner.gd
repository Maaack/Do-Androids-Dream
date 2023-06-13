extends Node2D


export(PackedScene) var path_hint_scene : PackedScene = preload("res://Scenes/PathHint/PathHintType1.tscn")

func add_path(path_array : PoolVector2Array, start_position : Vector2 , end_position : Vector2, color : Color = Color.white):
	var path_hint_instance = path_hint_scene.instance()
	call_deferred("add_child", path_hint_instance)
	path_hint_instance.start_position = start_position
	path_hint_instance.end_position = end_position
	path_hint_instance.path_points = path_array
	path_hint_instance.color = color
	var tween = get_tree().create_tween()
	tween.tween_property(path_hint_instance, "modulate", Color.transparent, 1)
	yield(tween, "finished")
	path_hint_instance.queue_free()
