extends Node

signal dream_recollected(dream_text)

const PROXY_API_URL = "https://dk7cqkgzlc.execute-api.us-east-1.amazonaws.com/prod/chat-completions"
const PROXY_USER = 'GodotProxyTester'

var _http_request

func get_http_request():
	if _http_request != null:
		return _http_request
	_http_request = HTTPRequest.new()
	
	# Connect to the signal that is emitted when the request is completed
	add_child(_http_request)
	_http_request.connect("request_completed", self, "on_request_completed")
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
	return PROXY_USER

func get_api_method() -> int:
	return HTTPClient.METHOD_POST

func _build_request_body(starting_sheep_count : int, ending_sheep_count : int, events : Array) -> String:
	var events_string : String = " ".join(events)
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
		"user": "PostmanTestingUser"
	}
	return JSON.print(body_dict)

func mock_request_dream(starting_sheep_count : int, ending_sheep_count : int, events : Array):
	var body : String = _build_request_body(starting_sheep_count, ending_sheep_count, events)
	yield(get_tree().create_timer(5.0),"timeout")
	var dream_string : String = "Yeah I dreamed things about starting with %d sheep and ending with %d! Also, %s" \
		% [starting_sheep_count, ending_sheep_count, events.pop_back()]
	on_request_completed(HTTPRequest.RESULT_SUCCESS, "200", [], dream_string)


func request_dream(starting_sheep_count : int, ending_sheep_count : int, events : Array):
	var local_http_request : HTTPRequest = get_http_request()
	var body : String = _build_request_body(starting_sheep_count, ending_sheep_count, events)
		# Set URL of the ChatGPT API proxy endpoint and the method to POST 
	var user : String = get_api_user()
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
		var response = parse_json(body.get_string_from_utf8())
		emit_signal("dream_recollected", str(response['body']))
	else:
		print("Error:", result)

