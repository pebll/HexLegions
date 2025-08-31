extends Resource
class_name HexTileData

@export var tile_id: String = ""
@export var display_name: String = ""
@export var model_id: String = ""
@export var is_walkable: bool = true

func _init(id: String = "", name: String = "", model_id_: String = ""):
	tile_id = id
	display_name = name
	model_id = model_id_
