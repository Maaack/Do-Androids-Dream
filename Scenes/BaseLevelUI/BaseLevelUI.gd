extends Control


const MAX_SHEEP_COUNT : int = 20
var current_sheep_names : Array = [
	"Abby",
	"Ashley",
	"Barbara",
	"Betsy",
	"Cara",
	"Cutie",
	"Erin",
	"Lousie", 
	"Loren", 
	"Maggie",
	"Megan",
	"Nancy",
]

var extra_sheep_names : Array = [
	"Anna",
	"Angel",
	"Athena",
	"Aurora",
	"Marg",
	"Pretty",
	"Sweetie",
	"Tammy",
	"Zelda",
]

var hungry_sheep : Array
var starting_sheep_count : int = 0
var day_ended : bool = false
var game_events : Array = []

func reset_level() -> void:
	game_events.clear()
	hungry_sheep = current_sheep_names.duplicate()
	starting_sheep_count = current_sheep_names.size()
	day_ended = false

func _ready():
	reset_level()
	
func _kill_sheep(sheep_name : String):
	current_sheep_names.erase(sheep_name)
	extra_sheep_names.append(sheep_name)
	hungry_sheep.erase(sheep_name)

func add_event(event_type : int, subject_sheep : String) -> void:
	game_events.append(EventData.new(event_type, subject_sheep))

func add_feed_sheep_event(sheep):
	add_event(EventData.EVENT_TYPES.EAT_NORMAL_GRASS, sheep)
	hungry_sheep.erase(sheep)

func add_poison_sheep_event(sheep):
	add_event(EventData.EVENT_TYPES.EAT_VOLATILE_GRASS, sheep)
	hungry_sheep.erase(sheep)

func add_explode_sheep_event(sheep):
	add_event(EventData.EVENT_TYPES.EXPLODE, sheep)
	_kill_sheep(sheep)

func add_build_sheep_event(sheep):
	add_event(EventData.EVENT_TYPES.BUILD, sheep)
	extra_sheep_names.erase(sheep)
	current_sheep_names.append(sheep)

func add_sheep_starved_event(sheep):
	add_event(EventData.EVENT_TYPES.STARVE, sheep)
	_kill_sheep(sheep)

func _on_FeedSheepButton_pressed():
	if day_ended or hungry_sheep.size() == 0:
		return
	hungry_sheep.shuffle()
	var random_sheep = hungry_sheep[0]
	add_feed_sheep_event(random_sheep)

func _on_PoisonSheepButton_pressed():
	if day_ended or hungry_sheep.size() == 0:
		return
	hungry_sheep.shuffle()
	var random_sheep = hungry_sheep[0]
	add_poison_sheep_event(random_sheep)
	yield(get_tree().create_timer(3), "timeout")
	add_explode_sheep_event(random_sheep)

func _on_BuildSheepButton_pressed():
	if day_ended or current_sheep_names.size() >= MAX_SHEEP_COUNT or extra_sheep_names.size() == 0:
		return
	extra_sheep_names.shuffle()
	var random_sheep = extra_sheep_names[0]
	add_build_sheep_event(random_sheep)

func show_scoring_screen():
	$ScoringScreen.show()
	$ScoringScreen.start_dream_request(starting_sheep_count, current_sheep_names.size(), game_events)

func hide_scoring_screen():
	$ScoringScreen.hide()

func _on_ScoringScreen_done_pressed():
	hide_scoring_screen()
	reset_level()

func _on_EndDayButton_pressed():
	if day_ended:
		return
	day_ended = true
	if hungry_sheep.size() > 0:
		for starved_sheep in hungry_sheep:
			add_sheep_starved_event(starved_sheep)
	show_scoring_screen()
