@tool
extends Node3D
class_name Tile

var tile_type: String = "": set = set_tile_type
@export var tile_config: HexTileConfigResource = preload("res://data/tile_config.tres")

var current_tile_data: HexTileData = null

var model: Model = null

func _ready():
	add_to_group("tiles")
	# Find the Model child node
	model = _find_model_child()
	
	# Initialize tile data if not already set
	if not current_tile_data and tile_type != "":
		current_tile_data = tile_config.get_tile_data(tile_type)
	_update_children()

func _find_model_child() -> Model:
	# Look for a direct child that is a Model
	for child in get_children():
		if child is Model:
			return child
	print("Tile: No Model child found")
	return null

func set_tile_type(new_type: String):
	if new_type == tile_type:
		return
	
	if not tile_config.tile_exists(new_type):
		print("Tile: Tile type does not exist: ", new_type)
		return
	
	tile_type = new_type
	current_tile_data = tile_config.get_tile_data(tile_type)
	if not current_tile_data:
		print("Tile: No tile data found for type: ", tile_type)
		return
	
	_update_children()
	notify_property_list_changed()

func _update_children():
	print("Tile: Updating children")
	if not model:
		print("Tile: Model reference is null")
		return
	if not current_tile_data:
		print("Tile: Current tile data is null")
		return
	if not current_tile_data.model_id:
		print("Tile: Model ID is empty")
		return
	
	model.set_model_id(current_tile_data.model_id)


# Editor dropdown
func _get_property_list():
	var properties = []
	
	# Dynamically generate dropdown from tile config
	var tile_type_hint_string = ""
	if tile_config:
		var tile_ids = tile_config.get_all_tile_ids()
		tile_type_hint_string = ",".join(tile_ids)
	else:
		# Fallback if no config is set
		tile_type_hint_string = "tile_hex_forest_detail"
	
	properties.append({
		"name": "tile_type",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": tile_type_hint_string
	})
	
	return properties
