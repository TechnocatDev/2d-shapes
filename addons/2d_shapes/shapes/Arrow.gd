@tool
@icon("res://addons/2d_shapes/Arrow.svg")
class_name Arrow extends GeometricShape

const GeometricShape = preload("GeometricShape.gd")
const TargetHandle = preload("../handles/TargetHandle.gd")
const ArrowScalarHandle = preload("../handles/ArrowScalarHandle.gd")


const default_corner_radius := 0.0


@export var target: Vector2 = Vector2.RIGHT * 200:
	get:
		return target
	set(value):
		var min_length := head_length + corner_radius
		target = value if value.length() > min_length else min_length * value.normalized()
		generate_geometry()


@export var corner_radius: float = default_corner_radius:
	get:
		return corner_radius
	set(value):
		corner_radius = clamp(value, 0, min(head_width - stem_width, head_length, stem_width) / 2)
		generate_geometry()


@export var head_length: float = 60:
	get:
		return head_length
	set(value):
		var arrow_length = target.length()
		head_length = clamp(value, corner_radius * 2, arrow_length - corner_radius)
		generate_geometry()


@export var head_width: float = 60:
	get:
		return head_width
	set(value):
		head_width = clamp(value, corner_radius * 2 + stem_width, 10000)
		generate_geometry()


@export var stem_width: float = 30:
	get:
		return stem_width
	set(value):
		stem_width = clamp(value, 2 * corner_radius, head_width - 2 * corner_radius)
		generate_geometry()


func _ready():
	generate_geometry()


func generate_geometry():
	var arrow_rotation := -target.angle() - PI / 2
	var arrow_length := target.length()
	var head_transform := Transform2D(arrow_rotation, Vector2(0, arrow_length))
	var nock_transform := Transform2D(arrow_rotation, Vector2.ZERO)
	polygon = head(head_transform)
	polygon.append_array(nock(nock_transform))
	queue_redraw()


func head(head_transform: Transform2D) -> PackedVector2Array:
	# Find circles' centers
	var left_circle_center = Vector2(-head_width / 2 + corner_radius, head_length - corner_radius)
	var top_circle_center = Vector2(0, corner_radius)
	var right_circle_center = Vector2(head_width / 2 - corner_radius, head_length - corner_radius)
	
	var points: PackedVector2Array = [Vector2(-stem_width / 2, head_length)]
	
	# Left
	var left_start_angle = 3 * PI / 2
	var left_end_angle = -left_circle_center.angle_to_point(top_circle_center) + PI / 2
	points.append_array(arc(left_start_angle, left_end_angle, left_circle_center, corner_radius))
	# Top
	var top_end_angle = -left_end_angle + PI
	points.append_array(arc(left_end_angle, top_end_angle, top_circle_center, corner_radius))
	# Right
	points.append_array(arc(top_end_angle, left_start_angle, right_circle_center, corner_radius))
	points.append(Vector2(stem_width / 2, head_length))
	for i in range(points.size()):
		points[i] *= head_transform
	return points


func nock(nock_transform: Transform2D) -> PackedVector2Array:
	var center_x = stem_width / 2 - corner_radius
	var points: PackedVector2Array = arc(0.0, -PI / 2, Vector2(center_x, -corner_radius), corner_radius)
	points.append_array(arc(-PI / 2, PI, Vector2(-center_x, -corner_radius), corner_radius))
	for i in range(points.size()):
		points[i] *= nock_transform
	return points


func draw_handles(overlay: Control) -> Array:
	var arrow_length := target.length()
	var handles = []
	
	handles.push_back(TargetHandle.new(self))
	
	handles.push_back(ArrowScalarHandle.new(self, Vector2(head_width / 2 - corner_radius, head_length), 'corner_radius', Vector2.LEFT))
	handles.push_back(ArrowScalarHandle.new(self, Vector2(0, head_length), 'head_length', Vector2.DOWN, true))
	handles.push_back(ArrowScalarHandle.new(self, Vector2(-head_width / 2, head_length - corner_radius), 'head_width', Vector2.LEFT * 2, true))
	handles.push_back(ArrowScalarHandle.new(self, Vector2(stem_width / 2, head_length + (arrow_length - head_length - corner_radius) / 2), 'stem_width', Vector2.RIGHT * 2, true))
	
	for i in range(handles.size() - 1, -1, -1):
		handles[i].draw(overlay)
	
	return handles

