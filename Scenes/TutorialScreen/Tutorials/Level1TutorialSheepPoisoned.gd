extends "res://Scenes/TutorialScreen/TutorialScreen.gd"

const TUTORIAL_TEXT = "Uh oh! The robot sheep %s just ate some volatile grass.\n\n\nThis wont end well..."

func set_sheep_name(sheep_name : String):
	$Control/NinePatchRect/MarginContainer/PanelContainer/TutorialText.text = TUTORIAL_TEXT % sheep_name
	
