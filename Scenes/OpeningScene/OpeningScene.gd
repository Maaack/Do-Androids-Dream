extends Control

export(String, FILE, "*.tscn") var next_scene : String

func next():
	SceneLoader.load_scene(next_scene)

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_select") or event.is_action_pressed("interact"):
		next()
		get_tree().set_input_as_handled()
