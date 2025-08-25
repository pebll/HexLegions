@tool
extends Node3D
class_name Unit

var unit_type: String = "": set = set_unit_type
@export var unit_config: UnitConfigResource = preload("res://data/unit_config.tres")

var current_unit_data: UnitData = null

var model: Model = null

func _ready():
	add_to_group("units")
	# Find the Model child node
	model = _find_model_child()
	
	# Initialize unit data if not already set
	if not current_unit_data and unit_type != "":
		current_unit_data = unit_config.get_unit_data(unit_type)
	_update_children()

func _find_model_child() -> Model:
	# Look for a direct child that is a Model
	for child in get_children():
		if child is Model:
			return child
	print("Unit: No Model child found")
	return null

func set_unit_type(new_type: String):
	if new_type == unit_type:
		return
	
	if not unit_config.unit_exists(new_type):
		print("Unit: Unit type does not exist: ", new_type)
		return
	
	unit_type = new_type
	current_unit_data = unit_config.get_unit_data(unit_type)
	if not current_unit_data:
		print("Unit: No unit data found for type: ", unit_type)
		return
	
	_update_children()
	notify_property_list_changed()

func _update_children():
	print("Unit: Updating children")
	if not model:
		print("Unit: Model reference is null")
		return
	if not current_unit_data:
		print("Unit: Current unit data is null")
		return
	if not current_unit_data.model_id:
		print("Unit: Model ID is empty")
		return
	
	model.set_model_id(current_unit_data.model_id)


# Editor dropdown
func _get_property_list():
	var properties = []
	
	# Dynamically generate dropdown from unit config
	var unit_type_hint_string = ""
	if unit_config:
		var unit_ids = unit_config.get_all_unit_ids()
		unit_type_hint_string = ",".join(unit_ids)
	else:
		# Fallback if no config is set
		unit_type_hint_string = "unit_fox"
	
	properties.append({
		"name": "unit_type",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": unit_type_hint_string
	})
	
	return properties
