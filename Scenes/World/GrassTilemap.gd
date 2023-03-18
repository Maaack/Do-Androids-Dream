extends TileMap

enum GRASS_TYPES{
	NONE = -1,
	NORMAL,
	VOLATILE,
}

var grass_scene = preload("res://Scenes/Grass/Grass.tscn")

var loaded_scenes = false

func _load_scenes():
	if loaded_scenes:
		return
	loaded_scenes = true
	var cell_offset = cell_size / 2
	for cell_position in get_used_cells():
		var cell = get_cellv(cell_position)
		if cell < 0:
			return
		var grass_instance = grass_scene.instance()
		grass_instance.position = cell_offset + map_to_world(cell_position) * scale
		match(cell):
			GRASS_TYPES.NORMAL:
				pass
			GRASS_TYPES.VOLATILE:
				grass_instance.is_volatile = true
		add_child(grass_instance)
		set_cellv(cell_position, GRASS_TYPES.NONE)

func _ready():
	_load_scenes()
