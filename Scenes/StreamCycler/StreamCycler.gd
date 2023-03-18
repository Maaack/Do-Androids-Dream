extends Node2D

enum STREAM_TYPE {
	STREAM_PLAYER,
	STREAM_PLAYER_2D,
	STREAM_PLAYER_3D
}

export(STREAM_TYPE) var stream_type : int = 0
export(Array, AudioStream) var streams : Array = []
export(String) var bus : String = "Master"
export(float, -80, 24) var volume_db : float = 0

var stream_players : Array = []

func _get_stream_type_class():
	match(stream_type):
		STREAM_TYPE.STREAM_PLAYER:
			return AudioStreamPlayer
		STREAM_TYPE.STREAM_PLAYER_2D:
			return AudioStreamPlayer2D
		STREAM_TYPE.STREAM_PLAYER_3D:
			return AudioStreamPlayer3D

func _ready():
	var stream_type_class = _get_stream_type_class()
	for stream in streams:
		var stream_player = stream_type_class.new()
		add_child(stream_player)
		stream_player.stream = stream
		stream_player.bus = bus
		stream_player.volume_db = volume_db
		stream_players.append(stream_player)

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

func play():
	$AnimationPlayer.play("Walking")

func stop():
	$AnimationPlayer.stop()
