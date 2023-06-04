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
var tutorial_magnet = preload("res://Scenes/TutorialScreen/Tutorials/Level1TutorialMagnet.tscn")

var oneshots_completed : Array = []
var sheep_exploded_count : int = 0
var area_names_map : Dictionary = {
	"crossroads" : "The Crossroads",
	"alpha_pasture" : "Alpha Pasture",
	"beta_pasture" : "Beta Pasture",
	"delta_pasture" : "Delta Pasture",
	"barren_limit" : "The Barren Limit",
	"volatile_pastures" : "Volatile Pastures",
	"winding_circuit" : "The Winding Circuit",
}

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

func _enter_area_event(area_name : String) -> bool:
	if not area_names_map.has(area_name):
		return false
	if is_oneshot_completed(area_name):
		return false
	complete_oneshot(area_name)
	var area_readable_name : String = area_names_map[area_name]
	show_entering_area(area_readable_name)
	add_shephered_entered_area_event(area_readable_name)
	return true

func _on_World_shepherd_entered_area(area_name):
	if _enter_area_event(area_name):
		return
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

func _on_World_sheep_ate_volatile_grass(sheep_instance):
	if is_oneshot_completed("sheep_poisoned"):
		return
	complete_oneshot("sheep_poisoned")
	var tutorial = InGameMenuController.open_menu(tutorial_sheep_poisoned)
	tutorial.set_sheep_name(sheep_instance.get_readable_name())
	._on_World_sheep_ate_volatile_grass(sheep_instance)

func _on_World_sheep_exploded(sheep_instance):
	sheep_exploded_count += 1
	if sheep_exploded_count == 4:
		InGameMenuController.open_menu(tutorial_sheep_exploding)
	._on_World_sheep_exploded(sheep_instance)

func _on_World_magnet_collected():
	if is_oneshot_completed("magnet_collected"):
		return
	complete_oneshot("magnet_collected")
	InGameMenuController.open_menu(tutorial_magnet)
