@tool
extends Node3D
class_name HexTilemap

## Custom tilemap node for managing hex tiles with coordinate system
## Provides API for creating, accessing, and querying hex tiles

signal tile_created(coordinate: Vector2i, tile: Tile)
signal tile_removed(coordinate: Vector2i)
signal tilemap_cleared()

@export var tile_config: HexTileConfigResource = preload("res://data/tile_config.tres")
@export var tile_scene: PackedScene = preload("res://scenes/tile.tscn")

# Hardcoded hex size that matches the tile models
const HEX_SIZE = 1.14
var hex_size: float = HEX_SIZE

# Internal storage for tiles
var _tiles: Dictionary = {} # Vector2i -> Tile
var _tile_positions: Dictionary = {} # Tile -> Vector2i (reverse lookup)
var _hex_utils: HexUtils

func _ready():
	add_to_group("tilemaps")
	_initialize_hex_utils()
	if not tile_scene:
		push_warning("HexTilemap: No tile scene assigned, creating basic Tile nodes")

func _initialize_hex_utils():
	_hex_utils = HexUtils.new(HEX_SIZE, "pointy", Vector2.ZERO) # Using pointy orientation with hardcoded size

## Create a tile at the given hex coordinate
## @param coordinate: Hex coordinate (Vector2i) in axial coordinate system
## @param tile_id: String ID of the tile type to create
## @return: The created Tile node, or null if creation failed
func create_tile_at_coordinate(coordinate: Vector2i, tile_id: String) -> Tile:
	# Check if tile already exists at this coordinate
	if has_tile_at_coordinate(coordinate):
		push_warning("HexTilemap: Tile already exists at coordinate ", coordinate)
		return get_tile_at_coordinate(coordinate)
	
	# Validate tile_id
	if not tile_config or not tile_config.tile_exists(tile_id):
		push_error("HexTilemap: Invalid tile_id: ", tile_id)
		return null
	
	# Create tile node
	var tile: Tile
	if tile_scene:
		var instance = tile_scene.instantiate()
		if instance is Tile:
			tile = instance
		else:
			push_error("HexTilemap: tile_scene does not instantiate a Tile node")
			instance.queue_free()
			return null
	else:
		# Fallback: create basic Tile node
		tile = Tile.new()
	
	# Configure tile
	tile.tile_type = tile_id
	tile.name = "Tile_" + str(coordinate.x) + "_" + str(coordinate.y)
	
	# Position tile in world using HexUtils
	var world_2d = _hex_utils.axial_to_world(coordinate.x, coordinate.y)
	tile.position = Vector3(world_2d.x, 0, world_2d.y)
	
	# Add to scene and track
	add_child(tile)
	_tiles[coordinate] = tile
	_tile_positions[tile] = coordinate
	
	# Emit signal
	tile_created.emit(coordinate, tile)
	
	print("HexTilemap: Created tile '", tile_id, "' at coordinate ", coordinate, " (world pos: ", tile.position, ")")
	return tile

## Remove tile at given coordinate
## @param coordinate: Hex coordinate to remove tile from
## @return: true if tile was removed, false if no tile existed
func remove_tile_at_coordinate(coordinate: Vector2i) -> bool:
	if not has_tile_at_coordinate(coordinate):
		return false
	
	var tile = _tiles[coordinate]
	_tiles.erase(coordinate)
	_tile_positions.erase(tile)
	
	tile.queue_free()
	tile_removed.emit(coordinate)
	
	print("HexTilemap: Removed tile at coordinate ", coordinate)
	return true

## Get tile at given coordinate
## @param coordinate: Hex coordinate to query
## @return: Tile node at coordinate, or null if none exists
func get_tile_at_coordinate(coordinate: Vector2i) -> Tile:
	return _tiles.get(coordinate, null)

## Check if tile exists at coordinate
## @param coordinate: Hex coordinate to check
## @return: true if tile exists, false otherwise
func has_tile_at_coordinate(coordinate: Vector2i) -> bool:
	return coordinate in _tiles

## Get coordinate of given tile
## @param tile: Tile node to query
## @return: Vector2i coordinate, or Vector2i(-999, -999) if not found
func get_coordinate_of_tile(tile: Tile) -> Vector2i:
	return _tile_positions.get(tile, Vector2i(-999, -999))

## Get all tiles in the tilemap
## @return: Array of all Tile nodes
func get_all_tiles() -> Array[Tile]:
	var tiles: Array[Tile] = []
	for tile in _tiles.values():
		tiles.append(tile)
	return tiles

## Get all coordinates in the tilemap
## @return: Array of all Vector2i coordinates
func get_all_coordinates() -> Array[Vector2i]:
	var coordinates: Array[Vector2i] = []
	for coord in _tiles.keys():
		coordinates.append(coord)
	return coordinates

## Get tiles within a radius of a coordinate
## @param center: Center coordinate
## @param radius: Radius in hex tiles
## @return: Array of Tile nodes within radius
func get_tiles_in_radius(center: Vector2i, radius: int) -> Array[Tile]:
	var tiles: Array[Tile] = []
	
	for coord in _tiles.keys():
		if _hex_utils.distance(center.x, center.y, coord.x, coord.y) <= radius:
			tiles.append(_tiles[coord])
	
	return tiles

