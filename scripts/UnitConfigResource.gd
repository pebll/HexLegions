@tool
extends Resource
class_name UnitConfigResource

@export var units: Array[UnitData] = []

func get_unit_data(unit_id: String) -> UnitData:
	for unit_data in units:
		if unit_data.unit_id == unit_id:
			return unit_data
	return null

func get_all_unit_ids() -> Array:
	var ids = []
	for unit_data in units:
		ids.append(unit_data.unit_id)
	return ids

func unit_exists(unit_id: String) -> bool:
	return get_unit_data(unit_id) != null
