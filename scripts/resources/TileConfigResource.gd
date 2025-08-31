@tool
extends Resource
class_name HexTileConfigResource

@export var tiles: Array[HexTileData] = []

func get_tile_data(tile_id: String) -> HexTileData:
	for tile_data in tiles:
		if tile_data.tile_id == tile_id:
			return tile_data
	return null

func get_all_tile_ids() -> Array:
	var ids = []
	for tile_data in tiles:
		ids.append(tile_data.tile_id)
	return ids

func tile_exists(tile_id: String) -> bool:
	return get_tile_data(tile_id) != null
