extends Node

signal dream_recollected(dream_text)

const FAILED_DREAM_MESSAGE : String = "That night the android shepherd was restless. In the morning, it could not remember any of its dreams.\n\n" \
	+ "(There was a problem getting your dream. Please try again later. We apologize that this is a dissappointing outcome, but ChatGPT shouldn't be this slow.\n\n" \
	+ "ChatGPT might actually be down: [url]https://platform.openai.com/[/url] )"
onready var _api_client = $APIClient

func _build_request_body(starting_sheep_count : int, ending_sheep_count : int, events_string : String) -> String:
	var api_user : String = _api_client.get_api_user()
	var messages : Array = [
		{
			"role": "system",
			"content": "You are a helpful assistant that can role-play."
		},
		{
			"role": "user",
			"content": "You will act the part of an android shepherd with the ability to dream. I will recite to you events that occurred to you during the day, and then I will ask you to describe your android's dreams that night from a first-person perspective."
		},
		{
			"role": "assistant",
			"content": "Okay, I can play the role of an android shepherd with the ability to dream. Please go ahead and recite the events that occurred to me during the day."
		},
	]

	# Build the last message based on the days events
	var last_content = "In the morning, you ventured out to herd your flock of %d robot sheep. "\
		+"%s "\
		+"You returned home with %d robot sheep. That night, you went to sleep and dreamed. "\
		+"Describe in one or two paragraphs from a first-person perspective, what did you dream about that night?"
	last_content = last_content % [starting_sheep_count, events_string, ending_sheep_count]

	var last_message : Dictionary = {
		"role": "user",
		"content": last_content
	}
	messages.append(last_message)

	# Set the request body with the complete messages dict
	var body_dict : Dictionary = {
		"messages": messages,
		"user": api_user
	}
	return JSON.print(body_dict)

func mock_request_dream(starting_sheep_count : int, ending_sheep_count : int, events_string : String):
	var _body : String = _build_request_body(starting_sheep_count, ending_sheep_count, events_string)
	_api_client.mock_request(_body)

func request_dream(starting_sheep_count : int, ending_sheep_count : int, events_string : String):
	var body : String = _build_request_body(starting_sheep_count, ending_sheep_count, events_string)
	_api_client.request(body)

func _on_APIClient_response_received(response_body):
	emit_signal("dream_recollected", response_body)

func _on_APIClient_request_failed(error):
	emit_signal("dream_recollected", FAILED_DREAM_MESSAGE)
