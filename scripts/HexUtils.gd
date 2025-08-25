@tool
extends RefCounted
class_name HexUtils

## Simple hex grid utilities based on Red Blob Games implementation
## https://www.redblobgames.com/grids/hexagons/

# Hex layout settings
var size: float
var orientation: String # "pointy" or "flat"
var origin: Vector2

func _init(hex_size: float = 1.0, hex_orientation: String = "pointy", hex_origin: Vector2 = Vector2.ZERO):
	size = hex_size
	orientation = hex_orientation
	origin = hex_origin

## Convert axial coordinates to world position
func axial_to_world(q: int, r: int) -> Vector2:
	if orientation == "pointy":
		var x = size * (sqrt(3.0) * q + sqrt(3.0) / 2.0 * r)
		var y = size * (3.0 / 2.0 * r)
		return Vector2(x, y) + origin
	else: # flat
		var x = size * (3.0 / 2.0 * q)
		var y = size * (sqrt(3.0) / 2.0 * q + sqrt(3.0) * r)
		return Vector2(x, y) + origin

## Convert world position to axial coordinates
func world_to_axial(pos: Vector2) -> Vector2i:
	var local_pos = pos - origin
	var q: float
	var r: float
	
	if orientation == "pointy":
		q = (sqrt(3.0) / 3.0 * local_pos.x - 1.0 / 3.0 * local_pos.y) / size
		r = (2.0 / 3.0 * local_pos.y) / size
	else: # flat
		q = (2.0 / 3.0 * local_pos.x) / size
		r = (-1.0 / 3.0 * local_pos.x + sqrt(3.0) / 3.0 * local_pos.y) / size
	
	return round_axial(q, r)

## Round floating point axial coordinates to integers
func round_axial(q: float, r: float) -> Vector2i:
	var s = -q - r
	var rq = round(q)
	var rr = round(r)
	var rs = round(s)
	
	var q_diff = abs(rq - q)
	var r_diff = abs(rr - r)
	var s_diff = abs(rs - s)
	
	if q_diff > r_diff and q_diff > s_diff:
		rq = - rr - rs
	elif r_diff > s_diff:
		rr = - rq - rs
	
	return Vector2i(int(rq), int(rr))

## Get hex coordinates in a radius around center
func get_coords_in_radius(center_q: int, center_r: int, radius: int) -> Array[Vector2i]:
	var coords: Array[Vector2i] = []
	
	for q in range(-radius, radius + 1):
		var r1 = max(-radius, -q - radius)
		var r2 = min(radius, -q + radius)
		for r in range(r1, r2 + 1):
			coords.append(Vector2i(center_q + q, center_r + r))
	
	return coords

## Get the 6 neighbors of a hex
func get_neighbors(q: int, r: int) -> Array[Vector2i]:
	var directions = [
		Vector2i(1, 0), Vector2i(1, -1), Vector2i(0, -1),
		Vector2i(-1, 0), Vector2i(-1, 1), Vector2i(0, 1)
	]
	
	var neighbors: Array[Vector2i] = []
	for direction in directions:
		neighbors.append(Vector2i(q + direction.x, r + direction.y))
	
	return neighbors

## Calculate distance between two hex coordinates
func distance(q1: int, r1: int, q2: int, r2: int) -> int:
	return (abs(q1 - q2) + abs(q1 + r1 - q2 - r2) + abs(r1 - r2)) / 2
