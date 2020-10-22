extends TextureButton


var _dragging: bool = false
var _drag_position: Vector2


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && (event.button_index & button_mask):
		_dragging = event.is_pressed()
		_drag_position = get_global_mouse_position()

	elif _dragging && event is InputEventMouseMotion:
		OS.window_position = OS.window_position + get_global_mouse_position() - _drag_position

