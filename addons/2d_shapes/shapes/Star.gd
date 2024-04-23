@tool
@icon("res://addons/2d_shapes/Star.svg")
class_name Star extends GeometricShape

const GeometricShape = preload("GeometricShape.gd")
const SizeHandle = preload("../handles/SizeHandle.gd")
const ScalarHandle = preload("../handles/ScalarHandle.gd")


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


@export var size: Vector2 = Vector2(95.106, 95.106):
	get:
		return size
	set(value):
		if regular:
			var aspect = get_unitary_dimensions().aspect()

			var fit_x :=  Vector2(value.x, value.x / aspect)
			var fit_y := Vector2(value.y * aspect, value.y)
			
			value = fit_x if is_equal_approx(size.y, value.y) else fit_y
		
		size.x = clamp(value.x, 2.0, 10000)
		size.y = clamp(value.y, 2.0, 10000)
		generate_geometry()


@export_range(0.01, 1) var inner_proportion: float = 0.4:
	get:
		return inner_proportion
	set(value):
		var half_step := PI / sides
		inner_proportion = clamp(value, 0.01, cos(half_step))
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
	var step := TAU / sides
	var half_step := step / 2
	var start := PI / 2 if sides % 2 else (PI + step) / 2

	var rightmost_angle := start - roundf((PI / 2) / step) * step
	var unitary_width = 2 * cos(rightmost_angle)
	var unitary_height = 1 + cos(half_step) if sides % 2 else 2 * cos(half_step)
	return Vector2(unitary_width, unitary_height)


func generate_geometry():
	polygon = []

	var unitary_dimensions := get_unitary_dimensions()
	var half_step := PI / sides

	var offset_y := unitary_dimensions.y / 2 - 1 if sides % 2 else 0.0

	var transform := Transform2D(0.0, size / unitary_dimensions, 0.0, Vector2(0.0, offset_y))

	var outer_point = Vector2(1.0, 0.0)
	var inner_point = Vector2(inner_proportion, 0.0) * Transform2D(-half_step, Vector2.ZERO)

	for angle in get_angles():
		polygon.append(outer_point * transform.rotated(angle))
		polygon.append(inner_point * transform.rotated(angle))
	
	queue_redraw()


func get_angles() -> PackedFloat32Array:
	var step := TAU / sides
	var start := PI / 2 if sides % 2 else (PI + step) / 2
	
	var angle = start
	var angles: PackedFloat32Array = []
	for i in range(sides):
		angles.append(angle)
		angle -= step
	
	return angles


func draw_handles(overlay: Control) -> Array:
	var half_size := size / 2
	var half_step := PI / sides

	var handles = []

	var unitary_dimensions := get_unitary_dimensions()
	var radius := size.y / unitary_dimensions.y
	var offset_y := unitary_dimensions.y / 2 - 1 if sides % 2 else 0.0
	var inner_corner_y = radius * inner_proportion - offset_y * radius
	var magnitude = 1 / radius
	handles.push_back(ScalarHandle.new(self, Vector2(0, inner_corner_y), 'inner_proportion', Vector2.DOWN * magnitude))

	# Starting from top-left, clockwise order.
	for i in range(8):
		handles.push_back(SizeHandle.new(self, i))
	
	# On click, the first handle on the array has priority. Visuals should reflect
	# that by drawing the first handle on top.
	for i in range(handles.size() - 1, -1, -1):
		handles[i].draw(overlay)
	
	return handles
