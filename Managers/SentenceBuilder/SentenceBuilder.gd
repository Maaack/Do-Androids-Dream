extends Node

const EAT_NORMAL_GRASS_MESSAGE = "The robot sheep %s grazed on electric grass.\n"
const EAT_VOLATILE_GRASS_MESSAGE = "The robot sheep %s grazed on volatile grass.\n"
const EXPLODED_MESSAGE = "The robot sheep %s grazed on volatile grass and experienced rapid uncontrolled disassembly.\n"
const STARVE_MESSAGE = "The robot sheep %s didn't get enough grass, and broke down on the way home.\n"
const BUILD_MESSAGE = "The shepherd assembled new robot sheep and welcomed %s into the world.\n"
const MUSE_MESSAGE = "The shepherd mused, \"%s\".\n"

const CONCATENATE_CONTENT_EVENTS : Array = [
	EventData.EVENT_TYPES.EAT_NORMAL_GRASS,
	EventData.EVENT_TYPES.EAT_VOLATILE_GRASS,
	EventData.EVENT_TYPES.EXPLODE,
	EventData.EVENT_TYPES.STARVE,
	EventData.EVENT_TYPES.BUILD
]

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

func _get_sentence_for_event_type(event_type : int, contents : Array):
	var unique_contents : Array = []
	for content in contents:
		if not unique_contents.has(content):
			unique_contents.append(content)
	var content_part = _get_concatenated_string(unique_contents)
	match(event_type):
		EventData.EVENT_TYPES.EAT_NORMAL_GRASS:
			return EAT_NORMAL_GRASS_MESSAGE % content_part
		EventData.EVENT_TYPES.EAT_VOLATILE_GRASS:
			return EAT_VOLATILE_GRASS_MESSAGE % content_part
		EventData.EVENT_TYPES.EXPLODE:
			return EXPLODED_MESSAGE % content_part
		EventData.EVENT_TYPES.STARVE:
			return STARVE_MESSAGE % content_part
		EventData.EVENT_TYPES.BUILD:
			return BUILD_MESSAGE % content_part
		EventData.EVENT_TYPES.MUSE:
			return MUSE_MESSAGE % content_part
	return ""

func get_event_sentences(events_array : Array) -> String:
	var full_string : String = ""
	var last_event_type : int = 0
	var last_event_contents : Array = []
	for event in events_array:
		if event is EventData:
			if last_event_type != event.event_type and last_event_contents.size() > 0:
				full_string += _get_sentence_for_event_type(last_event_type, last_event_contents)
				last_event_contents.clear()
			last_event_type = event.event_type
			if CONCATENATE_CONTENT_EVENTS.has(event.event_type):
				last_event_contents.append(event.event_content)
			else:
				full_string += _get_sentence_for_event_type(event.event_type, [event.event_content])
	full_string += _get_sentence_for_event_type(last_event_type, last_event_contents)
	return full_string
