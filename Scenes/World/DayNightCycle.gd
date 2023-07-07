extends CanvasModulate

export(float) var time_scale : float = 1.0
export(float) var day_length : float = 100.0
export(Color) var source_color: Color = Color.white
export(Color) var target_color: Color = Color.darkslateblue
export(bool) var enabled : bool = false

var _time : float = 0

func _process(delta: float) -> void:
	if not enabled:
		return
	var value : float
	_time += (delta * time_scale) / (day_length / 2)
	value = 1 - clamp(cos(_time) + 1, 0, 1)
	color = source_color.linear_interpolate(target_color, value)

func reset_time() -> void:
	_time = 0
