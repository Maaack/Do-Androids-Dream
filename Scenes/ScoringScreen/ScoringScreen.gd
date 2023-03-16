extends Control


signal done_pressed

func _on_DoneButton_pressed():
	emit_signal("done_pressed")
