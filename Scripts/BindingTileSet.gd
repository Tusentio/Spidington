tool
extends TileSet

func _is_tile_bound(drawn_id, neighbor_id):
	match [drawn_id, neighbor_id]:
		[-1, _], [_, -1]:
			return false
		[drawn_id, drawn_id]:
			return true
		_:
			return tile_get_z_index(drawn_id) == tile_get_z_index(neighbor_id)
