extends Node


const GeometricShape = preload("../shapes/GeometricShape.gd")

var transform: Transform2D
var shape: GeometricShape


func get_local_mouse_position() -> Vector2:
	var event_position = shape.get_viewport().get_mouse_position()
	var global_transform = shape.get_global_transform_with_canvas()
	return global_transform.affine_inverse() * transform.affine_inverse() * event_position


func draw(overlay: Control) -> void:
	printerr('Function overlay was not implemented')
	pass


func start_drag(event: InputEventMouseButton) -> void:
	printerr('Function start_drag was not implemented')	
	pass


func drag(event: InputEventMouseMotion) -> void:
	printerr('Function drag was not implemented')
	pass


func end_drag(undo_redo: EditorUndoRedoManager) -> void:
	printerr('Function end_drag was not implemented')
	pass


func on_shift_pressed(is_pressed: bool) -> void:
	pass

