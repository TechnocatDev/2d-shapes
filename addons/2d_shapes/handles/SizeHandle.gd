extends Handle

const Handle = preload("Handle.gd")


const position_offsets := [
	Vector2(-0.5, -0.5),
	Vector2(0, -0.5),
	Vector2(0.5, -0.5),
	Vector2(0.5, 0),
	Vector2(0.5, 0.5),
	Vector2(0, 0.5),
	Vector2(-0.5, 0.5),
	Vector2(-0.5, 0)
]
const size_transforms := [
	-Vector2.ONE,
	Vector2.UP,
	Vector2(1, -1),
	Vector2.RIGHT,
	Vector2.ONE,
	Vector2.DOWN,
	Vector2(-1, 1),
	Vector2.LEFT,
]

var _index: int
var size_transform: Vector2
var keep_aspect_ratio := false

# previous drag state
var drag_start : Dictionary = {
	'size': Vector2(),
	'transform': Transform2D(),
	'position': Vector2(),
	'mouse_position': Vector2()
}


func _init(selected_shape: GeometricShape, index: int):
	var transform_viewport := selected_shape.get_viewport_transform()
	var transform_global := selected_shape.get_global_transform_with_canvas()
	var pos = transform_viewport * transform_global * (position_offsets[index] * selected_shape.size)
	shape = selected_shape
	transform = Transform2D(0.0, pos)
	_index = index
	size_transform = size_transforms[index]


func draw(overlay: Control):
	var global_rotation := shape.global_rotation
	overlay.draw_set_transform_matrix(transform.rotated_local(global_rotation))
	var rect := Rect2(Vector2(2,2), Vector2(4,4))
	overlay.draw_rect(Rect2(Vector2(-5,-5), Vector2(10,10)), Color.BLACK)
	overlay.draw_rect(Rect2(Vector2(-4,-4), Vector2(8,8)), Color.WHITE)
	overlay.draw_rect(Rect2(Vector2(-3,-3), Vector2(6,6)), Color.ORANGE_RED)
	if _index == 0:
		var transform_global := shape.get_global_transform_with_canvas()
		var transform_viewport := shape.get_viewport_transform()
		var scale_total := transform_viewport.get_scale() * transform_global.get_scale()
		var bounding_rect = Rect2(Vector2.ZERO, scale_total * shape.size)
		overlay.draw_rect(bounding_rect, Color.ORANGE_RED, false, 1)
	overlay.draw_set_transform_matrix(Transform2D())


func start_drag(event: InputEventMouseButton):
	drag_start = {
		'size': shape.size,
		'transform': shape.get_global_transform_with_canvas(),
		'position': shape.position,
		'mouse_position': get_local_mouse_position()
	 }


func drag(event: InputEvent) -> void:
	var event_position = drag_start_get_local_mouse_position()
	var drag_delta: Vector2 = event_position - drag_start['mouse_position']
	
	var new_size = drag_start['size'] + drag_delta * size_transform
	if keep_aspect_ratio:
		var fit_x := Vector2(new_size.x, new_size.x / drag_start['size'].aspect())
		var fit_y := Vector2(new_size.y * drag_start['size'].aspect(), new_size.y)
		new_size = fit_x if size_transform.x else fit_y
	# Reset the size first to avoid glitching
	shape.size = drag_start['size']
	shape.size = new_size

	var delta_size = shape.size - drag_start['size']
	# Transform proportionally to size change
	var position_transform = position_offsets[_index]
	shape.position = drag_start['position'] + shape.transform.basis_xform(position_transform * delta_size)
	shape.queue_redraw()


func drag_start_get_local_mouse_position():
	var event_position = shape.get_viewport().get_mouse_position()
	var global_transform = drag_start['transform']
	return global_transform.affine_inverse() * transform.affine_inverse() * event_position


func end_drag(undo_redo: EditorUndoRedoManager):
	undo_redo.create_action("Resize shape to %s" % shape.size)
	undo_redo.add_do_property(shape, "size", shape.size)
	undo_redo.add_do_property(shape, "position", shape.position)
	undo_redo.add_do_method(shape, "generate_geometry")
	undo_redo.add_undo_property(shape, "size", drag_start['size'])
	undo_redo.add_undo_property(shape, "position", drag_start['position'])
	undo_redo.add_undo_method(shape, "generate_geometry")

	undo_redo.commit_action()


func on_shift_pressed(is_pressed: bool):
	keep_aspect_ratio = is_pressed

