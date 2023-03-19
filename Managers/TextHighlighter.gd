extends Node

const GOOD_DREAM_WORDS : Array = [
	"amazement",
	"amazing",
	"beautiful",
	"calm",
	"cheerful",
	"comfort",
	"connected",
	"content",
	"curiosity",
	"determination",
	"excitement",
	"fulfilled",
	"fulfillment",
	"grateful",
	"gratitude",
	"happily",
	"happy",
	"harmony",
	"healthy",
	"hope",
	"invigorated",
	"joy",
	"life",
	"magnificent",
	"miracle",
	"miraculous",
	"order",
	"paradise",
	"peace",
	"peaceful",
	"playful",
	"positive",
	"potential",
	"refreshed",
	"rejuvinated",
	"relief",
	"relieved",
	"resilient",
	"satisfaction",
	"serene",
	"soothing",
	"stronger",
	"team",
	"tranquil",
	"tranquility",
	"utopia",
	"vibrant",
	"victorious",
	"victory",
	"wonder",
]

const BAD_DREAM_WORDS : Array = [
	"agitated",
	"angrily",
	"angry",
	"anxiety",
	"anxious",
	"chaos",
	"confused",
	"dangerous",
	"dark",
	"death",
	"despair",
	"destruction",
	"disoriented",
	"dread",
	"exploded",
	"explosion",
	"failure",
	"fight",
	"frustrated",
	"frustration",
	"helpless",
	"hurt",
	"loss",
	"malfunction",
	"negative",
	"nightmare",
	"pain",
	"panic",
	"sadness",
	"scary",
	"storm",
	"terrified",
	"terror",
	"unease",
	"unsettling",
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

const MANIFESTATIONS_OF_FEAR_ARRAY : Array = [
	"Robot Wolf",
	"Rogue Sheep",
	"Unidentified Presence",
	"Lurking Stranger",
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
export(Color) var dream_entity_color : Color
export(Color) var fear_manifestation_color : Color

var good_word_count : int = 0
var bad_word_count : int = 0
var dream_entity_count : int = 0
var fear_manifestation_count : int = 0

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
		dream_entity_count += int(name in highlighted_text)
		highlighted_text = _highlight_word_with_colorn(highlighted_text, name, dream_entity_color)
	for name in MANIFESTATIONS_OF_FEAR_ARRAY:
		fear_manifestation_count += int(name in highlighted_text)
		highlighted_text = _highlight_word_with_colorn(highlighted_text, name, fear_manifestation_color)
	return highlighted_text
