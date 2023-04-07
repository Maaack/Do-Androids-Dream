extends BaseLevel

var tutorial_1 = preload("res://Scenes/TutorialScreen/Tutorials/Level1Tutorial1.tscn")
var tutorial_2 = preload("res://Scenes/TutorialScreen/Tutorials/Level1Tutorial2.tscn")
var tutorial_3 = preload("res://Scenes/TutorialScreen/Tutorials/Level1Tutorial3.tscn")
var tutorial_sheep_part = preload("res://Scenes/TutorialScreen/Tutorials/Level1TutorialSheepPart.tscn")
var tutorial_west_lands = preload("res://Scenes/TutorialScreen/Tutorials/Level1TutorialWestLands.tscn")
var tutorial_sheep_poisoned = preload("res://Scenes/TutorialScreen/Tutorials/Level1TutorialSheepPoisoned.tscn")
var tutorial_sheep_exploding = preload("res://Scenes/TutorialScreen/Tutorials/Level1TutorialSheepExploding.tscn")
var tutorial_first_camp = preload("res://Scenes/TutorialScreen/Tutorials/Level1TutorialFirstCamp.tscn")
var tutorial_second_camp = preload("res://Scenes/TutorialScreen/Tutorials/Level1TutorialSecondCamp.tscn")

var sheep_part_collected : bool = false
var shepherd_entered_west_lands : bool = false
var shepherd_entered_first_camp : bool = false
var shepherd_entered_second_camp : bool = false
var sheep_poisoned : bool = false
var sheep_exploded_count : int = 0

func play_tutorial_1():
	InGameMenuController.open_menu(tutorial_1)

func play_tutorial_2():
	InGameMenuController.open_menu(tutorial_2)
	
func play_tutorial_3():
	InGameMenuController.open_menu(tutorial_3)

func _on_World_sheep_part_collected():
	if sheep_part_collected:
		return
	sheep_part_collected = true
	InGameMenuController.open_menu(tutorial_sheep_part)

func _on_World_shepherd_entered_area(area_name):
	match area_name:
		"west_lands":
			if shepherd_entered_west_lands:
				return
			shepherd_entered_west_lands = true
			InGameMenuController.open_menu(tutorial_west_lands)
		"first_camp":
			if current_day > 0 or shepherd_entered_first_camp:
				return
			shepherd_entered_first_camp = true
			InGameMenuController.open_menu(tutorial_first_camp)
		"second_camp":
			if current_day > 1 or shepherd_entered_second_camp:
				return
			shepherd_entered_second_camp = true
			InGameMenuController.open_menu(tutorial_second_camp)

func _on_World_sheep_ate_volatile_grass(sheep_name):
	if sheep_poisoned:
		return
	sheep_poisoned = true
	var tutorial = InGameMenuController.open_menu(tutorial_sheep_poisoned)
	tutorial.set_sheep_name(sheep_name)
	._on_World_sheep_ate_volatile_grass(sheep_name)

func _on_World_sheep_exploded(sheep_name):
	sheep_exploded_count += 1
	if sheep_exploded_count == 4:
		InGameMenuController.open_menu(tutorial_sheep_exploding)
	._on_World_sheep_exploded(sheep_name)
