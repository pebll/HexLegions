@tool
extends RefCounted
class_name MapGenerator

## Simple hex map generator using proven HexUtils
## Just generates random tiles with correct positioning

## Generate a hex map with given parameters
## @param size: radius in tiles from center (1 = 7 tiles total, 2 = 19 tiles total)
## @param tile_pool: array of tile_id strings to randomly choose from
## @param tilemap_node: HexTilemap node to populate with tiles
## @param hex_size: size of hex tiles (default 1.0)
## @return Dictionary with generation stats
static func generate_map(size: int, tile_pool: Array[String], tilemap_node, hex_size: float = 1.0) -> Dictionary:
	if size < 1:
		push_error("MapGenerator: Size must be at least 1")
		return {"error": "Invalid size"}
	
	if tile_pool.is_empty():
		push_error("MapGenerator: Tile pool cannot be empty")
		return {"error": "Empty tile pool"}
	
	if not tilemap_node:
		push_error("MapGenerator: Tilemap node is required")
		return {"error": "No tilemap node"}
	
	# Clear existing tiles
	tilemap_node.clear_tiles()
	
	# Create hex utility with flat orientation (matches Godot's typical setup)
	var hex_utils = HexUtils.new(hex_size, "pointy", Vector2.ZERO)
	
	var tiles_created = 0
	var generation_start_time = Time.get_time_dict_from_system()
	
	# Get hex coordinates in radius
	var coordinates = hex_utils.get_coords_in_radius(0, 0, size)
	
	print("MapGenerator: Generating ", coordinates.size(), " tiles with radius ", size)
	
	# Create tiles at each coordinate
	for coord in coordinates:
		var random_tile_id = tile_pool[randi() % tile_pool.size()]
		
		# Create tile in tilemap (HexTilemap will handle positioning)
		var tile = tilemap_node.create_tile_at_coordinate(coord, random_tile_id)
		if tile:
			tiles_created += 1
		else:
			print("MapGenerator: Failed to create tile at ", coord)
	
	var generation_end_time = Time.get_time_dict_from_system()
	
	var stats = {
		"tiles_created": tiles_created,
		"total_coordinates": coordinates.size(),
		"radius": size,
		"tile_pool_size": tile_pool.size(),
		"start_time": generation_start_time,
		"end_time": generation_end_time
	}
	
	print("MapGenerator: Successfully generated ", tiles_created, " tiles")
	return stats

## Get world position from hex coordinate (convenience method)
static func hex_to_world(coord: Vector2i, hex_size: float = 1.14) -> Vector3:
	var hex_utils = HexUtils.new(hex_size, "pointy", Vector2.ZERO)
	var world_2d = hex_utils.axial_to_world(coord.x, coord.y)
	return Vector3(world_2d.x, 0, world_2d.y)

## Get hex coordinate from world position (convenience method) 
static func world_to_hex(world_pos: Vector3, hex_size: float = 1.14) -> Vector2i:
	var hex_utils = HexUtils.new(hex_size, "pointy", Vector2.ZERO)
	return hex_utils.world_to_axial(Vector2(world_pos.x, world_pos.z))

## Get neighbors of a hex coordinate
static func get_hex_neighbors(coord: Vector2i) -> Array[Vector2i]:
	var hex_utils = HexUtils.new(1.14, "pointy", Vector2.ZERO)
	return hex_utils.get_neighbors(coord.x, coord.y)

## Calculate distance between two hex coordinates
static func hex_distance(coord1: Vector2i, coord2: Vector2i) -> int:
	var hex_utils = HexUtils.new(1.14, "pointy", Vector2.ZERO)
	return hex_utils.distance(coord1.x, coord1.y, coord2.x, coord2.y)
