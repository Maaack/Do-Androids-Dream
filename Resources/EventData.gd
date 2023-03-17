extends Resource
class_name EventData

enum EVENT_TYPES{
	NONE,
	EAT_NORMAL_GRASS,
	EAT_VOLATILE_GRASS,
	EXPLODE,
	STARVE,
	BUILD
}

export(EVENT_TYPES) var event_type : int = EVENT_TYPES.NONE
export(String) var subject_sheep : String

func _init(init_event_type, init_subject_sheep):
	event_type = init_event_type
	subject_sheep = init_subject_sheep
