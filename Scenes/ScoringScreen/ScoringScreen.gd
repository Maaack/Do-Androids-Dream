extends Control


signal done_pressed

const REVEAL_PERCENT_PER_SECOND = 0.30

var events_array : Array setget set_events_array
var events_string : String

func set_events_array(new_values : Array):
	events_array = new_values
	events_string = $SentenceBuilder.get_event_sentences(events_array)
	$Panel/MarginContainer/VBoxContainer/RichTextLabel.text = events_string
	$Panel/MarginContainer/VBoxContainer/RichTextLabel.percent_visible = 0.0

func _process(delta):
	if $Panel/MarginContainer/VBoxContainer/RichTextLabel.percent_visible < 1.0:
		$Panel/MarginContainer/VBoxContainer/RichTextLabel.percent_visible += delta * REVEAL_PERCENT_PER_SECOND

func _on_DoneButton_pressed():
	emit_signal("done_pressed")
