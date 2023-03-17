extends Node

const EAT_NORMAL_GRASS_MESSAGE = "The robot sheep %s grazed on electric grass.\n"
const EAT_VOLATILE_GRASS_MESSAGE = "The robot sheep %s grazed on volatile grass.\n"
const EXPLODED_MESSAGE = "The robot sheep %s experienced rapid uncontrolled disassembly.\n"
const STARVE_MESSAGE = "The robot sheep %s didn't get enough grass, and broke down on the way home.\n"
const BUILD_MESSAGE = "You assembled new robot sheep and welcomed %s into the world.\n"

func _get_concatenated_string(subjects : Array) -> String:
	if subjects.size() == 0:
		return ""
	elif subjects.size() == 1:
		return subjects[0];
	elif subjects.size() == 2:
		return "%s and %s" % [subjects[0], subjects[1]]
	else:
		var last_subject = subjects.pop_back()
		var comma_separated_subjects = ", ".join(subjects)
		return "%s, and %s" % [comma_separated_subjects, last_subject]
	return ""
		
func _get_sentence_for_event_type(event_type : int, sheep_names : Array):
	var unique_sheep_names : Array = []
	for sheep_name in sheep_names:
		if not unique_sheep_names.has(sheep_name):
			unique_sheep_names.append(sheep_name)
	var sheep_name_part = _get_concatenated_string(unique_sheep_names)
	match(event_type):
		EventData.EVENT_TYPES.EAT_NORMAL_GRASS:
			return EAT_NORMAL_GRASS_MESSAGE % sheep_name_part
		EventData.EVENT_TYPES.EAT_VOLATILE_GRASS:
			return EAT_VOLATILE_GRASS_MESSAGE % sheep_name_part
		EventData.EVENT_TYPES.EXPLODE:
			return EXPLODED_MESSAGE % sheep_name_part
		EventData.EVENT_TYPES.STARVE:
			return STARVE_MESSAGE % sheep_name_part
		EventData.EVENT_TYPES.BUILD:
			return BUILD_MESSAGE % sheep_name_part
	return ""

func get_event_sentences(events_array : Array) -> String:
	var full_string : String = ""
	var last_event_type : int = 0
	var last_event_sheep_names : Array = []
	for event in events_array:
		if event is EventData:
			if last_event_type != event.event_type and last_event_sheep_names.size() > 0:
				full_string += _get_sentence_for_event_type(last_event_type, last_event_sheep_names)
				last_event_sheep_names.clear()
			last_event_type = event.event_type
			last_event_sheep_names.append(event.subject_sheep)
	full_string += _get_sentence_for_event_type(last_event_type, last_event_sheep_names)
	return full_string
