@tool
@icon("res://addons/2d_shapes/Ellipse.svg")
class_name Ellipse
extends GeometricShape

const GeometricShape = preload("GeometricShape.gd")
const SizeHandle = preload("../handles/SizeHandle.gd")

const default_size := 100.0


func _ready():
	generate_geometry()


@export var size: Vector2 = Vector2(default_size, default_size):
	get:
		return size
	set(value):
		if circle:
			var fit_x :=  Vector2(value.x, value.x)
			var fit_y := Vector2(value.y, value.y)
			
			value = fit_x if is_equal_approx(size.y, value.y) else fit_y
		
		size.x = clamp(value.x, 3, 10000)
		size.y = clamp(value.y, 3, 10000)
		generate_geometry()


@export var circle: bool = false:
	get:
		return circle
	set(value):
		circle = value
		size = size


func generate_geometry():
	polygon = arc(TAU, 0, Vector2.ZERO, min(size.x, size.y) / 2)
	
	for i in range(polygon.size()):
		polygon[i][size.max_axis_index()] *= max(size.x, size.y) / min(size.x, size.y)
	
	queue_redraw()


func draw_handles(overlay: Control) -> Array:
	var handles = []
	
	# Starting from top-left, clockwise order.
	for i in range(8):
		handles.push_back(SizeHandle.new(self, i))
	
	# On click, the first handle on the array has priority. Visuals should reflect
	# that by drawing the first handle on top.
	for i in range(handles.size() - 1, -1, -1):
		handles[i].draw(overlay)
	
	return handles

