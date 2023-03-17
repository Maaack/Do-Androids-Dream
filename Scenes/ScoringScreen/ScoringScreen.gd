extends Control


signal done_pressed

const REVEAL_PERCENT_PER_SECOND = 0.30

var showing_clock : bool = false

func _request_dream(starting_sheep_count : int, ending_sheep_count : int, events_string : String):
	$APIClient.request_dream(starting_sheep_count, ending_sheep_count, events_string)
	_start_clock()

func _show_clock():
	$ClockAnimationPlayer.play("ShowClock")
	showing_clock = true

func _hide_clock():
	if not showing_clock:
		return
	$ClockAnimationPlayer.play("HideClock")
	showing_clock = false

func _read_events(events_string : String):
	$Panel/MarginContainer/EventsContainer/RichTextLabel.text = events_string
	$AnimationPlayer.play("ReadEvents")
	yield($AnimationPlayer, "animation_finished")
	_show_clock()

func start_dream_request(starting_sheep_count : int, ending_sheep_count : int, events_array : Array):
	var events_string = $SentenceBuilder.get_event_sentences(events_array)
	_request_dream(starting_sheep_count, ending_sheep_count, events_string)
	_read_events(events_string)

func _start_clock():
	var clock_node = get_node_or_null("%Clock")
	if clock_node != null:
		clock_node.start()

func _stop_clock():
	var clock_node = get_node_or_null("%Clock")
	if clock_node != null:
		clock_node.stop()

func _show_dream():
	$AnimationPlayer.play("ShowDream")
	yield($AnimationPlayer, "animation_finished")
	$AnimationPlayer.play("DreamComplete")

func _dream_ready(dream_text : String):
	_hide_clock()
	var highlighted_dream_text = $TextHighlighter.highlight_dream(dream_text)
	$Panel/MarginContainer/DreamContainer/RichTextLabel.bbcode_text = highlighted_dream_text
	$AnimationPlayer.play("DreamReady")

func _on_DoneButton_pressed():
	emit_signal("done_pressed")

func _on_NextButton_pressed():
	_show_dream()

func _on_APIClient_dream_recollected(dream_text):
	_dream_ready(dream_text)
