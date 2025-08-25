extends Node3D

## Demo script to test the Map Generator and HexTilemap functionality

@onready var hex_tilemap: HexTilemap = $HexTilemap
@onready var generate_button: Button = $UI/VBoxContainer/GenerateButton
@onready var clear_button: Button = $UI/VBoxContainer/ClearButton
@onready var size_spinbox: SpinBox = $UI/VBoxContainer/SizeContainer/SizeSpinBox
@onready var stats_label: Label = $UI/VBoxContainer/StatsLabel

# Available tile types for generation
var tile_pool: Array[String] = ["tile_grass", "tile_sand", "tile_water"]

func _ready():
	# Connect UI signals
	generate_button.pressed.connect(_on_generate_pressed)
	clear_button.pressed.connect(_on_clear_pressed)
	
	# Connect tilemap signals
	hex_tilemap.tile_created.connect(_on_tile_created)
	hex_tilemap.tile_removed.connect(_on_tile_removed)
	hex_tilemap.tilemap_cleared.connect(_on_tilemap_cleared)
	
	print("MapGeneratorDemo: Ready! Available tile types: ", tile_pool)
	_update_stats_display()

func _on_generate_pressed():
	var size = int(size_spinbox.value)
	print("MapGeneratorDemo: Generating map with size ", size)
	
	# Disable button during generation
	generate_button.disabled = true
	generate_button.text = "Generating..."
	
	# Generate the map
	var stats = MapGenerator.generate_map(size, tile_pool, hex_tilemap)
	
	# Re-enable button
	generate_button.disabled = false
	generate_button.text = "Generate New Map"
	
	if "error" in stats:
		print("MapGeneratorDemo: Generation failed: ", stats.error)
		_show_error("Generation failed: " + stats.error)
	else:
		print("MapGeneratorDemo: Generation completed successfully!")
		_update_stats_display()

func _on_clear_pressed():
	print("MapGeneratorDemo: Clearing map")
	hex_tilemap.clear_tiles()
	_update_stats_display()

func _on_tile_created(coordinate: Vector2i, tile: Tile):
	print("MapGeneratorDemo: Tile created at ", coordinate, " type: ", tile.tile_type)

func _on_tile_removed(coordinate: Vector2i):
	print("MapGeneratorDemo: Tile removed at ", coordinate)

func _on_tilemap_cleared():
	print("MapGeneratorDemo: Tilemap cleared")

func _update_stats_display():
	var stats = hex_tilemap.get_tilemap_stats()
	var stats_text = ""
	
	if stats.total_tiles == 0:
		stats_text = "No map generated yet"
	else:
		stats_text = "Total tiles: " + str(stats.total_tiles) + "\n"
		stats_text += "Bounds: " + str(stats.bounds.min) + " to " + str(stats.bounds.max) + "\n"
		stats_text += "Tile types:\n"
		for tile_type in stats.tile_types:
			stats_text += "  " + tile_type + ": " + str(stats.tile_types[tile_type]) + "\n"
	
	stats_label.text = stats_text

func _show_error(message: String):
	stats_label.text = "ERROR: " + message

# Example API usage functions for demonstration
func _input(event):
	if event is InputEventMouseButton and event.pressed:
		if event.button_index == MOUSE_BUTTON_LEFT:
			_handle_tile_click(event.position)

func _handle_tile_click(mouse_pos: Vector2):
	# Get camera
	var camera = get_viewport().get_camera_3d()
	if not camera:
		return
	
	# Raycast from camera to world
	var from = camera.project_ray_origin(mouse_pos)
	var to = from + camera.project_ray_normal(mouse_pos) * 1000
	
	var space_state = get_world_3d().direct_space_state
	var query = PhysicsRayQueryParameters3D.create(from, to)
	var result = space_state.intersect_ray(query)
	
	if result:
		var world_pos = result.position
		var coordinate = hex_tilemap.get_coordinate_from_world_position(world_pos)
		var tile = hex_tilemap.get_tile_at_coordinate(coordinate)
		
		if tile:
			print("MapGeneratorDemo: Clicked tile at ", coordinate, " type: ", tile.tile_type)
			_show_tile_info(coordinate, tile)
		else:
			print("MapGeneratorDemo: Clicked empty space at ", coordinate)

func _show_tile_info(coordinate: Vector2i, tile: Tile):
	var info = "Clicked Tile Info:\n"
	info += "Coordinate: " + str(coordinate) + "\n"
	info += "Type: " + tile.tile_type + "\n"
	info += "World Position: " + str(tile.global_position) + "\n"
	var walkable = "Unknown"
	if tile.current_tile_data:
		walkable = str(tile.current_tile_data.is_walkable)
	info += "Walkable: " + walkable + "\n"
	
	# Get neighbors
	var neighbors = hex_tilemap.get_neighbors(coordinate, false)
	info += "Neighbors: " + str(neighbors.size()) + "\n"
	for neighbor_coord in neighbors:
		var neighbor_tile = neighbors[neighbor_coord]
		if neighbor_tile:
			info += "  " + str(neighbor_coord) + ": " + neighbor_tile.tile_type + "\n"
	
	print("MapGeneratorDemo: ", info)
	
	# Update stats display temporarily to show tile info
	var original_text = stats_label.text
	stats_label.text = info
	
	# Restore original stats after 3 seconds
	await get_tree().create_timer(3.0).timeout
	if stats_label.text == info: # Only restore if not changed by user
		stats_label.text = original_text
