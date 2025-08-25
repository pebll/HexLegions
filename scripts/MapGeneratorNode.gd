@tool
extends Node
class_name MapGeneratorNode

## Map generator node that can be added as a child to HexTilemap
## Provides editor interface for generating hex maps

@export_group("Generation Parameters")
@export var map_size: int = 3: set = _set_map_size
@export var tile_pool: Array[String] = ["tile_grass", "tile_sand", "tile_water"]: set = _set_tile_pool

# Hardcoded hex size that matches the tile models
const HEX_SIZE = 1.14

@export_group("Generation Controls")
@export var editor_generate_map: bool = false: set = _generate_map
@export var clear_map: bool = false: set = _clear_map

var _tilemap: HexTilemap

func _ready():
	# Find parent HexTilemap (works both in editor and runtime)
	var parent = get_parent()
	if parent is HexTilemap:
		_tilemap = parent
	else:
		push_warning("MapGeneratorNode: Parent is not a HexTilemap")

func _set_map_size(value: int):
	map_size = max(1, value)
	if Engine.is_editor_hint():
		notify_property_list_changed()


func _set_tile_pool(value: Array[String]):
	tile_pool = value
	if Engine.is_editor_hint():
		notify_property_list_changed()

func _generate_map(value: bool):
	if Engine.is_editor_hint() and value:
		editor_generate_map = false # Reset button
		_perform_generation()
		notify_property_list_changed()
    
func generate_map():
	_perform_generation()

func _clear_map(value: bool):
	if Engine.is_editor_hint() and value:
		clear_map = false # Reset button
		_perform_clear()
		notify_property_list_changed()

func _perform_generation():
	print("MapGeneratorNode: Starting generation...")
	print("MapGeneratorNode: _tilemap = ", _tilemap)
	print("MapGeneratorNode: tile_pool = ", tile_pool)
	print("MapGeneratorNode: map_size = ", map_size)
	
	if not _tilemap:
		push_error("MapGeneratorNode: No HexTilemap parent found")
		return
	
	if tile_pool.is_empty():
		push_error("MapGeneratorNode: Tile pool is empty")
		return
	
	print("MapGeneratorNode: Generating map with size=", map_size, " hex_size=", HEX_SIZE, " tiles=", tile_pool)
	
	# Update tilemap hex size
	_tilemap.hex_size = HEX_SIZE
	
	# Generate the map
	var stats = MapGenerator.generate_map(map_size, tile_pool, _tilemap, HEX_SIZE)
	
	print("MapGeneratorNode: Generation stats = ", stats)
	
	if "error" in stats:
		push_error("MapGeneratorNode: Generation failed: " + stats.error)
	else:
		print("MapGeneratorNode: Generation successful - ", stats.tiles_created, " tiles created")

func _perform_clear():
	if not _tilemap:
		push_error("MapGeneratorNode: No HexTilemap parent found")
		return
	
	print("MapGeneratorNode: Clearing map")
	_tilemap.clear_tiles()

# Custom property list to make the interface cleaner
func _get_property_list():
	var properties = []
	
	# Add info about expected tile count
	var expected_tiles = _get_expected_tile_count(map_size)
	
	properties.append({
		"name": "expected_tile_count",
		"type": TYPE_STRING,
		"usage": PROPERTY_USAGE_EDITOR | PROPERTY_USAGE_READ_ONLY,
		"hint_string": "Expected tiles for radius " + str(map_size) + ": " + str(expected_tiles)
	})
	
	return properties

func _get_expected_tile_count(radius: int) -> int:
	# Hex area formula: 3 * radius^2 + 3 * radius + 1
	return 3 * radius * radius + 3 * radius + 1

# Validation for tile pool
func _validate_tile_pool() -> bool:
	if not _tilemap or not _tilemap.tile_config:
		return false
	
	for tile_id in tile_pool:
		if not _tilemap.tile_config.tile_exists(tile_id):
			push_warning("MapGeneratorNode: Tile ID '" + tile_id + "' does not exist in tile config")
			return false
	
	return true

# Helper to get available tile IDs from config
func get_available_tile_ids() -> Array[String]:
	if not _tilemap or not _tilemap.tile_config:
		return []
	
	return _tilemap.tile_config.get_all_tile_ids()
