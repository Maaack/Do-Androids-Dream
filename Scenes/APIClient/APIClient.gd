extends Node

signal response_received(response_body)
signal request_failed(error)

export(String) var api_url : String
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
	return api_url

func get_api_user() -> String:
	return "%s %s" % [OS.get_locale_language(), OS.get_name()]

func get_api_method() -> int:
	return HTTPClient.METHOD_POST

func mock_request(body : String):
	yield(get_tree().create_timer(10.0),"timeout")
	on_request_completed(HTTPRequest.RESULT_SUCCESS, "200", [], body)

func request(body : String):
	var local_http_request : HTTPRequest = get_http_request()

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
			var body_string = body.get_string_from_utf8()
			var response = parse_json(body_string)
			if response.has("body"):
				emit_signal("response_received", str(response["body"]))
			elif response.has("errorMessage"):
				emit_signal("request_failed", str(response["errorMessage"]))
			else:
				emit_signal("request_failed", "failed to parse json: %s" % body_string)
		else:
			emit_signal("response_received", body)
	else:
		print("Error:", result)

func _on_HTTPRequest_request_completed(result, response_code, headers, body):
	on_request_completed(result, response_code, headers, body)
