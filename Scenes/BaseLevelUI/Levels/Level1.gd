extends "res://Scenes/BaseLevelUI/BaseLevelUI.gd"

var tutorial_1 = preload("res://Scenes/TutorialScreen/Tutorials/Level1Tutorial1.tscn")
var tutorial_2 = preload("res://Scenes/TutorialScreen/Tutorials/Level1Tutorial2.tscn")
var tutorial_3 = preload("res://Scenes/TutorialScreen/Tutorials/Level1Tutorial3.tscn")

func play_tutorial_1():
	InGameMenuController.open_menu(tutorial_1)

func play_tutorial_2():
	InGameMenuController.open_menu(tutorial_2)
	
func play_tutorial_3():
	InGameMenuController.open_menu(tutorial_3)
