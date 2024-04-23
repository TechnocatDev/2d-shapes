@tool
@icon("res://addons/2d_shapes/Rectangle.svg")
class_name Rectangle
extends GeometricShape

const GeometricShape = preload("GeometricShape.gd")
const Handle = preload("../handles/Handle.gd")
const SizeHandle = preload("../handles/SizeHandle.gd")
const ScalarHandle = preload("../handles/ScalarHandle.gd")

const default_corner_radius := 10.0
const default_size := 100


func _ready():
	generate_geometry()


@export var size: Vector2 = Vector2(default_size, default_size):
	get:
		return size
	set(value):
		if square:
			var fit_x :=  Vector2(value.x, value.x)
			var fit_y := Vector2(value.y, value.y)
			
			value = fit_x if size.y == value.y else fit_y
		
		size.x = clamp(value.x, corner_radius * 2, 10000)
		size.y = clamp(value.y, corner_radius * 2, 10000)
		generate_geometry()


@export var corner_radius: float = default_corner_radius:
	get:
		return corner_radius
	set(value):
		corner_radius = clamp(value, 0.0, size[size.min_axis_index()] / 2)
		generate_geometry()


@export var square: bool = false:
	get:
		return square
	set(value):
		square = value
		size = size


func generate_geometry():
	polygon = []
	polygon.append_array(top_left_corner())
	polygon.append_array(top_right_corner())
	polygon.append_array(bottom_right_corner())
	polygon.append_array(bottom_left_corner())
	for i in range(polygon.size()):
		polygon[i] -= size / 2
	queue_redraw()


func top_left_corner() -> PackedVector2Array:
	return arc(PI, PI/2, Vector2(corner_radius, corner_radius), corner_radius)


func top_right_corner() -> Array:
	return arc(PI/2, 0, Vector2(size.x - corner_radius, corner_radius), corner_radius)


func bottom_right_corner() -> Array:
	return arc(2 * PI, 1.5 * PI, Vector2(size.x - corner_radius, size.y - corner_radius), corner_radius)


func bottom_left_corner() -> Array:
	return arc(1.5 * PI, PI, Vector2(corner_radius, size.y - corner_radius), corner_radius)


func draw_handles(overlay: Control) -> Array:
	var half_size := size / 2

	var handles = []
	handles.push_back(ScalarHandle.new(self, Vector2(half_size.x, -half_size.y + corner_radius), 'corner_radius'))
	# Starting from top-left, clockwise order.
	for i in range(8):
		handles.push_back(SizeHandle.new(self, i))
	
	# On click, the first handle on the array has priority. Visuals should reflect
	# that by drawing the first handle on top.
	for i in range(handles.size() - 1, -1, -1):
		handles[i].draw(overlay)
	
	return handles
