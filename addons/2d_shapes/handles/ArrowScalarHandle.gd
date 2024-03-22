extends "res://addons/2d_shapes/handles/ScalarHandle.gd"

const ScalarHandle = preload("ScalarHandle.gd")
const Arrow = preload("../shapes/Arrow.gd")

var square: bool


func _init(selected_shape: Arrow, position: Vector2, scalar_: String, axis_: Vector2 = Vector2.DOWN, square_: bool = false):
	super(selected_shape, position, scalar_, axis_)
	var transform_viewport := selected_shape.get_viewport_transform()
	var transform_global := selected_shape.get_global_transform_with_canvas()
	var target = selected_shape.target
	var arrow_rotation := target.angle() + PI / 2
	var arrow_transform := Transform2D(arrow_rotation, target)
	var handle_position := transform_viewport * transform_global * arrow_transform * position
	transform = Transform2D(arrow_rotation, handle_position)
	square = square_


func draw(overlay: Control):
	if square:
		var global_rotation := shape.global_rotation
		overlay.draw_set_transform_matrix(transform.rotated_local(global_rotation))
		var rect := Rect2(Vector2(2,2), Vector2(4,4))
		overlay.draw_rect(Rect2(Vector2(-5,-5), Vector2(10,10)), Color.BLACK)
		overlay.draw_rect(Rect2(Vector2(-4,-4), Vector2(8,8)), Color.WHITE)
		overlay.draw_rect(Rect2(Vector2(-3,-3), Vector2(6,6)), Color.ORANGE_RED)
		overlay.draw_set_transform_matrix(Transform2D())
	else:
		super.draw(overlay)

