extends Control

class_name BaseLevel

const MAX_SHEEP_COUNT : int = 20

export(int) var starting_sheep_count : int = 6
export(float) var day_length : float = 100
export(int, 1, 12) var game_days : int = 3
export(int, 0, 12) var musing_start_day : int = 0

var day_ended : bool = false
var destination_reached : bool = false
var current_day : int = 0
var game_events : Array = []
var day_events : Array = []
var day_starting_sheep_count : int = 0
var sheep_editor_packed = preload("res://Scenes/SheepEditor/SheepEditor.tscn")

func _end_day():
	if day_ended:
		return
	day_ended = true
	current_day += 1
	get_tree().paused = true
	$"%World".starve_hungry_sheep()
	show_scoring_screen()

func _get_days_left():
	return game_days - current_day

func _start_day():
	day_events.clear()
	get_tree().paused = false
	day_ended = false
	day_starting_sheep_count = $"%World".get_sheep_count()
	$"%Clock".start()
	$"%World".reset_day()
	$"%DaysLeftLabel".text = "Days Left: %d" % _get_days_left()
	if current_day >= musing_start_day:
		$MuseTimer.start()

func reset_level() -> void:
	game_events.clear()
	$"%World".set_day_length(day_length)
	$"%World".reset_world(starting_sheep_count)
	$"%Clock".wait_time = day_length
	_start_day()

func _show_sheep_editor(sheep_list : Array):
	var sheep_editor = InGameMenuController.open_menu(sheep_editor_packed)
	sheep_editor.sheep_list = sheep_list

func _ready():
	reset_level()
	yield(get_tree().create_timer(0.1), "timeout")
	_show_sheep_editor($"%World".sheep_instances)

func add_event(event_type : int, content : String) -> void:
	game_events.append(EventData.new(event_type, content))
	day_events.append(EventData.new(event_type, content))

func add_shepherd_dreamed_event(dream_text):
	game_events.append(EventData.new(EventData.EVENT_TYPES.DREAM, dream_text))

func add_feed_sheep_event(sheep_name):
	add_event(EventData.EVENT_TYPES.EAT_NORMAL_GRASS, sheep_name)

func add_poison_sheep_event(sheep_name):
	pass
	# add_event(EventData.EVENT_TYPES.EAT_VOLATILE_GRASS, sheep_name)

func add_explode_sheep_event(sheep_name):
	add_event(EventData.EVENT_TYPES.EXPLODE, sheep_name)

func add_build_sheep_event(sheep_name):
	add_event(EventData.EVENT_TYPES.BUILD, sheep_name)

func add_sheep_starved_event(sheep_name):
	add_event(EventData.EVENT_TYPES.STARVE, sheep_name)

func add_shephered_entered_area_event(area_name):
	add_event(EventData.EVENT_TYPES.ENTER_AREA, area_name)

func show_scoring_screen():
	$BackgroundMusic.stop()
	$DreamMusic.play()
	$ScoringScreen.show()
	$ScoringScreen.last_dream_flag = game_is_over()
	$ScoringScreen.start_dream_request(day_starting_sheep_count, $"%World".get_sheep_count(), day_events)

func hide_scoring_screen():
	$BackgroundMusic.play()
	$DreamMusic.stop()
	$ScoringScreen.hide()

func game_is_over():
	return current_day >= game_days or destination_reached

func show_musing(musing_text : String = ""):
	$"%BottomLabel".text = musing_text
	$BottomPanelAnimationPlayer.play("Muse")

func show_entering_area(area_name : String = ""):
	$"%AreaNameLabel".text = area_name
	$AreaNameAnimationPlayer.play("FadeInNOut")

func _on_ScoringScreen_done_pressed():
	hide_scoring_screen()
	if game_is_over():
		SceneLoader.load_scene("res://Scenes/Credits/EndCredits.tscn")
	else:
		_start_day()

func _on_ScoringScreen_restart_pressed():
	SceneLoader.reload_current_scene()

func _on_EndDayButton_pressed():
	_end_day()

func _on_World_sheep_ate_normal_grass(sheep_name):
	add_feed_sheep_event(sheep_name)

func _on_World_sheep_ate_volatile_grass(sheep_name):
	add_poison_sheep_event(sheep_name)

func _on_World_sheep_exploded(sheep_name):
	add_explode_sheep_event(sheep_name)

func _on_World_sheep_assembled(sheep_instance):
	_show_sheep_editor([sheep_instance])
	add_build_sheep_event(sheep_instance.sheep_name)

func _on_World_sheep_starved(sheep_name):
	add_sheep_starved_event(sheep_name)

func _on_ScoringScreen_shepherd_dreamed(dream_text):
	add_shepherd_dreamed_event(dream_text)

func _on_Clock_timeout():
	_end_day()

func _on_MuseTimer_timeout():
	$MuseClient.request_musing()

func _on_MuseClient_musing_shared(musing_text):
	add_event(EventData.EVENT_TYPES.MUSE, musing_text)
	show_musing(musing_text)

