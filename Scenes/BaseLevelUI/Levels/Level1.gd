extends BaseLevel

var welcome_screen = preload("res://Scenes/TutorialScreen/Tutorials/Welcome.tscn")
var tutorial_sheep_part = preload("res://Scenes/TutorialScreen/Tutorials/Level1TutorialSheepPart.tscn")
var tutorial_west_lands = preload("res://Scenes/TutorialScreen/Tutorials/Level1TutorialWestLands.tscn")
var tutorial_sheep_poisoned = preload("res://Scenes/TutorialScreen/Tutorials/Level1TutorialSheepPoisoned.tscn")
var tutorial_sheep_exploding = preload("res://Scenes/TutorialScreen/Tutorials/Level1TutorialSheepExploding.tscn")
var tutorial_first_camp = preload("res://Scenes/TutorialScreen/Tutorials/Level1TutorialFirstCamp.tscn")
var tutorial_second_camp = preload("res://Scenes/TutorialScreen/Tutorials/Level1TutorialSecondCamp.tscn")
var tutorial_final_camp = preload("res://Scenes/TutorialScreen/Tutorials/Level1TutorialFinalCamp.tscn")
var tutorial_well_fed = preload("res://Scenes/TutorialScreen/Tutorials/Level1TutorialWellFed.tscn")
var battery_pickup_screen = preload("res://Scenes/TutorialScreen/Tutorials/BatteryPickup.tscn")
var magnet_pickup_screen = preload("res://Scenes/TutorialScreen/Tutorials/MagnetPickup.tscn")
var repeller_pickup_screen = preload("res://Scenes/TutorialScreen/Tutorials/RepellerPickup.tscn")
var unpowered_sheep_screen = preload("res://Scenes/TutorialScreen/Tutorials/UnpoweredSheep.tscn")
var charge_sheep_screen = preload("res://Scenes/TutorialScreen/Tutorials/ChargeSheep.tscn")
var grasses_explanation_screen = preload("res://Scenes/TutorialScreen/Tutorials/GrassesExplanation.tscn")
var goal_explanation_screen = preload("res://Scenes/TutorialScreen/Tutorials/GoalExplanation.tscn")
var new_sheep_screen = preload("res://Scenes/TutorialScreen/Tutorials/NewSheepInFlock.tscn")
var swapping_explanation_screen = preload("res://Scenes/TutorialScreen/Tutorials/SwappingExplanation.tscn")
var catch_runaway_screen = preload("res://Scenes/TutorialScreen/Tutorials/CatchRunaway.tscn")
var glitch_in_matrix_screen = preload("res://Scenes/TutorialScreen/Tutorials/GlitchInMatrix.tscn")
var end_of_day_screen = preload("res://Scenes/TutorialScreen/Tutorials/EndOfDay.tscn")

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
	"watchers_gate" : "Watchers Gate",
}

enum Goals {
	GET_BATTERY,
	POWER_SHEEP,
	GET_MAGNET,
	GO_TO_DELTA,
}

func play_welcome_screen():
	InGameMenuController.open_menu(welcome_screen)
	goal_active = true

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
		"unpowered_sheep":
			if not is_oneshot_completed("unpowered_sheep"):
				complete_oneshot("unpowered_sheep")
				InGameMenuController.open_menu(unpowered_sheep_screen)
		"power_sheep":
			var battery_equipped : bool = $"%World".get_shepherd().is_battery_equipped() 
			if not is_oneshot_completed("charge_sheep") and battery_equipped:
				complete_oneshot("charge_sheep")
				InGameMenuController.open_menu(charge_sheep_screen)
				$"%World".get_shepherd().equipped_activation_enabled = true
		"catch_runaway":
			if not is_oneshot_completed("catch_runaway") and not is_oneshot_completed("new_sheep"):
				complete_oneshot("catch_runaway")
				InGameMenuController.open_menu(catch_runaway_screen)
		"warp_back":
			if not is_oneshot_completed("new_sheep"):
				$"%World".warp_back_shepherd()
				InGameMenuController.open_menu(glitch_in_matrix_screen)

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
	InGameMenuController.open_menu(magnet_pickup_screen)
	$"%World".set_current_goal(Goals.GO_TO_DELTA)
	$SwappingExplanationTimer.start()

func _on_World_battery_collected():
	if is_oneshot_completed("battery_collected"):
		# Battery already collected once
		$SwappingExplanationTimer.start()
		return
	complete_oneshot("battery_collected")
	InGameMenuController.open_menu(battery_pickup_screen)
	$"%World".set_current_goal(Goals.POWER_SHEEP)

func _on_World_repeller_collected():
	if is_oneshot_completed("repeller_collected"):
		return
	complete_oneshot("repeller_collected")
	InGameMenuController.open_menu(repeller_pickup_screen)
	$SwappingExplanationTimer.start()

func _on_World_new_sheep(sheep_instance : Sheep):
	._on_World_new_sheep(sheep_instance)
	if is_oneshot_completed("new_sheep"):
		return
	complete_oneshot("new_sheep")
	InGameMenuController.open_menu(new_sheep_screen)
	goal_active = false
	$GrassExplanationTimer.start()

func _on_GrassExplanationTimer_timeout():
	if is_oneshot_completed("grass_explanation"):
		return
	complete_oneshot("grass_explanation")
	InGameMenuController.open_menu(grasses_explanation_screen)
	$GoalExplanationTimer.start()

func _on_GoalTimer_timeout():
	if is_oneshot_completed("goal_explanation"):
		return
	complete_oneshot("goal_explanation")
	InGameMenuController.open_menu(goal_explanation_screen)
	$"%World".set_current_goal(Goals.GET_MAGNET)
	goal_active = true
	_start_day_clock()

func _on_SwappingExplanationTimer_timeout():
	if is_oneshot_completed("swapping_explanation"):
		return
	complete_oneshot("swapping_explanation")
	InGameMenuController.open_menu(swapping_explanation_screen)
	$"%World".get_shepherd().equipped_swapping_enabled = true

func _end_day():
	._end_day()
	if is_oneshot_completed("first_day_ended"):
		return
	complete_oneshot("first_day_ended")
	InGameMenuController.open_menu(end_of_day_screen)

func _on_World_battery_discharged():
	if is_oneshot_completed("battery_discharged"):
		return
	complete_oneshot("battery_discharged")
	$"%World".set_current_goal(Goals.GET_MAGNET)
	goal_active = false
