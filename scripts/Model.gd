@tool
extends Node3D
class_name Model

var model_id: String = "model_fox": set = set_model_id
var default_animation: String = "idle": set = _set_default_animation
@export var model_config: ModelConfigResource = preload("res://data/model_config.tres")

var current_model: Node3D
var animation_player: AnimationPlayer
var current_model_data: ModelData = null

func _ready():
	add_to_group("models")
	_update_model()

# API Call: Set new model id
func set_model_id(new_id: String):
	if new_id == model_id:
		return
	
	if not new_id or new_id == "":
		print("Model: Invalid model ID provided")
		return
	
	model_id = new_id
	_update_model()
	notify_property_list_changed()

func _set_default_animation(new_animation: String):
	default_animation = new_animation
	if current_model_data:
		play_animation(default_animation)

func _update_model():
	print("Model: Updating model")
	if not model_config:
		print("Model: No model config provided")
		return
	
	if not model_id or model_id == "":
		print("Model: No model ID set")
		return
	
	# Try to get model data safely
	var model_data = null
	if model_config.has_method("get_model_data"):
		model_data = model_config.get_model_data(model_id)
	
	if not model_data:
		print("No model data found for type: ", model_id)
		return
	
	print("Found model data for: ", model_data.model_id)
	current_model_data = model_data
	
	# Remove current model
	if current_model:
		current_model.queue_free()
	
	# Load and add new model
	if ResourceLoader.exists(model_data.model_path):
		var model_scene = load(model_data.model_path) as PackedScene
		if model_scene:
			current_model = model_scene.instantiate()
			add_child(current_model)
			
			# Scale
			current_model.scale = Vector3(model_data.scale_factor, model_data.scale_factor, model_data.scale_factor)
			if current_model_data.animated:
				# Find and setup animation player
				animation_player = _find_animation_player(current_model)
				if animation_player:
					print("Found AnimationPlayer, playing default animation: ", default_animation)
					play_animation(default_animation)
		else:
			print("Failed to load model scene from: ", model_data.model_path)
	else:
		print("Model path not found: ", model_data.model_path)

func _find_animation_player(node: Node) -> AnimationPlayer:
	if not current_model_data.animated:
		print("Model: Model is not animated")
		return null
	if node is AnimationPlayer:
		return node
	for child in node.get_children():
		var result = _find_animation_player(child)
		if result:
			return result
	return null

# API Call: Play animation
func play_animation(animation: String):
	if not current_model_data.animated:
		print("Model: Model is not animated")
		return
	if not animation_player:
		print("Model: No animation player found")
		return
	if not current_model_data:
		print("Model: No model data found")
		return
	if not current_model_data.animations.has(animation) or current_model_data.animations[animation] == "":
		print("Model: No model animation found for: ", animation)
		return

	var model_animation = String(current_model_data.animations[animation])

	if animation_player.has_animation(model_animation):
		var model_animation_res = animation_player.get_animation(model_animation)
		if model_animation_res:
			model_animation_res.loop_mode = Animation.LOOP_LINEAR
		animation_player.play(model_animation)
		print("Model: Playing ", animation, " animation: ", model_animation)
		return

	print("Model: Model animation ", model_animation, " does not exist on animation player")


# Editor dropdown
func _get_property_list():
	var properties = []
	
	# Dynamically generate dropdown from model config
	var hint_string = ""
	var animation_hint_string = ""
	if model_config:
		var model_ids = model_config.get_all_model_ids()
		hint_string = ",".join(model_ids)
		
		# Get available animations for current model
		if current_model_data and current_model_data.animated:
			var animations = []
			for anim_key in current_model_data.animations.keys():
				if current_model_data.animations[anim_key] != "":
					animations.append(anim_key)
			if animations.size() > 0:
				animation_hint_string = ",".join(animations)
			else:
				animation_hint_string = "idle"
		else:
			animation_hint_string = "idle"
	else:
		# Fallback if no config is set
		hint_string = "model_fox"
		animation_hint_string = "idle"
	
	properties.append({
		"name": "model_id",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": hint_string
	})

	properties.append({
		"name": "default_animation",
		"type": TYPE_STRING,
		"hint": PROPERTY_HINT_ENUM,
		"hint_string": animation_hint_string
	})
	
	return properties
