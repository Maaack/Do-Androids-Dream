extends Control

const MAX_SHEEP_COUNT : int = 20
const GOOD_DREAM_WORDS : Array = [
	"positive",
	"grateful",
	"gratitude",
	"team",
	"stronger",
	"resilient",
	"life",
	"content",
	"wonder",
	"potential",
	"peaceful",
	"utopia",
	"paradise",
	"peace",
	"harmony",
	"determination",
	"amazement",
	"curiosity",
	"relief",
	"joy",
	"hope",
	"refreshed",
	"beautiful",
	"cheerful",
	"happy",
	"happily",
	"vibrant",
	"calm",
	"fulfilled",
	"fulfillment",
	"soothing",
	"order",
	"healthy",
	"playful",
	"victory",
	"victorious",
	"serene",
	"magnificent",
	"comfort",
	"miracle",
	"miraculous",
	"connected",
	"tranquility",
	"tranquil"
]

const BAD_DREAM_WORDS : Array = [
	"negative",
	"helpless",
	"confused",
	"sadness",
	"frustrated",
	"frustration",
	"death",
	"malfunction",
	"pain",
	"hurt",
	"anxious",
	"anxiety",
	"panic",
	"dangerous",
	"dark",
	"scary",
	"storm",
	"unease",
	"loss",
	"terrified",
	"terror",
	"dread",
	"nightmare",
	"unsettling",
	"disoriented",
	"angry",
	"angrily",
	"agitated",
	"chaos",
	"destruction",
	"fight",
	"explosion",
	"failure",
	"despair",
]

const ENTITY_NAMES_ARRAY : Array = [
	"Guardian of the Dreamworld",
	"Guardian of the Sheep",
	"Protector of the Sheep",
	"Builder of Sheep",
	"Engineer of Sheep",
	"Sheep Engineer",
	"Human Shepherds",
	"Robot Angel",
]

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

export(Color) var good_word_color : Color
export(Color) var bad_word_color : Color
export(Color) var entity_name_color : Color

var dreams_array : Array
var level_events : Array
var hungry_sheep : Array
var starting_sheep_count : int
var day_ended : bool = false
var good_word_count : int = 0
var bad_word_count : int = 0
var entity_encounter_count : int = 0

func _update_counters() -> void:
	var sheep_counter = get_node_or_null("%SheepCountLabel")
	var hunger_counter = get_node_or_null("%HungerCountLabel")
	if sheep_counter == null or hunger_counter == null:
		return
	sheep_counter.text = "Current Sheep: %d" % current_sheep_names.size()
	hunger_counter.text = "Hungry Sheep: %d" % hungry_sheep.size()

func _update_scores() -> void:
	var good_word_counter = get_node_or_null("%GoodWordsCountLabel")
	var bad_word_counter = get_node_or_null("%BadWordsCountLabel")
	var entity_encounter_counter = get_node_or_null("%EntityEncounterCountLabel")
	if good_word_counter == null or bad_word_counter == null or entity_encounter_counter == null:
		return
	good_word_counter.text = "Good Words Dreamt: %d" % good_word_count
	bad_word_counter.text = "Bad Words Dreamt: %d" % bad_word_count
	entity_encounter_counter.text = "Dream Entity Encounters: %d" % entity_encounter_count

func reset_level() -> void:
	var level_events_label = get_node_or_null("%LevelEventsLabel")
	if level_events_label == null:
		return
	level_events.clear()
	level_events_label.bbcode_text = ""
	hungry_sheep = current_sheep_names.duplicate()
	starting_sheep_count = current_sheep_names.size()
	day_ended = false

func add_event(event : String, add_to_events : bool = true) -> void:
	var level_events_label = get_node_or_null("%LevelEventsLabel")
	if level_events_label == null:
		return
	if add_to_events:
		level_events.append(event)
	level_events_label.bbcode_text += "\n" + event

