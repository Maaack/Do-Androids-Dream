extends CanvasLayer

var sheep_list : Array = [] setget set_sheep_list
var sheep_edit_panel_scene = preload("res://Scenes/SheepEditor/SheepEditPanel.tscn")

func _clear_container():
	for child in $"%GridContainer".get_children():
		child.queue_free()

func set_sheep_list(new_values : Array):
	sheep_list = new_values
	_clear_container()
	for sheep_instance in sheep_list:
		var sheep_edit_instance = sheep_edit_panel_scene.instance()
		$"%GridContainer".add_child(sheep_edit_instance)
		sheep_edit_instance.sheep_instance = sheep_instance

func _on_DonePressed_pressed():
	InGameMenuController.close_menu()
