extends Resource
class_name ModelData

@export var model_id: String = ""
@export var model_path: String = ""
@export var scale_factor: float = 1.0

# Animation mappings specific to this model
# Keys: "idle", "walk", "attack" → values are animation names in the AnimationPlayer
@export var animated: bool = true
@export var animations: Dictionary = {
	"idle": "Idle",
	"idle_alt": "",
	"walk": "Walk",
	"attack": "Attack"
}

func _init(id: String = "", path: String = ""):
	model_id = id
	model_path = path
