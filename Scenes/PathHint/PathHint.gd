tool
extends Node2D

export(PoolVector2Array) var path_points : PoolVector2Array setget set_path_points
export(Color) var color : Color = Color.white setget set_color
export(Texture) var path_texture : Texture setget set_path_texture
export(Texture) var start_marker_texture : Texture setget set_start_marker_texture
export(Vector2) var start_marker_offset : Vector2 = Vector2.ZERO
export(Texture) var end_marker_texture : Texture setget set_end_marker_texture
export(Vector2) var end_marker_offset : Vector2 = Vector2.ZERO
export(Vector2) var start_position : Vector2 setget set_start_position
export(Vector2) var end_position : Vector2 setget set_end_position

func set_path_points(value : PoolVector2Array):
	path_points = value
	$Path.points = path_points

func set_start_position(value : Vector2):
	start_position = value
	if is_visible_in_tree():
		$StartMarker.position = start_position + start_marker_offset

func set_end_position(value : Vector2):
	end_position = value
	if is_visible_in_tree():
		$EndMarker.position = end_position + end_marker_offset

func set_path_texture(value : Texture):
	path_texture = value
	if is_visible_in_tree():
		$Path.texture = path_texture

func set_start_marker_texture(value : Texture):
	start_marker_texture = value
	if is_visible_in_tree():
		$StartMarker.texture = start_marker_texture

func set_end_marker_texture(value : Texture):
	end_marker_texture = value
	if is_visible_in_tree():
		$EndMarker.texture = end_marker_texture

func set_color(value : Color):
	color = value
	if is_visible_in_tree():
		$Path.modulate = color
		$Path.default_color = color
		$StartMarker.modulate = color
		$EndMarker.modulate = color

func _ready():
	self.color = color
	self.path_texture = path_texture
	self.start_marker_texture = start_marker_texture
	self.end_marker_texture = end_marker_texture
	self.start_position = start_position
	self.end_position = end_position
