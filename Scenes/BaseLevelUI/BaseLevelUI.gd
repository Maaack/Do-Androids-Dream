extends Control

class_name BaseLevel

const MAX_SHEEP_COUNT : int = 20
const TOGGLE_ACTION_RADIUS : float = 60.0
enum InputModes{
	MOUSE,
	KEYBOARD
}

export(int) var starting_sheep_count : int = 6
export(float) var day_length : float = 100
export(int, 1, 12) var game_days : int = 3
export(int, 0, 12) var musing_start_day : int = 0
export(float, 0, 1000) var min_goal_arrow_distance : float = 300
export(bool) var goal_active : bool = false
export(bool) var dreaming_enabled : bool = true

var day_ended : bool = false
var destination_reached : bool = false
var current_day : int = 0
var game_events : Array = []
var day_events : Array = []
var day_starting_sheep_count : int = 0
var sheep_editor_packed = preload("res://Scenes/SheepEditor/SheepEditor.tscn")
var input_mode : int = InputModes.MOUSE
var recent_new_sheep : Array = []
var pause_mouse_input : bool = false

func _end_day():
	if day_ended:
		return
	day_ended = true
	$"%EndDayButton".disabled = true
	$"%World".snooze_all()
	$EndDayDelayTimer.start()

func _get_days_left():
	return game_days - current_day

func _start_day_clock():
	$"%DayTimeContainer".show()
	$"%Clock".start()
	$"%World".reset_day()

func _start_day(start_clock_flag : bool = true):
	day_events.clear()
	get_tree().paused = false
	day_ended = false
	day_starting_sheep_count = $"%World".get_powered_sheep_count()
	if start_clock_flag:
		_start_day_clock()
	$"%World".start_day()
	$"%DaysLeftLabel".text = "Days Left: %d" % _get_days_left()
	if current_day >= musing_start_day:
		$MuseTimer.start()
	$"%EndDayButton".disabled = false

func reset_level() -> void:
	game_events.clear()
	$"%World".set_day_length(day_length)
	$"%World".reset_world(starting_sheep_count)
	$"%Clock".wait_time = day_length
	_start_day(false)

func _show_sheep_editor(sheep_list : Array):
	if sheep_list.size() == 0:
		return
	var sheep_editor = InGameMenuController.open_menu(sheep_editor_packed)
	sheep_editor.sheep_list = sheep_list

func _ready():
	reset_level()

func add_event(event_type : int, content : String, readable_content : String = "") -> void:
	var event : EventData = EventData.new(event_type, content, readable_content)
	game_events.append(event)
	day_events.append(event)

func add_shepherd_dreamed_event(dream_text):
	game_events.append(EventData.new(EventData.EVENT_TYPES.DREAM, dream_text, dream_text))

func add_feed_sheep_event(sheep_instance : Sheep):
	add_event(EventData.EVENT_TYPES.EAT_NORMAL_GRASS, sheep_instance.sheep_name, sheep_instance.custom_sheep_name)

func add_poison_sheep_event(sheep_name):
	pass
	# add_event(EventData.EVENT_TYPES.EAT_VOLATILE_GRASS, sheep_name)

func add_explode_sheep_event(sheep_instance : Sheep):
	add_event(EventData.EVENT_TYPES.EXPLODE, sheep_instance.sheep_name, sheep_instance.custom_sheep_name)

func add_build_sheep_event(sheep_instance : Sheep):
	add_event(EventData.EVENT_TYPES.BUILD, sheep_instance.sheep_name, sheep_instance.custom_sheep_name)

func add_power_sheep_event(sheep_instance : Sheep):
	add_event(EventData.EVENT_TYPES.POWER, sheep_instance.sheep_name, sheep_instance.custom_sheep_name)

func add_sheep_starved_event(sheep_instance : Sheep):
	add_event(EventData.EVENT_TYPES.STARVE, sheep_instance.sheep_name, sheep_instance.custom_sheep_name)

func add_shephered_entered_area_event(area_name):
	add_event(EventData.EVENT_TYPES.ENTER_AREA, area_name)

func show_scoring_screen():
	$BackgroundMusic.stop()
	$DreamMusic.play()
	$ScoringScreen.show()
	$ScoringScreen.last_dream_flag = game_is_over()
	$ScoringScreen.start_dream_request(day_starting_sheep_count, $"%World".get_powered_sheep_count(), day_events)

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

