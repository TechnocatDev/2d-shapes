extends Node2D


var polygon : PackedVector2Array


@export_enum("Filled", "Outline", "Filled + Outline") var style: int = 0:
	get:
		return style
	set(value):
		style = value
		queue_redraw()


@export var outline_width: int = 1:
	get:
		return outline_width
	set(value):
		outline_width = clamp(value, 0.01, 1000)
		queue_redraw()


@export var fill_color: Color = Color.WHITE:
	get:
		return fill_color
	set(value):
		fill_color = value
		queue_redraw()


@export var outline_color: Color = Color.BLACK:
	get:
		return outline_color
	set(value):
		outline_color = value
		queue_redraw()


func _draw():
	if style == 0 or style == 2:
		# Polygon is assumed to be open, i.e. its last vertex is not equal the first
		# Closed polygons may fail triangulation!
		draw_colored_polygon(polygon, fill_color)
	if style == 1 or style == 2:
		var closed_polygon = polygon.duplicate()
		closed_polygon.push_back(polygon[0])
		draw_polyline(closed_polygon, outline_color, outline_width)


func arc(start: float, end: float, center: Vector2, radius: float) -> PackedVector2Array:
	"""Draw arc in clockwise direction"""
	if radius < 0.01: # Skip drawing if radius is too close to zero
		return [center]
	
	if start < end:
		start += TAU
	
	var step: float = max(asin(4 / radius), 0.1) # Trying to keep distance between points at ~4
	var angle := start - step
	var coords: PackedVector2Array = []
	var start_point = Vector2(cos(start) * radius + center.x, -sin(start) * radius + center.y)
	var end_point = Vector2(cos(end) * radius + center.x, -sin(end) * radius + center.y)
	
	coords.push_back(start_point)
	while angle > end:
		var point = Vector2(cos(angle) * radius + center.x, -sin(angle) * radius + center.y)
		if not point.distance_squared_to(end_point) < 8.0:
			coords.push_back(point)
		angle -= step
	coords.push_back(end_point)
	
	return coords


func draw_handles(overlay: Control) -> Array:
	printerr('Function draw_handles was not implemented')
	return []


func generate_geometry() -> void:
	printerr('Function generate_geometry was not implemented')

