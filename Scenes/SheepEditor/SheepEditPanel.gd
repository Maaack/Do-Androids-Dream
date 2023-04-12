extends Panel


var sheep_instance : Node2D setget set_sheep_instance

func set_sheep_instance(new_instance : Node2D):
	sheep_instance = new_instance
	if sheep_instance.is_in_group("sheeps"):
		$"%SheepNameEdit".text = sheep_instance.sheep_name

func _on_SheepNameEdit_text_changed(new_text):
	if sheep_instance.is_in_group("sheeps"):
		sheep_instance.sheep_name = new_text