## Get coordinates within a radius of a coordinate
## @param center: Center coordinate
## @param radius: Radius in hex tiles
## @return: Array of Vector2i coordinates within radius
func get_coordinates_in_radius(center: Vector2i, radius: int) -> Array[Vector2i]:
	var coordinates: Array[Vector2i] = []
	
	for coord in _tiles.keys():
		if _hex_utils.distance(center.x, center.y, coord.x, coord.y) <= radius:
			coordinates.append(coord)
	
	return coordinates

## Get neighboring tiles of a coordinate
## @param coordinate: Center coordinate
## @param include_empty: If true, includes coordinates without tiles
## @return: Dictionary mapping neighbor coordinates to Tile nodes (or null if empty and include_empty=true)
func get_neighbors(coordinate: Vector2i, include_empty: bool = false) -> Dictionary:
	var neighbors = {}
	var neighbor_coords = _hex_utils.get_neighbors(coordinate.x, coordinate.y)
	
	for neighbor_coord in neighbor_coords:
		var tile = get_tile_at_coordinate(neighbor_coord)
		if tile or include_empty:
			neighbors[neighbor_coord] = tile
	
	return neighbors

## Get tile at world position (approximate)
## @param world_pos: World position to query
## @return: Tile node at position, or null if none exists
func get_tile_at_world_position(world_pos: Vector3) -> Tile:
	var coord = _hex_utils.world_to_axial(Vector2(world_pos.x, world_pos.z))
	return get_tile_at_coordinate(coord)

## Get coordinate from world position
## @param world_pos: World position to convert
## @return: Vector2i hex coordinate
func get_coordinate_from_world_position(world_pos: Vector3) -> Vector2i:
	return _hex_utils.world_to_axial(Vector2(world_pos.x, world_pos.z))

## Clear all tiles from the tilemap
func clear_tiles():
	for tile in _tiles.values():
		tile.queue_free()
	
	_tiles.clear()
	_tile_positions.clear()
	tilemap_cleared.emit()
	
	print("HexTilemap: Cleared all tiles")

## Get tilemap statistics
## @return: Dictionary with tilemap info
func get_tilemap_stats() -> Dictionary:
	var tile_types = {}
	for tile in _tiles.values():
		var tile_type = tile.tile_type
		tile_types[tile_type] = tile_types.get(tile_type, 0) + 1
	
	return {
		"total_tiles": _tiles.size(),
		"tile_types": tile_types,
		"bounds": _get_tilemap_bounds()
	}

## Get bounding box of all tiles
func _get_tilemap_bounds() -> Dictionary:
	if _tiles.is_empty():
		return {"min": Vector2i(0, 0), "max": Vector2i(0, 0)}
	
	var min_q = 999999
	var max_q = -999999
	var min_r = 999999
	var max_r = -999999
	
	for coord in _tiles.keys():
		min_q = min(min_q, coord.x)
		max_q = max(max_q, coord.x)
		min_r = min(min_r, coord.y)
		max_r = max(max_r, coord.y)
	
	return {
		"min": Vector2i(min_q, min_r),
		"max": Vector2i(max_q, max_r)
	}

## Find path between two coordinates (simple A* implementation)
## @param start: Start coordinate
## @param end: End coordinate
## @param walkable_only: If true, only considers walkable tiles
## @return: Array of Vector2i coordinates forming path, empty if no path found
func find_path(start: Vector2i, end: Vector2i, walkable_only: bool = true) -> Array[Vector2i]:
	# Simple A* pathfinding implementation
	var open_set = [start]
	var came_from = {}
	var g_score = {start: 0}
	var f_score = {start: MapGenerator.hex_distance(start, end)}
	
	while not open_set.is_empty():
		# Find node with lowest f_score
		var current = open_set[0]
		var current_f = f_score.get(current, 999999)
		for node in open_set:
			var node_f = f_score.get(node, 999999)
			if node_f < current_f:
				current = node
				current_f = node_f
		
		if current == end:
			# Reconstruct path
			var path: Array[Vector2i] = []
			while current in came_from:
				path.push_front(current)
				current = came_from[current]
			path.push_front(start)
			return path
		
		open_set.erase(current)
		
		for neighbor in _hex_utils.get_neighbors(current.x, current.y):
			# Check if neighbor is valid
			if walkable_only:
				var tile = get_tile_at_coordinate(neighbor)
				if not tile or not tile.current_tile_data or not tile.current_tile_data.is_walkable:
					continue
			
			var tentative_g_score = g_score.get(current, 999999) + 1
			
			if tentative_g_score < g_score.get(neighbor, 999999):
				came_from[neighbor] = current
				g_score[neighbor] = tentative_g_score
				f_score[neighbor] = tentative_g_score + _hex_utils.distance(neighbor.x, neighbor.y, end.x, end.y)
				
				if neighbor not in open_set:
					open_set.append(neighbor)
	
	# No path found
	return []
