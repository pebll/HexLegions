@tool
extends Resource
class_name ModelConfigResource

@export var models: Array[ModelData] = []

func get_model_data(model_id: String) -> ModelData:
	for model_data in models:
		if model_data.model_id == model_id:
			return model_data
	return null

func get_all_model_ids() -> Array:
	var ids = []
	for model_data in models:
		ids.append(model_data.model_id)
	return ids

func model_exists(model_id: String) -> bool:
	return get_model_data(model_id) != null