func _on_World_sheep_ate_normal_grass(sheep_instance : Sheep):
	add_feed_sheep_event(sheep_instance)

func _on_World_sheep_ate_volatile_grass(sheep_instance : Sheep):
	add_poison_sheep_event(sheep_instance)

func _on_World_sheep_exploded(sheep_instance : Sheep):
	add_explode_sheep_event(sheep_instance)

func _on_World_new_sheep(sheep_instance : Sheep):
	recent_new_sheep.append(sheep_instance)
	if $NewSheepTimer.is_stopped():
		$NewSheepTimer.start()

func _on_World_sheep_assembled(sheep_instance : Sheep):
	add_build_sheep_event(sheep_instance)
	_on_World_new_sheep(sheep_instance)

func _on_World_sheep_powered(sheep_instance):
	add_power_sheep_event(sheep_instance)
	_on_World_new_sheep(sheep_instance)

func _on_World_sheep_starved(sheep_instance : Sheep):
	add_sheep_starved_event(sheep_instance)

func _on_ScoringScreen_shepherd_dreamed(dream_text):
	add_shepherd_dreamed_event(dream_text)

func _on_Clock_timeout():
	_end_day()

func _on_MuseTimer_timeout():
	$MuseClient.request_musing()

func _on_NewSheepTimer_timeout():
	if recent_new_sheep.size() > 0:
		_show_sheep_editor(recent_new_sheep)
		recent_new_sheep = []

func _on_MuseClient_musing_shared(musing_text):
	add_event(EventData.EVENT_TYPES.MUSE, musing_text)
	show_musing(musing_text)

func _get_camera_center():
	return get_viewport_rect().size / 2

func _process(delta):
	match(input_mode):
		InputModes.MOUSE:
			if pause_mouse_input:
				return
			elif Input.is_action_pressed("interact"):
				var direction = get_local_mouse_position() - _get_camera_center()
				if direction.length() > TOGGLE_ACTION_RADIUS:
					$"%World".move_shepherd(direction)
					$"%World".stop_toggling_shepherd_equipped()
				else:
					$"%World".move_shepherd(Vector2.ZERO)
					$"%World".start_toggling_shepherd_equipped()
			elif Input.is_action_just_released("interact"):
				$"%World".move_shepherd(Vector2.ZERO)
				$"%World".stop_toggling_shepherd_equipped()
		InputModes.KEYBOARD:
			var input_vector = Vector2.ZERO
			input_vector.x = Input.get_action_strength("move_right") - Input.get_action_strength("move_left")
			input_vector.y = Input.get_action_strength("move_down") - Input.get_action_strength("move_up")
			if input_vector.length() < 0.01:
				$"%World".move_shepherd(Vector2.ZERO)
			else:
				$"%World".move_shepherd(input_vector)
	var goal_relative_position : Vector2 = $"%World".get_goal_relative_position()
	if goal_active and goal_relative_position.length() > min_goal_arrow_distance:
		$"%GoalArrowControl".show()
	else:
		$"%GoalArrowControl".hide()
	$"%GoalArrowControl".point_to(goal_relative_position)

func _unhandled_input(event):
	if event is InputEventMouseButton:
		input_mode = InputModes.MOUSE
		if  event.is_action_pressed("interact") and event.doubleclick:
			pause_mouse_input = true
			$PauseMouseTimer.start()
			var direction = event.position - _get_camera_center()
			if direction.length() > TOGGLE_ACTION_RADIUS:
				$"%World".set_shepherd_destination(event.position - _get_camera_center())
			else:
				$"%World".swap_shepherd_equipped()
		elif event.is_action_pressed("swap"):
			$"%World".swap_shepherd_equipped()
	elif event is InputEventKey:
		input_mode = InputModes.KEYBOARD
		if event.is_action_pressed("interact"):
			$"%World".start_toggling_shepherd_equipped()
		if event.is_action_released("interact"):
			$"%World".stop_toggling_shepherd_equipped()

func _on_PauseMouseTimer_timeout():
	pause_mouse_input = false

func _start_night():
	current_day += 1
	get_tree().paused = true
	$"%World".starve_hungry_sheep()
	if dreaming_enabled:
		show_scoring_screen()
	else:
		_start_day()

func _on_EndDayDelayTimer_timeout():
	_start_night()
