extends TextureButton


const NO_BUTTONS: int = 0
const DEADZONE_SIZE: int = 25		# Number of pixels (squared) user must "drag", before dragging actually starts.

var _mouse_button_down: bool = false
var _button_used_at_position: Vector2
var _initiated_drag: bool = false
var _stored_button_mask: int = NO_BUTTONS


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && (event.button_index & button_mask || event.button_index & _stored_button_mask):
		_mouse_button_down = event.is_pressed()
		_button_used_at_position = get_global_mouse_position()

		if _initiated_drag:
			# This allows us to wait a single frame before we change back our button mask. This prevents the button
			# from registering a button release and sending its "pressed" signal.
			yield(get_tree(), "idle_frame")

			button_mask = _stored_button_mask
			_initiated_drag = false

	elif event is InputEventMouseMotion && _mouse_button_down:
		var delta_drag_distance: float = (get_global_mouse_position() - _button_used_at_position).length_squared()

		if delta_drag_distance > DEADZONE_SIZE && !_initiated_drag:
			_initiated_drag = true
			_stored_button_mask = button_mask
			button_mask = NO_BUTTONS

		if _initiated_drag:
			OS.window_position += get_global_mouse_position() - _button_used_at_position

