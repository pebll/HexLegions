extends Resource
class_name UnitData

@export var unit_id: String = ""
@export var display_name: String = ""
@export var model_id: String = ""
@export var default_attack: int = 2
@export var default_health: int = 6
@export var movement_speed: float = 5.0
@export var description: String = ""

func _init(id: String = "", name: String = "", model_id_: String = ""):
	unit_id = id
	display_name = name
	model_id = model_id_