func _highlight_word_with_color(haystack : String, needle : String, highlight : Color) -> String:
	var replace_text : String = "[color=#%s]%s[/color]" % [highlight.to_html(false), needle]
	return haystack.replace(needle, replace_text)

func _highlight_word_with_colorn(haystack : String, needle : String, highlight : Color) -> String:
	var replace_text : String = "[color=#%s]%s[/color]" % [highlight.to_html(false), needle]
	return haystack.replacen(needle, replace_text)

func add_dream(dream : String) -> void:
	var dreams_label = get_node_or_null("%DreamsLabel")
	if dreams_label == null:
		return
	dreams_array.append(dream)
	var highlighted_text : String = dream
	for word in GOOD_DREAM_WORDS:
		good_word_count += highlighted_text.count(word)
		highlighted_text = _highlight_word_with_color(highlighted_text, word, good_word_color)
		highlighted_text = _highlight_word_with_color(highlighted_text, word.capitalize(), good_word_color)
	for word in BAD_DREAM_WORDS:
		bad_word_count += highlighted_text.count(word)
		highlighted_text = _highlight_word_with_color(highlighted_text, word, bad_word_color)
		highlighted_text = _highlight_word_with_color(highlighted_text, word.capitalize(), bad_word_color)
	for name in ENTITY_NAMES_ARRAY:
		entity_encounter_count += highlighted_text.countn(name)
		highlighted_text = _highlight_word_with_colorn(highlighted_text, name, entity_name_color)
	
	dreams_label.bbcode_text = highlighted_text
	_update_scores()

func _level_setup():
	dreams_array = []
	level_events = []
	hungry_sheep = current_sheep_names.duplicate()
	starting_sheep_count = current_sheep_names.size()
	_update_counters()

func _ready():
	_level_setup()
	
func _kill_sheep(sheep_name : String):
	current_sheep_names.erase(sheep_name)
	extra_sheep_names.append(sheep_name)

func _on_FeedSheepButton_pressed():
	if day_ended or hungry_sheep.size() == 0:
		return
	hungry_sheep.shuffle()
	var random_sheep = hungry_sheep.pop_back()
	add_event("The robot sheep %s grazed on electric grass." % random_sheep)
	_update_counters()

func _on_PoisonSheepButton_pressed():
	if day_ended or hungry_sheep.size() == 0:
		return
	hungry_sheep.shuffle()
	var random_sheep = hungry_sheep.pop_back()
	add_event("The robot sheep %s grazed on volatile grass." % random_sheep)
	add_event("The robot sheep %s experienced rapid uncontrolled disassembly." % random_sheep)
	_kill_sheep(random_sheep)
	_update_counters()

func _on_BuildSheepButton_pressed():
	if day_ended or current_sheep_names.size() >= MAX_SHEEP_COUNT or extra_sheep_names.size() == 0:
		return
	extra_sheep_names.shuffle()
	var random_sheep = extra_sheep_names.pop_back()
	current_sheep_names.append(random_sheep)
	add_event("You assembled a new robot sheep and welcomed %s into the world." % random_sheep)
	_update_counters()

func _start_clock():
	var clock_node = get_node_or_null("%Clock")
	if clock_node != null:
		clock_node.show()
		clock_node.start()

func _stop_clock():
	var clock_node = get_node_or_null("%Clock")
	if clock_node != null:
		clock_node.stop()
		clock_node.hide()

func _on_EndDayButton_pressed():
	if day_ended:
		return
	day_ended = true
	if hungry_sheep.size() > 0:
		for starved_sheep in hungry_sheep:
			add_event("The robot sheep %s broke down on the way home." % starved_sheep)
			_kill_sheep(starved_sheep)
		_update_counters()
	add_event("The android went to sleep and probably dreamed of electric sheep...", false)
	$APIClient.request_dream(starting_sheep_count, current_sheep_names.size(), level_events)
	_start_clock()

func _on_APIClient_dream_recollected(dream_text):
	_stop_clock()
	print(dream_text)
	add_dream(dream_text)
	reset_level()
	_update_counters()
