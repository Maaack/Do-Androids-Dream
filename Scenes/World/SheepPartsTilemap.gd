extends TileMap


var sheep_part_scene = preload("res://Scenes/SheepPart/SheepPart.tscn")

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
		var sheep_part_instance = sheep_part_scene.instance()
		sheep_part_instance.position = cell_offset + map_to_world(cell_position) * scale
		add_child(sheep_part_instance)
		set_cellv(cell_position, -1)

func _ready():
	_load_scenes()
