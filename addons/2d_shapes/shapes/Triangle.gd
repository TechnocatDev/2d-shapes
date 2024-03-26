@tool
@icon("res://addons/2d_shapes/Arrow.svg")
class_name Triangle extends GeometricShape

const GeometricShape = preload("GeometricShape.gd")
const SizeHandle = preload("../handles/SizeHandle.gd")
const ScalarHandle = preload("../handles/ScalarHandle.gd")


const default_corner_radius := 20.0
const default_size := default_corner_radius * 3.0
const triangle_height_proportion = sqrt(3.0) / 2.0


@export var size: Vector2 = Vector2(default_size, default_size):
	get:
		return size
	set(value):
		if type == 2:
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
		if type == 2:
			size = size
		generate_geometry()


@export_enum("Isoceles", "Square", "Regular") var type: int = 0:
	get:
		return type
	set(value):
		type = value
		size = size
		generate_geometry()


func _ready():
	generate_geometry()


func generate_geometry():
	if type == 1:
		polygon = generate_square()
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


func generate_square() -> PackedVector2Array:
	var points: PackedVector2Array = []
	# Find circles' centers
	var left_circle_center = Vector2(-size.x / 2 + corner_radius, size.y / 2 - corner_radius)
	var top_circle_center = Vector2(-size.x / 2 + corner_radius, -size.y / 2 + corner_radius)
	var right_circle_center = Vector2(size.x / 2 - corner_radius, size.y / 2 - corner_radius)
	
	# Left
	var left_start_angle = 3 * PI / 2
	var left_end_angle = 2 * PI / 2
	points.append_array(arc(left_start_angle, left_end_angle, left_circle_center, corner_radius))
	# Top
	var top_end_angle = -top_circle_center.angle_to_point(right_circle_center) + PI / 2
	points.append_array(arc(left_end_angle, top_end_angle, top_circle_center, corner_radius))
	# Right
	points.append_array(arc(top_end_angle, left_start_angle, right_circle_center, corner_radius))
	return points


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
