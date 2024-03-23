extends Handle

const Handle = preload("Handle.gd")


const triangle_height_proportion = sqrt(3.0) / 2.0

var scalar: String
var axis: Vector2
var drag_start : Dictionary = {
	'mouse_position': Vector2()
}


func _init(selected_shape: GeometricShape, position: Vector2, scalar_: String, axis_: Vector2 = Vector2.DOWN):
	var transform_viewport := selected_shape.get_viewport_transform()
	var transform_global := selected_shape.get_global_transform_with_canvas()
	var pos = transform_viewport * transform_global * position
	shape = selected_shape
	scalar = scalar_
	axis = axis_
	transform = Transform2D(0.0, pos)


func draw(overlay: Control):
	overlay.draw_set_transform_matrix(transform)
	overlay.draw_circle(Vector2.ZERO, 6, Color.BLACK)
	overlay.draw_circle(Vector2.ZERO, 5, Color.WHITE)
	overlay.draw_circle(Vector2.ZERO, 4, Color.ROYAL_BLUE)
	overlay.draw_set_transform_matrix(Transform2D())


func start_drag(event: InputEventMouseButton):
	drag_start = {
		scalar: shape[scalar],
		'mouse_position': get_local_mouse_position()
	 }


func drag(event: InputEvent) -> void:
	var event_position = get_local_mouse_position()
	
	var drag_delta: Vector2 = event_position - drag_start['mouse_position']
	shape[scalar] = drag_start[scalar] + drag_delta.dot(axis)
	
	shape.queue_redraw()


func end_drag(undo_redo: EditorUndoRedoManager):
	undo_redo.create_action("Set %s to %s" % [scalar, shape[scalar]])
	undo_redo.add_do_property(shape, scalar, shape[scalar])
	undo_redo.add_do_method(shape, "generate_geometry")
	undo_redo.add_undo_property(shape, scalar, drag_start[scalar])
	undo_redo.add_undo_method(shape, "generate_geometry")
	
	undo_redo.commit_action()

