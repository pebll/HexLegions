@tool
extends Node3D
class_name ForcePoint

const MAX_FORCE: float = 10
const MAX_RANGE: float = 10

@export_range(MAX_RANGE / 100, MAX_RANGE, MAX_RANGE / 1000) var effect_range: float = MAX_RANGE / 2
@export_range(-MAX_FORCE, MAX_FORCE, MAX_FORCE / 1000) var force: float = MAX_FORCE / 2
@export var is_static: bool = false

static var all_points: Array[ForcePoint] = []
var velocity: Vector2 = Vector2.ZERO

# Simplified constants for better settling
const DAMPING: float = 0.85
const MAX_SPEED: float = 0.003
const MIN_VELOCITY_THRESHOLD: float = 0.0001
const MIN_FORCE_THRESHOLD: float = 0.001

func _ready():
	all_points.append(self)
	set_notify_transform(true)
	_draw_gizmos()

func _exit_tree():
	all_points.erase(self)

func _physics_process(delta):
	if is_static:
		return
	
	var total_force = calculate_force()
	
	# Stop tiny movements to help settling
	if total_force.length() < MIN_FORCE_THRESHOLD and velocity.length() < MIN_VELOCITY_THRESHOLD:
		velocity = Vector2.ZERO
		return
	
	# Apply force with proper physics
	velocity += total_force * delta
	velocity *= DAMPING # Apply damping
	velocity = velocity.limit_length(MAX_SPEED)
	
	# Update position
	global_position.x += velocity.x
	global_position.z += velocity.y

func calculate_force() -> Vector2:
	var total_force = Vector2.ZERO
	var my_pos = Vector2(global_position.x, global_position.z)
	
	for point in all_points:
		if point == self:
			continue
		
		var other_pos = Vector2(point.global_position.x, point.global_position.z)
		var diff = my_pos - other_pos
		var distance = diff.length()
		
		# Skip if outside range or too close (prevents singularity)
		if distance > point.effect_range or distance < 0.01:
			continue
		
		# Use inverse square law with softening to prevent singularities
		var normalized_distance = distance / point.effect_range
		var softened_distance = max(normalized_distance, 0.1) # Prevent division by very small numbers
		var force_magnitude = point.force / (softened_distance * softened_distance)
		
		# Clamp force magnitude to prevent explosive behavior
		force_magnitude = clamp(force_magnitude, -MAX_FORCE * 2, MAX_FORCE * 2)
		
		total_force += diff.normalized() * force_magnitude
	
	return total_force

func _notification(what):
	if what == NOTIFICATION_TRANSFORM_CHANGED:
		_draw_gizmos()

func _draw_gizmos():
	# Draw force point as colored sphere
	var color = Color.BLACK
	if is_static:
		color = Color.RED if force < 0 else Color.BLUE
	else:
		color = Color.GREEN if force > 0 else Color.ORANGE
	
	var size = abs(force) * 0.1
	DebugDraw3D.draw_sphere(global_position, size, color)
	
	# Draw velocity arrow for moving points
	if !is_static and velocity.length() > 0.0001:
		var arrow_end = global_position + Vector3(velocity.x, 0, velocity.y) * 200
		DebugDraw3D.draw_arrow_line(global_position, arrow_end, Color.WHITE, 0.05)
