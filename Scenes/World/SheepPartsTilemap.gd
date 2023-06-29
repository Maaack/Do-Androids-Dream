extends TileMap

signal add_sheep_part(position)
signal add_unpowered_sheep(position)

var loaded_scenes = false

func load_scenes():
	if loaded_scenes:
		return
	loaded_scenes = true
	var cell_offset = cell_size / 2
	for cell_position in get_used_cells():
		var cell = get_cellv(cell_position)
		match(cell):
			0:
				emit_signal("add_sheep_part", cell_offset + map_to_world(cell_position) * scale)
				set_cellv(cell_position, -1)
			1:
				emit_signal("add_unpowered_sheep", cell_offset + map_to_world(cell_position) * scale)
				set_cellv(cell_position, -1)
