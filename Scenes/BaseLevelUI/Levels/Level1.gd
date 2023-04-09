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
var tutorial_final_camp = preload("res://Scenes/TutorialScreen/Tutorials/Level1TutorialFinalCamp.tscn")
var tutorial_well_fed = preload("res://Scenes/TutorialScreen/Tutorials/Level1TutorialWellFed.tscn")

var oneshots_completed : Array = []
var sheep_exploded_count : int = 0

func play_tutorial_1():
	InGameMenuController.open_menu(tutorial_1)

func play_tutorial_2():
	InGameMenuController.open_menu(tutorial_2)
	
func play_tutorial_3():
	InGameMenuController.open_menu(tutorial_3)

func is_oneshot_completed(oneshot : String):
	return oneshots_completed.has(oneshot)

func complete_oneshot(oneshot : String):
	if is_oneshot_completed(oneshot):
		return
	oneshots_completed.append(oneshot)

func _on_World_sheep_part_collected():
	if is_oneshot_completed("sheep_part_collected"):
		return
	complete_oneshot("sheep_part_collected")
	InGameMenuController.open_menu(tutorial_sheep_part)

func _on_World_shepherd_entered_area(area_name):
	match area_name:
		"west_lands":
			if is_oneshot_completed("west_lands"):
				return
			complete_oneshot("west_lands")
			InGameMenuController.open_menu(tutorial_west_lands)
		"first_camp":
			if current_day > 0 or is_oneshot_completed("first_camp"):
				return
			complete_oneshot("first_camp")
			InGameMenuController.open_menu(tutorial_first_camp)
		"second_camp":
			if current_day > 1 or is_oneshot_completed("second_camp"):
				return
			complete_oneshot("second_camp")
			InGameMenuController.open_menu(tutorial_second_camp)
		"final_camp":
			if is_oneshot_completed("final_camp"):
				return
			complete_oneshot("final_camp")
			destination_reached = true
			InGameMenuController.open_menu(tutorial_final_camp)
		"well_fed_hint":
			if is_oneshot_completed("well_fed_hint"):
				return
			complete_oneshot("well_fed_hint")
			InGameMenuController.open_menu(tutorial_well_fed)
		"crossroads":
			if is_oneshot_completed("crossroads"):
				return
			complete_oneshot("crossroads")
			show_entering_area("The Crossroads")
		"alpha_pasture":
			if is_oneshot_completed("alpha_pasture"):
				return
			complete_oneshot("alpha_pasture")
			show_entering_area("Alpha Pasture")
		"beta_pasture":
			if is_oneshot_completed("beta_pasture"):
				return
			complete_oneshot("beta_pasture")
			show_entering_area("Beta Pasture")
		"delta_pasture":
			if is_oneshot_completed("delta_pasture"):
				return
			complete_oneshot("delta_pasture")
			show_entering_area("Delta Pasture")
		"barren_limit":
			if is_oneshot_completed("barren_limit"):
				return
			complete_oneshot("barren_limit")
			show_entering_area("Barren Limit")
		"volatile_pastures":
			if is_oneshot_completed("volatile_pastures"):
				return
			complete_oneshot("volatile_pastures")
			show_entering_area("Volatile Pastures")
		"winding_circuit":
			if is_oneshot_completed("winding_circuit"):
				return
			complete_oneshot("winding_circuit")
			show_entering_area("Winding Circuit")

func _on_World_sheep_ate_volatile_grass(sheep_name):
	if is_oneshot_completed("sheep_poisoned"):
		return
	complete_oneshot("sheep_poisoned")
	var tutorial = InGameMenuController.open_menu(tutorial_sheep_poisoned)
	tutorial.set_sheep_name(sheep_name)
	._on_World_sheep_ate_volatile_grass(sheep_name)

func _on_World_sheep_exploded(sheep_name):
	sheep_exploded_count += 1
	if sheep_exploded_count == 4:
		InGameMenuController.open_menu(tutorial_sheep_exploding)
	._on_World_sheep_exploded(sheep_name)
