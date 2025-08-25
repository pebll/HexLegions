extends Node3D

func _ready():
	print("Test scene loaded successfully!")
	
	# Show info about units
	var units = get_tree().get_nodes_in_group("units")
	print("Found units in scene: ", units.size())
	
	for unit in units:
		if unit is Unit:
			print("Unit: ", unit.name, " - Type: ", unit.unit_type)
	
	# Example: Dynamically create a new unit
	# Uncomment the lines below to test dynamic unit creation
	# var new_unit = Unit.create_unit("unit_wolf", self)
	# if new_unit:
	#     new_unit.global_position = Vector3(2, 1, 2)
	#     print("Created new wolf unit at position: ", new_unit.global_position)

func _process(_delta):
	if Input.is_action_pressed("exit"):
		get_tree().quit()
	
	# Test unit movement with mouse click
	if Input.is_action_just_pressed("ui_accept"):
		var camera = get_node("Camera3D")
		var mouse_pos = get_viewport().get_mouse_position()
		var from = camera.project_ray_origin(mouse_pos)
		var to = from + camera.project_ray_normal(mouse_pos) * 1000
		
		var space_state = get_world_3d().direct_space_state
		var query = PhysicsRayQueryParameters3D.create(from, to)
		var result = space_state.intersect_ray(query)
		
		if result:
			var unit = get_node("Unit")
			if unit:
				unit.move_to_point(Vector2(result.position.x, result.position.z))
				print("Moving unit to: ", result.position)
