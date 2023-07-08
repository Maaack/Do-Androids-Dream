extends CanvasLayer

var can_close : bool = false

func _force_close():
	InGameMenuController.close_menu()

func _close():
	if not can_close:
		return
	_force_close()

func _unhandled_input(event):
	if event.is_action_pressed("ui_cancel") or event.is_action_pressed("ui_select") or event.is_action_pressed("interact"):
		_close()
		get_tree().set_input_as_handled()

func _on_ResumeButton_pressed():
	_force_close()

func _on_CloseDelayTimer_timeout():
	can_close = true
