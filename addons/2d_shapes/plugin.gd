@tool
extends EditorPlugin

const GeometricShape = preload("./shapes/GeometricShape.gd")
const Handle = preload("./handles/Handle.gd")


var selected_shape: GeometricShape
var dragged_handle: Handle = null
var handles : Array
var is_holding_shift := false


#== node ==
func _enter_tree() -> void:
	add_custom_type("Rectangle", "Node2D", preload("./shapes/Rectangle.gd"), preload("Rectangle.svg"))
	add_custom_type("Ellipse", "Node2D", preload("./shapes/Ellipse.gd"), preload("Ellipse.svg"))
	add_custom_type("Arrow", "Node2D", preload("./shapes/Arrow.gd"), preload("Arrow.svg"))
	add_custom_type("Triangle", "Node2D", preload("./shapes/Triangle.gd"), preload("Triangle.svg"))
	add_custom_type("Polygon", "Node2D", preload("./shapes/Polygon.gd"), preload("Polygon.svg"))
	add_custom_type("Star", "Node2D", preload("./shapes/Star.gd"), preload("Star.svg"))
	add_undo_redo_inspector_hook_callback(undo_redo_callback)


func _exit_tree() -> void:
	remove_custom_type("Rectangle")
	remove_custom_type("Ellipse")
	remove_custom_type("Arrow")
	remove_custom_type("Triangle")
	remove_custom_type("Polygon")
	remove_custom_type("Star")
	remove_undo_redo_inspector_hook_callback(undo_redo_callback)


#== plugin ==
var undo_redo_callback = func (undo_redo: Object, modified_object:Object, property: String, new_value: Variant):
	if modified_object is GeometricShape:
		update_overlays()


func _handles(object : Object) -> bool:
	return object is GeometricShape


func _edit(object: Object) -> void:
	if object is GeometricShape:
		selected_shape = object
		update_overlays()


func _make_visible(visible : bool) -> void:
	if not selected_shape:
		return
	if not visible:
		selected_shape = null
	update_overlays()


#== drawing handles ==
func _forward_canvas_draw_over_viewport(overlay: Control) -> void:
	if selected_shape and selected_shape.is_inside_tree():
		handles = selected_shape.draw_handles(overlay)


func _forward_canvas_gui_input(event: InputEvent) -> bool:
	if not selected_shape or not selected_shape.visible:
		return false
	
	# Clicking and releasing the click
	if event is InputEventMouseButton and event.button_index == MOUSE_BUTTON_LEFT:
		if event.is_pressed():
			for handle: Handle in handles:
				if not handle.transform.origin.distance_to(event.position) < 10:
					continue
				handle.start_drag(event)
				dragged_handle = handle
				dragged_handle.on_shift_pressed(is_holding_shift)
				return true
		elif dragged_handle:
			dragged_handle.drag(event)
			dragged_handle.end_drag(get_undo_redo())
			dragged_handle = null
			return true
	
	# Dragging
	if event is InputEventMouseMotion and dragged_handle:
		dragged_handle.drag(event)
		update_overlays()
		return true
	
	# Pressing Shift
	if event is InputEventKey and event.keycode == KEY_SHIFT:
		is_holding_shift = event.is_pressed()
		if dragged_handle:
			dragged_handle.on_shift_pressed(event.is_pressed())
		return true
	
	return false

