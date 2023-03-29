extends Resource
class_name EventData

enum EVENT_TYPES{
	NONE,
	EAT_NORMAL_GRASS,
	EAT_VOLATILE_GRASS,
	EXPLODE,
	STARVE,
	BUILD,
	MUSE
}

export(EVENT_TYPES) var event_type : int = EVENT_TYPES.NONE
export(String) var event_content : String

func _init(init_event_type, init_event_content):
	event_type = init_event_type
	event_content = init_event_content
