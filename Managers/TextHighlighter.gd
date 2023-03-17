extends Node

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

const ALL_SHEEP_NAMES : Array = [
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

var good_word_count : int = 0
var bad_word_count : int = 0
var entity_encounter_count : int = 0

func _highlight_word_with_color(haystack : String, needle : String, highlight : Color) -> String:
	var replace_text : String = "[color=#%s]%s[/color]" % [highlight.to_html(false), needle]
	return haystack.replace(needle, replace_text)

func _highlight_word_with_colorn(haystack : String, needle : String, highlight : Color) -> String:
	var replace_text : String = "[color=#%s]%s[/color]" % [highlight.to_html(false), needle]
	return haystack.replacen(needle, replace_text)

func highlight_dream(dream : String) -> String:
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
	return highlighted_text
