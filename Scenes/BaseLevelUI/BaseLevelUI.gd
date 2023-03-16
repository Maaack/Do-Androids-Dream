extends Control


func show_scoring_screen():
	$ScoringScreen.show()

func hide_scoring_screen():
	$ScoringScreen.hide()

func _on_Button_pressed():
	show_scoring_screen()

func _on_ScoringScreen_done_pressed():
	hide_scoring_screen()
