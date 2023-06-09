extends Control


signal done_pressed
signal restart_pressed
signal shepherd_dreamed(dream_text)

const REVEAL_PERCENT_PER_SECOND = 0.30
const DAY_EVENTS_STRING = "The android shepherd ventured out in the morning with its flock of %d sheep to graze on the electric pastures. While tending the flock...\n\n" \
	+ "%s\n" \
	+ "At the end of the day, the android shepherd made camp with %d robot sheep."
const LAST_DAY_EVENTS_STRING = "The android shepherd ventured out in the morning with its flock of %d sheep to graze on the electric pastures. While tending the flock...\n\n" \
	+ "%s\n" \
	+ "At the end of the day, the android shepherd safely returned home with %d robot sheep."
const OOPS_STRING = "Oops... Something went wrong. We didn't get a response from the android shepherd (ChatGPT API) for way too long. Must be dead."

var showing_clock : bool = false
var dream_returned : bool = false
var last_dream_flag : bool = false
var string_maps : Dictionary = {}

func _request_dream(starting_sheep_count : int, ending_sheep_count : int, events_string : String):
	$AnimationPlayer.play("RESET")
	$ButtonAnimationPlayer.play("RESET")
	dream_returned = false
	$DreamClient.request_dream(starting_sheep_count, ending_sheep_count, events_string)
	_start_clock()

func _show_clock():
	if dream_returned:
		return
	$ClockAnimationPlayer.play("ShowClock")
	showing_clock = true

func _hide_clock():
	if not showing_clock:
		return
	$ClockAnimationPlayer.play("HideClock")
	showing_clock = false

func _get_day_events_string():
	if last_dream_flag:
		return LAST_DAY_EVENTS_STRING
	return DAY_EVENTS_STRING

func _get_filled_day_events_string(starting_sheep_count : int, ending_sheep_count : int, events_string : String):
	return _get_day_events_string() % [starting_sheep_count, events_string, ending_sheep_count]

func _read_events(starting_sheep_count : int, ending_sheep_count : int, events_string : String):
	$"%DayEventsTextLabel".text = _get_filled_day_events_string(starting_sheep_count, ending_sheep_count, events_string)
	$AnimationPlayer.play("ReadEvents")
	yield($AnimationPlayer, "animation_finished")
	_show_clock()

func _fill_string_map(events_array : Array):
	for event in events_array:
		if event is EventData:
			if event.custom_event_content != "" and event.custom_event_content != event.event_content:
				string_maps[event.event_content] = event.custom_event_content

func _replace_backend_strings(text : String):
	var result_text : String = text
	for backend_string in string_maps:
		var custom_string : String = string_maps[backend_string]
		result_text = result_text.replace(backend_string, custom_string)
	return result_text

func start_dream_request(starting_sheep_count : int, ending_sheep_count : int, events_array : Array):
	_fill_string_map(events_array)
	var events_string = $SentenceBuilder.get_event_sentences(events_array)
	var custom_events_string : String = _replace_backend_strings(events_string)
	_request_dream(starting_sheep_count, ending_sheep_count, events_string)
	_read_events(starting_sheep_count, ending_sheep_count, custom_events_string)

func _start_clock():
	var clock_node = get_node_or_null("%Clock")
	if clock_node != null:
		clock_node.start()

func _stop_clock():
	var clock_node = get_node_or_null("%Clock")
	if clock_node != null:
		clock_node.stop()

func _show_dream():
	if last_dream_flag:
		$"%DoneButton".text = "The End"
	$AnimationPlayer.play("ShowDream")
	yield($AnimationPlayer, "animation_finished")
	$ButtonAnimationPlayer.play("DreamComplete")
		

func _dream_ready(dream_text : String):
	if dream_returned:
		return
	dream_returned = true
	_hide_clock()
	var highlighted_dream_text = $TextHighlighter.highlight_dream(dream_text)
	$"%DreamTextLabel".bbcode_text = highlighted_dream_text
	$"%GoodWordCount".text = "%d" % $TextHighlighter.good_word_count
	$"%BadWordCount".text = "%d" % $TextHighlighter.bad_word_count
	$"%DreamEntitiesCount".text = "%d" % $TextHighlighter.dream_entity_count
	$"%FearManifestationsCount".text = "%d" % $TextHighlighter.fear_manifestation_count
	var total_score = (($TextHighlighter.dream_entity_count * 6) \
		+ $TextHighlighter.good_word_count) \
		- (($TextHighlighter.fear_manifestation_count * 2) \
		+ $TextHighlighter.bad_word_count)
	if total_score > 12:
		$"%GradeResult".text = "SS"
	elif total_score > 9:
		$"%GradeResult".text = "S"
	elif total_score > 5:
		$"%GradeResult".text = "A"
	elif total_score > 2:
		$"%GradeResult".text = "B"
	elif total_score > -2:
		$"%GradeResult".text = "C"
	elif total_score > -5:
		$"%GradeResult".text = "D"
	else:
		$"%GradeResult".text = "F"
	$ButtonAnimationPlayer.play("DreamReady")
	emit_signal("shepherd_dreamed", dream_text)

func _on_DoneButton_pressed():
	emit_signal("done_pressed")

func _on_RestartButton_pressed():
	emit_signal("restart_pressed")

func _on_NextButton_pressed():
	_show_dream()

func _on_DreamClient_dream_recollected(dream_text : String):
	var custom_dream_text : String = _replace_backend_strings(dream_text)
	_dream_ready(custom_dream_text)

func _ready():
	$"%GoodWordCount".modulate = $TextHighlighter.good_word_color
	$"%BadWordCount".modulate = $TextHighlighter.bad_word_color
	$"%DreamEntitiesCount".modulate = $TextHighlighter.dream_entity_color
	$"%FearManifestationsCount".modulate = $TextHighlighter.fear_manifestation_color

func _on_Clock_timeout():
	if dream_returned:
		return
	yield(get_tree().create_timer(5), "timeout")
	_dream_ready(OOPS_STRING)


func _input(event):
	if $AnimationPlayer.is_playing() and (event is InputEventMouseButton or event is InputEventKey):
		match($AnimationPlayer.current_animation):
			# Seek 0.01 from the end to still trigger `animation_finished` signals.
			"ReadEvents":
				$AnimationPlayer.seek(11 - 0.01)
			"ShowDream":
				$AnimationPlayer.seek(16 - 0.01)
