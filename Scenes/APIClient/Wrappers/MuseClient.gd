extends Node

const FAILED_MUSING_MESSAGE : String = "My mind is foggy. I hope I don't have trouble dreaming tonight."
signal musing_shared(musing_text)

onready var _api_client = $APIClient

func _build_request_body() -> String:
	var api_user : String = _api_client.get_api_user()
	var messages : Array = [
		{
			"role": "system",
			"content": "You are a helpful assistant that can role-play."
		},
		{
			"role": "user",
			"content": "You will act the part of an android shepherd with the ability to dream. While going about your day herding your electric sheep, share a very short, one-sentence musing you would have on the nature of dreams."
		}
	]

	# Set the request body with the complete messages dict
	var body_dict : Dictionary = {
		"messages": messages,
		"user": api_user
	}
	return JSON.print(body_dict)

func mock_request_musing():
	var _body : String = _build_request_body()
	_api_client.mock_request(_body)

func request_musing():
	var body : String = _build_request_body()
	_api_client.request(body)

func _on_APIClient_response_received(response_body):
	emit_signal("musing_shared", response_body)

func _on_APIClient_request_failed(_error):
	emit_signal("musing_shared", FAILED_MUSING_MESSAGE)
