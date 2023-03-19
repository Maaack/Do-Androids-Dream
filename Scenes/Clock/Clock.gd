tool
extends Control


class_name ClockTimer

signal timeout

export(Color) var clock_color : Color setget set_clock_color
export(Color) var shadow_color : Color setget set_shadow_color
export(float, 0.0, 3600.0) var wait_time : float = 1.0 setget set_wait_time
export(float) var shadow_x : float = -8.0 setget set_shadow_x
export(float) var shadow_y : float = 4.0 setget set_shadow_y

func set_clock_color(value : Color):
	clock_color = value
	if is_inside_tree():
		$TimerDraw.circle_color = clock_color
		$TimerDraw.update()

func set_shadow_color(value : Color):
	shadow_color = value
	if is_inside_tree():
		$TimerDraw2.circle_color = shadow_color
		$TimerDraw2.update()

func set_shadow_x(value : float):
	shadow_x = value
	if is_inside_tree():
		$TimerDraw2.margin_left = shadow_x
		$TimerDraw2.margin_right = shadow_x

func set_shadow_y(value : float):
	shadow_y = value
	if is_inside_tree():
		$TimerDraw2.margin_bottom = shadow_y
		$TimerDraw2.margin_top = shadow_y

func set_wait_time(value : float):
	wait_time = value
	if is_inside_tree():
		$Timer.wait_time = value
		$TimerDraw.total_value = wait_time
		$TimerDraw2.total_value = wait_time

func reset():
	set_clock_color(clock_color)
	set_shadow_color(shadow_color)
	set_shadow_x(shadow_x)
	set_shadow_y(shadow_y)
	set_wait_time(wait_time)
	draw_clock_value(0.0)

func _ready():
	reset()

func _default_wait_time():
	return wait_time

func draw_clock_value(clock_value : float):
	$TimerDraw.current_value = clock_value
	$TimerDraw2.current_value = clock_value
	$TimerDraw.update()
	$TimerDraw2.update()

func start(new_wait_time : float = _default_wait_time()):
	wait_time = new_wait_time
	set_wait_time(wait_time)
	$Timer.start()
	yield($Timer, "timeout")
	emit_signal("timeout")

func stop():
	emit_signal("timeout")
	draw_clock_value(0.0)

func _process(delta):
	var current_time : float = wait_time - $Timer.time_left
	draw_clock_value(current_time)
