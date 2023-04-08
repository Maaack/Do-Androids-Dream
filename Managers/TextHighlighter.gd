extends Node

const GOOD_DREAM_WORDS : Array = [
	"amazement",
	"amazing",
	"appreciate",
	"appreciative",
	"appreciating",
	"awe",
	"beautiful",
	"calm",
	"cheerful",
	"comfort",
	"connected",
	"content",
	"curiosity",
	"determination",
	"excitement",
	"exhilarating",
	"exhilaration",
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
	"laugh",
	"life",
	"love",
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
	"pride",
	"recharged",
	"refreshed",
	"reinvigorated",
	"rejuvinated",
	"relief",
	"relieved",
	"renewed",
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
	"alone",
	"angrily",
	"angry",
	"anxiety",
	"anxious",
	"chaos",
	"confused",
	"danger",
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
	"horrible",
	"horror",
	"hurt",
	"loss",
	"malfunction",
	"negative",
	"nightmare",
	"pain",
	"panic",
	"sadness",
	"scary",
	"struggle",
	"struggling",
	"storm",
	"terrified",
	"terror",
	"unease",
	"uneasy",
	"unsettled",
	"unsettling",
]

const ENTITY_NAMES_ARRAY : Array = [
	"The Creator",
	"Guardian of the Dreamworld",
	"Guardian of the Sheep",
	"Protector of the Sheep",
	"Builder of Sheep",
	"Engineer of Sheep",
	"Sheep Engineer",
	"Human Shepherds",
	"Robot Angel",
	"Robot Owl",
	"Electronic Tree",
	"Humanoid Robot",
	"Humanoid Android",
]

const MANIFESTATIONS_OF_FEAR_ARRAY : Array = [
	"Robot Wolf",
	"Robot Wolves",
	"Robotic Wolf",
	"Robotic Wolves",
	"Wild Wolves",
	"Rogue Sheep",
	"Unidentified Presence",
	"Lurking Stranger",
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

func _bold_word(haystack : String, needle : String) -> String:
	var replace_text : String = "[b]%s[/b]" % needle
	return haystack.replace(needle, replace_text)

func highlight_dream(dream : String) -> String:
	good_word_count = 0
	bad_word_count = 0
	dream_entity_count = 0
	fear_manifestation_count = 0
	var highlighted_text : String = dream
	for word in GOOD_DREAM_WORDS:
		good_word_count += highlighted_text.countn(word)
		highlighted_text = _highlight_word_with_color(highlighted_text, word, good_word_color)
		highlighted_text = _highlight_word_with_color(highlighted_text, word.capitalize(), good_word_color)
	for word in BAD_DREAM_WORDS:
		bad_word_count += highlighted_text.countn(word)
		highlighted_text = _highlight_word_with_color(highlighted_text, word, bad_word_color)
		highlighted_text = _highlight_word_with_color(highlighted_text, word.capitalize(), bad_word_color)
	for word in ENTITY_NAMES_ARRAY:
		dream_entity_count += int(highlighted_text.findn(word) != -1)
		highlighted_text = _highlight_word_with_colorn(highlighted_text, word, dream_entity_color)
	for word in MANIFESTATIONS_OF_FEAR_ARRAY:
		fear_manifestation_count += int(highlighted_text.findn(word) != -1)
		highlighted_text = _highlight_word_with_colorn(highlighted_text, word, fear_manifestation_color)
	for sheep_name in SheepConstants.NAMES:
		highlighted_text = _bold_word(highlighted_text, sheep_name)
	return highlighted_text
