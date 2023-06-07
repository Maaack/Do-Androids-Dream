extends Node2D

export(PoolVector2Array) var path_points : PoolVector2Array setget set_path_points
export(Color) var color : Color = Color.white setget set_color
export(Texture) var path_texture : Texture setget set_path_texture
export(Texture) var destination_marker_texture : Texture setget set_destination_marker_texture
export(Vector2) var destination_marker_offset : Vector2 = Vector2(0,-16)

func set_path_points(value : PoolVector2Array):
	path_points = value
	$Path.points = path_points

func set_indicator_position(new_position):
	$DestinationMarker.position = new_position + destination_marker_offset

func set_path_texture(value : Texture):
	path_texture = value
	if is_visible_in_tree():
		$Path.texture = path_texture

func set_destination_marker_texture(value : Texture):
	destination_marker_texture = value
	if is_visible_in_tree():
		$DestinationMarker.texture = destination_marker_texture

func set_color(value : Color):
	color = value
	if is_visible_in_tree():
		$Path.modulate = color
		$DestinationMarker.modulate = color

func _ready():
	self.color = color
	self.path_texture = path_texture
	self.destination_marker_texture = destination_marker_texture
