@tool
@icon("res://addons/2d_shapes/Polygon.svg")
class_name Polygon extends GeometricShape

const GeometricShape = preload("GeometricShape.gd")
const SizeHandle = preload("../handles/SizeHandle.gd")
const ScalarHandle = preload("../handles/ScalarHandle.gd")


const default_corner_radius := 10
const default_size := 100
const default_sides := 5


@export_range(3, 20) var sides: int = default_sides:
	get:
		return sides
	set(value):
		sides = clamp(value, 3, 20)
		if regular:
			size = size
		else:
			generate_geometry()


@export var size: Vector2 = Vector2(default_size, default_size):
	get:
		return size
	set(value):
		if regular:
			var corners = 2 * corner_radius
			var aspect = get_unitary_dimensions().aspect()

			var fit_x :=  Vector2(value.x, ((value.x - corners) / aspect) + corners)
			var fit_y := Vector2(((value.y - corners) * aspect) + corners, value.y)
			
			value = fit_x if is_equal_approx(size.y, value.y) else fit_y
		
		size.x = clamp(value.x, max(2.0, corner_radius * 2), 10000)
		size.y = clamp(value.y, max(2.0, corner_radius * 2), 10000)
		generate_geometry()


@export var corner_radius: float = default_corner_radius:
	get:
		return corner_radius
	set(value):
		corner_radius = clamp(value, 0.0, size[size.min_axis_index()] / 2)
		if regular:
			size = size
		generate_geometry()


@export var regular: bool = false:
	get:
		return regular
	set(value):
		regular = value
		size = size


func _ready():
	generate_geometry()


func get_unitary_dimensions() -> Vector2:
	"""Width and height of a regular polygon of radius 1.0"""
	var corners = 2 * corner_radius
	var step := TAU / sides
	var half_step := step / 2
	var start := PI / 2 if sides % 2 else (PI + step) / 2

	var rightmost_angle := start - roundf((PI / 2) / step) * step
	var unitary_width = 2 * cos(rightmost_angle)
	var unitary_height = 1 + cos(half_step) if sides % 2 else 2 * cos(half_step)
	return Vector2(unitary_width, unitary_height)


func generate_geometry():
	polygon = []
	var centers = get_centers()

	if sides % 2:
		var radius_y = -centers[0].y
		for i in range(centers.size()):
			centers[i].y += radius_y - (size.y / 2) + corner_radius
	
	for i in range(sides):
		var previous = centers[i - 1]
		var current = centers[i]
		var next = centers[(i + 1) % sides]

		var angle_to_previous = -current.angle_to_point(previous) - PI / 2
		var angle_to_next = -current.angle_to_point(next) + PI / 2
		polygon.append_array(arc(angle_to_previous, angle_to_next, current, corner_radius))
	
	queue_redraw()


func get_centers() -> PackedVector2Array:
	var unitary_dimensions := get_unitary_dimensions()
	var size_minus_corner_radius := size - Vector2.ONE * corner_radius * 2
	var radius_x := size_minus_corner_radius.x / unitary_dimensions.x
	var radius_y := size_minus_corner_radius.y / unitary_dimensions.y

	# Protect against radius being too small, since it causes triangulation problems
	radius_x  = max(radius_x, 0.01)
	radius_y  = max(radius_y, 0.01)

	var step := TAU / sides
	var start := PI / 2 if sides % 2 else (PI + step) / 2
	
	var angle = start
	var centers: PackedVector2Array = []
	for i in range(sides):
		var x = radius_x * cos(angle)
		var y = radius_y * -sin(angle)
		centers.append(Vector2(x, y))
		angle -= step
	
	return centers


func draw_handles(overlay: Control) -> Array:
	var half_size := size / 2
	var half_step := PI / sides

	var handles = []

	# TODO fix magnitude
	var magnitude = get_unitary_dimensions().x / (2 * sin(half_step))
	var corner_x = (size.x / 2 - corner_radius) / magnitude
	handles.push_back(ScalarHandle.new(self, Vector2(corner_x, half_size.y), 'corner_radius', Vector2.LEFT * magnitude))

	# Starting from top-left, clockwise order.
	for i in range(8):
		handles.push_back(SizeHandle.new(self, i))
	
	# On click, the first handle on the array has priority. Visuals should reflect
	# that by drawing the first handle on top.
	for i in range(handles.size() - 1, -1, -1):
		handles[i].draw(overlay)
	
	return handles
