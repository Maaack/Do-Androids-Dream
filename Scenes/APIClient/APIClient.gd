extends Node

signal dream_recollected(dream_text)

const PROXY_API_URL = "https://dk7cqkgzlc.execute-api.us-east-1.amazonaws.com/prod/chat-completions"
const FAILED_DREAM_MESSAGE : String = "That night the android shepherd was restless. In the morning, it could not remember any of its dreams.\n\n" \
	+ "(There was a problem getting your dream. Please try again later. We apologize that this is a dissappointing outcome, but ChatGPT shouldn't be this slow.\n\n" \
	+ "ChatGPT might actually be down: [url]https://platform.openai.com/[/url] )"
onready var _http_request = $HTTPRequest

func get_http_request():
	return _http_request

func get_api_key() -> String:
	var file = File.new()
	var error = file.open("res://API_KEY_SECRET.txt", File.READ)
	if error != OK:
		push_error("An error occurred in the API Key reading. %d" % error)

	var content = file.get_as_text()
	file.close()
	return content

func get_api_url() -> String:
	return PROXY_API_URL

func get_api_user() -> String:
	return "%s %s" % [OS.get_locale_language(), OS.get_name()]

func get_api_method() -> int:
	return HTTPClient.METHOD_POST

func _build_request_body(starting_sheep_count : int, ending_sheep_count : int, events_string : String) -> String:
	var api_user : String = get_api_user()
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
	yield(get_tree().create_timer(10.0),"timeout")
	var dream_string : String = "Yeah I dreamed things about starting with %d sheep and ending with %d! Before the dream, %s" \
		% [starting_sheep_count, ending_sheep_count, events_string]
	on_request_completed(HTTPRequest.RESULT_SUCCESS, "200", [], dream_string)

func request_dream(starting_sheep_count : int, ending_sheep_count : int, events_string : String):
	var local_http_request : HTTPRequest = get_http_request()
	var body : String = _build_request_body(starting_sheep_count, ending_sheep_count, events_string)
		# Set URL of the ChatGPT API proxy endpoint and the method to POST 
	var key : String = get_api_key()
	var url : String = get_api_url()
	var method : int = get_api_method()

	# Set the request headers
	var request_headers : Array = []
	request_headers.append("Content-Type: application/json")
	request_headers.append("x-api-key: %s" % key)
	# Send the request
	var error = local_http_request.request(url, request_headers, true, method, body)
	if error != OK:
		push_error("An error occurred in the HTTP request. %d" % error)

func on_request_completed(result, response_code, headers, body):
	if result == HTTPRequest.RESULT_SUCCESS:
		if body is PoolByteArray:
			var response = parse_json(body.get_string_from_utf8())
			if response.has("body"):
				emit_signal("dream_recollected", str(response["body"]))
			elif response.has("errorMessage"):
				emit_signal("dream_recollected", FAILED_DREAM_MESSAGE)
			else:
				emit_signal("dream_recollected", FAILED_DREAM_MESSAGE)
		else:
			emit_signal("dream_recollected", body)
	else:
		print("Error:", result)

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	on_request_completed(result, response_code, headers, body)
