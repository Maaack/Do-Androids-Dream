extends Resource
class_name EventData

enum EVENT_TYPES{
	NONE,
	EAT_NORMAL_GRASS,
	EAT_VOLATILE_GRASS,
	EXPLODE,
	STARVE,
	BUILD,
	POWER,
	MUSE,
	DREAM,
	ENTER_AREA,
}

export(EVENT_TYPES) var event_type : int = EVENT_TYPES.NONE
export(String) var event_content : String
export(String) var custom_event_content : String

func _init(init_event_type, init_event_content, init_custom_event_content = ""):
	event_type = init_event_type
	event_content = init_event_content
	custom_event_content = init_custom_event_content
