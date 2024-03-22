extends Handle

const Handle = preload("Handle.gd")
const Arrow = preload("../shapes/Arrow.gd")

const triangle_height_proportion = sqrt(3.0) / 2.0

var drag_start : Dictionary = {
	'target': Vector2(),
	'mouse_position': Vector2()
}
var snap_angle := false


func _init(selected_shape: Arrow):
	var transform_viewport := selected_shape.get_viewport_transform()
	var transform_global := selected_shape.get_global_transform_with_canvas()
	var target = selected_shape.target
	var arrow_rotation := target.angle() + PI / 2
	var arrow_transform := Transform2D(arrow_rotation, target)
	var handle_position = transform_viewport * transform_global * arrow_transform * Vector2()
	transform = Transform2D(0.0, handle_position)
	shape = selected_shape


func draw(overlay: Control):
	var transform_global := shape.get_global_transform_with_canvas()
	var transformed_target := transform_global.basis_xform(shape.target)
	var arrow_rotation := transformed_target.angle() + PI / 2
	overlay.draw_set_transform_matrix(transform.rotated_local(arrow_rotation))
	overlay.draw_colored_polygon(triangle(14.0), Color.BLACK)
	overlay.draw_colored_polygon(triangle(11.0), Color.WHITE)
	overlay.draw_colored_polygon(triangle(8.0), Color.ORANGE_RED)
	overlay.draw_set_transform_matrix(Transform2D())


func triangle(height: float) -> PackedVector2Array:
	var side = height / triangle_height_proportion
	return [
		Vector2(-side / 2, height / 2),
		Vector2(0, -height / 2),
		Vector2(side / 2, height / 2),
	]


func start_drag(event: InputEventMouseButton):
	drag_start = {
		'target': shape.target,
		'mouse_position': get_local_mouse_position()
	 }


func drag(event: InputEvent) -> void:
	var event_position = get_local_mouse_position()
	var drag_delta: Vector2 = event_position - drag_start['mouse_position']

	var new_target: Vector2 = drag_start['target'] + drag_delta
	if snap_angle:
		var modulo := fmod(new_target.angle() + shape.global_rotation + TAU - PI / 24, PI / 12)
		var angle := new_target.angle() - modulo + PI / 24
		shape.target = new_target.length() * Vector2(cos(angle), sin(angle))
	else:
		shape.target = new_target
	
	shape.queue_redraw()


func end_drag(undo_redo: EditorUndoRedoManager):
	undo_redo.create_action("Set target to %s" % shape.target)
	undo_redo.add_do_property(shape, "target", shape.target)
	undo_redo.add_do_method(shape, "generate_geometry")
	undo_redo.add_undo_property(shape, "target", drag_start['target'])
	undo_redo.add_undo_method(shape, "generate_geometry")

	undo_redo.commit_action()

func on_shift_pressed(is_pressed: bool) -> void:
	snap_angle = is_pressed
