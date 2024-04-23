@tool
@icon("res://addons/2d_shapes/Triangle.svg")
class_name Triangle extends GeometricShape

const GeometricShape = preload("GeometricShape.gd")
const SizeHandle = preload("../handles/SizeHandle.gd")
const ScalarHandle = preload("../handles/ScalarHandle.gd")


const default_corner_radius := 10
const triangle_height_proportion = sqrt(3.0) / 2.0


@export var size: Vector2 = Vector2(100, 89.282):
	get:
		return size
	set(value):
		if type == 1:
			var corners = 2 * corner_radius
			var fit_x :=  Vector2(value.x, ((value.x - corners) * triangle_height_proportion) + corners)
			var fit_y := Vector2(((value.y - corners) / triangle_height_proportion) + corners, value.y)
			
			value = fit_x if is_equal_approx(size.y, value.y) else fit_y
		
		size.x = clamp(value.x, max(2.0, corner_radius * 2), 10000)
		size.y = clamp(value.y, max(2.0, corner_radius * 2), 10000)
		generate_geometry()


@export var corner_radius: float = default_corner_radius:
	get:
		return corner_radius
	set(value):
		corner_radius = clamp(value, 0.0, size[size.min_axis_index()] / 2)
		if type == 1:
			size = size
		generate_geometry()


@export_enum("▲ Isoceles", "▲ Regular", "◢ Lower Right", "◣ Lower Left", "◤ Upper Left", "◥ Upper Right") var type: int = 0:
	get:
		return type
	set(value):
		type = value
		size = size
		generate_geometry()


func _ready():
	generate_geometry()


func generate_geometry():
	if type > 1:
		polygon = generate_right()
	else:
		polygon = generate_isoceles()
	queue_redraw()


func generate_isoceles() -> PackedVector2Array:
	var points: PackedVector2Array = []
	# Find circles' centers
	var left_circle_center = Vector2(-size.x / 2 + corner_radius, size.y / 2 - corner_radius)
	var top_circle_center = Vector2(0, -size.y / 2 + corner_radius)
	var right_circle_center = Vector2(size.x / 2 - corner_radius, size.y / 2 - corner_radius)
	
	# Left
	var left_start_angle = 3 * PI / 2
	var left_end_angle = -left_circle_center.angle_to_point(top_circle_center) + PI / 2
	points.append_array(arc(left_start_angle, left_end_angle, left_circle_center, corner_radius))
	# Top
	var top_end_angle = -left_end_angle + PI
	points.append_array(arc(left_end_angle, top_end_angle, top_circle_center, corner_radius))
	# Right
	points.append_array(arc(top_end_angle, left_start_angle, right_circle_center, corner_radius))
	return points


func generate_right() -> PackedVector2Array:
	var points: PackedVector2Array = []
	# Find circles' centers
	var centers := right_triangle_offsets()
	
	for i in range(3):
		var previous = centers[i - 1]
		var current = centers[i]
		var next = centers[(i + 1) % 3]

		var angle_to_previous = -current.angle_to_point(previous) - PI / 2
		var angle_to_next = -current.angle_to_point(next) + PI / 2
		points.append_array(arc(angle_to_previous, angle_to_next, current, corner_radius))
	
	return points


func right_triangle_offsets() -> PackedVector2Array:
	var half_size_minus_corner_radius := size / 2 - Vector2.ONE * corner_radius

	# Avoid zero size, because it causes triangulation error
	half_size_minus_corner_radius.x = max(half_size_minus_corner_radius.x, 0.01)
	half_size_minus_corner_radius.y = max(half_size_minus_corner_radius.y, 0.01)

	var offsets: PackedVector2Array = [
		Vector2(-half_size_minus_corner_radius.x, -half_size_minus_corner_radius.y),
		Vector2(half_size_minus_corner_radius.x, -half_size_minus_corner_radius.y),
		Vector2(half_size_minus_corner_radius.x, half_size_minus_corner_radius.y),
		Vector2(-half_size_minus_corner_radius.x, half_size_minus_corner_radius.y)
	]
	if type == 2:
		return [offsets[1], offsets[2], offsets[3]]
	if type == 3:
		return [offsets[0], offsets[2], offsets[3]]
	if type == 4:
		return [offsets[0], offsets[1], offsets[3]]
	if type == 5:
		return [offsets[0], offsets[1], offsets[2]]
	printerr("Unknown triangle type", type)
	return [offsets[1], offsets[2], offsets[3]]


func draw_handles(overlay: Control) -> Array:
	var half_size := size / 2

	var handles = []
	handles.push_back(ScalarHandle.new(self, Vector2(half_size.x - corner_radius, half_size.y), 'corner_radius', Vector2.LEFT))
	# Starting from top-left, clockwise order.
	for i in range(8):
		handles.push_back(SizeHandle.new(self, i))
	
	# On click, the first handle on the array has priority. Visuals should reflect
	# that by drawing the first handle on top.
	for i in range(handles.size() - 1, -1, -1):
		handles[i].draw(overlay)
	
	return handles
