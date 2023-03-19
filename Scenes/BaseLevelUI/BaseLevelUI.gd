extends Control


const MAX_SHEEP_COUNT : int = 20
const ALL_SHEEP_NAMES : Array = [
	"Abby",
	"Angel",
	"Anna",
	"Ashley",
	"Athena",
	"Aurora",
	"Barbara",
	"Betsy",
	"Cara",
	"Cutie",
	"Erin",
	"Loren",
	"Lousie",
	"Maggie",
	"Marg",
	"Megan",
	"Nancy",
	"Pretty",
	"Sweetie",
	"Tammy",
	"Zelda",
]

export(int) var starting_sheep_count : int = 6

var current_sheep_names : Array = []
var extra_sheep_names : Array = []
var hungry_sheep : Array = []
var day_ended : bool = false
var game_events : Array = []

func reset_level() -> void:
	game_events.clear()
	extra_sheep_names = ALL_SHEEP_NAMES.duplicate()
	extra_sheep_names.shuffle()
	while current_sheep_names.size() < starting_sheep_count:
		current_sheep_names.append(extra_sheep_names.pop_back())
	hungry_sheep = current_sheep_names.duplicate()
	$"%World".reset_world()
	for sheep in current_sheep_names:
		$"%World".add_sheep(sheep)
	day_ended = false
	$"%Clock".start()

func _ready():
	reset_level()

func _end_day():
	if day_ended:
		return
	day_ended = true
	get_tree().paused = true
	if hungry_sheep.size() > 0:
		var starved_sheep = hungry_sheep.duplicate()
		for sheep_name in starved_sheep:
			add_sheep_starved_event(sheep_name)
	show_scoring_screen()

func _check_level_end():
	if hungry_sheep.size() == 0:
		_end_day()

func _kill_sheep(sheep_name : String):
	current_sheep_names.erase(sheep_name)
	extra_sheep_names.append(sheep_name)
	hungry_sheep.erase(sheep_name)
	_check_level_end()

func add_event(event_type : int, subject_sheep : String) -> void:
	game_events.append(EventData.new(event_type, subject_sheep))

func add_feed_sheep_event(sheep_name):
	add_event(EventData.EVENT_TYPES.EAT_NORMAL_GRASS, sheep_name)
	hungry_sheep.erase(sheep_name)
	_check_level_end()

func add_poison_sheep_event(sheep_name):
	pass
	# add_event(EventData.EVENT_TYPES.EAT_VOLATILE_GRASS, sheep_name)

func add_explode_sheep_event(sheep_name):
	add_event(EventData.EVENT_TYPES.EXPLODE, sheep_name)
	_kill_sheep(sheep_name)

func add_build_sheep_event(sheep_name):
	add_event(EventData.EVENT_TYPES.BUILD, sheep_name)
	extra_sheep_names.erase(sheep_name)
	current_sheep_names.append(sheep_name)

func add_sheep_starved_event(sheep_name):
	add_event(EventData.EVENT_TYPES.STARVE, sheep_name)
	_kill_sheep(sheep_name)

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
	$BackgroundMusic.stop()
	$DreamMusic.play()
	$ScoringScreen.show()
	$ScoringScreen.start_dream_request(starting_sheep_count, current_sheep_names.size(), game_events)

func hide_scoring_screen():
	$ScoringScreen.hide()

func _on_ScoringScreen_done_pressed():
	SceneLoader.load_scene("res://Scenes/Credits/EndCredits.tscn")

func _on_ScoringScreen_restart_pressed():
	SceneLoader.reload_current_scene()

func _on_EndDayButton_pressed():
	_end_day()
	show_scoring_screen()

func _on_World_sheep_ate_normal_grass(sheep_name):
	add_feed_sheep_event(sheep_name)

func _on_World_sheep_ate_volatile_grass(sheep_name):
	add_poison_sheep_event(sheep_name)

func _on_World_sheep_exploded(sheep_name):
	add_explode_sheep_event(sheep_name)

func _on_Clock_timeout():
	_end_day()
