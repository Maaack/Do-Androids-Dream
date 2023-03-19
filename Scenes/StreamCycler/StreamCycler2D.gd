extends Node2D

export(Array, AudioStream) var streams : Array = []
export(String) var bus : String = "Master"
export(float, -80, 24) var volume_db : float = 0
export(float, 0, 100) var repeat_delay : float = 1
export(float, 0, 100) var repeat_delay_randomness : float = 0
export(float, 0, 10) var random_pitch : float = 1.1
export(bool) var is_playing : bool = false
export(bool) var repeats : bool = true

var stream_players : Array = []
var _is_waiting : bool = false

func _ready():
	var stream_type_class = AudioStreamPlayer2D
	for stream in streams:
		var stream_player = stream_type_class.new()
		add_child(stream_player)
		if random_pitch > 0:
			var pitch_stream_player = AudioStreamRandomPitch.new()
			pitch_stream_player.random_pitch = random_pitch
			pitch_stream_player.audio_stream = stream
			stream_player.stream = pitch_stream_player
		else:
			stream_player.stream = stream
		stream_player.bus = bus
		stream_player.volume_db = volume_db
		stream_players.append(stream_player)
	if is_playing:
		_play_loop(true)

func play_stream():
	var random_stream_players : Array = stream_players.duplicate()
	random_stream_players.shuffle()
	if random_stream_players.size() == 0:
		return
	var stream_player = random_stream_players.pop_front()
	while (stream_player != null and stream_player.playing):
		stream_player = random_stream_players.pop_front()
	if stream_player != null:
		stream_player.play()

func _play_loop(skip_first : bool = false):
	var skipped_first : bool = false
	while is_playing:
		if skip_first and not skipped_first:
			skipped_first = true
		else:
			play_stream()
		var wait_time = repeat_delay + rand_range(-repeat_delay_randomness, repeat_delay_randomness)
		_is_waiting = true
		yield(get_tree().create_timer(wait_time), "timeout")
		_is_waiting = false
		if not repeats:
			return

func play():
	if is_playing:
		return
	is_playing = true
	if _is_waiting:
		return
	_play_loop()

func stop():
	is_playing = false
