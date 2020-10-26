extends FileDialog


const EDGE_MARGIN: int = 4		# How much margin to have between the dialog and the window border. A margin makes
								# it easier to grab the edge of the dialog and resize it.

export(NodePath) var node_to_hide_when_open: NodePath	# This node will be hidden when the dialog is open.

var _title_margin: int
var _default_window_size: Vector2 = Vector2.ZERO
var _intended_window_size: Vector2 = Vector2.ZERO
var _ignore_rect_change: bool = false

var _dragging: bool = false
var _drag_position: Vector2


func _ready() -> void:
# warning-ignore:return_value_discarded
	self.connect("about_to_show", self, "_on_about_to_show")
# warning-ignore:return_value_discarded
	self.connect("popup_hide", self, "_on_popup_hide")
# warning-ignore:return_value_discarded
	self.connect("item_rect_changed", self, "_on_item_rect_changed")


func _gui_input(event: InputEvent) -> void:
	if event is InputEventMouseButton && event.button_index == BUTTON_LEFT:
		var title_rect: Rect2 = get_global_rect()
		title_rect.position.y -= _title_margin
		title_rect.size.y = _title_margin

		if event.is_pressed() && title_rect.has_point(get_global_mouse_position()):
			_dragging = true
			_drag_position = get_global_mouse_position()
		else:
			_dragging = false

	elif _dragging && event is InputEventMouseMotion:
		OS.window_position = OS.window_position + get_global_mouse_position() - _drag_position


func _on_about_to_show() -> void:
	_show_node_to_hide(false)
	_title_margin = get_stylebox("panel").expand_margin_top

	if _default_window_size == Vector2.ZERO:
		_default_window_size = OS.window_size
		_intended_window_size = _default_window_size

	rect_size = _intended_window_size - Vector2(EDGE_MARGIN * 2, _title_margin + (EDGE_MARGIN * 2))
	rect_global_position = Vector2(0, _title_margin)

	OS.window_position -= (_intended_window_size - _default_window_size) / 2
	OS.window_size = _intended_window_size

	_ignore_rect_change = true


func _on_popup_hide() -> void:
	_show_node_to_hide(true)

	_intended_window_size = OS.window_size
	OS.window_position += (_intended_window_size - _default_window_size) / 2
	OS.window_size = _default_window_size

	_ignore_rect_change = true


func _on_item_rect_changed() -> void:
	if _ignore_rect_change:
		_ignore_rect_change = false

		rect_size = _intended_window_size - Vector2(EDGE_MARGIN * 2, _title_margin + (EDGE_MARGIN * 2))
		rect_global_position = Vector2(0, _title_margin)

		OS.window_size = _intended_window_size

		return

	rect_global_position = Vector2(0, _title_margin)
	
	var new_window_size: Vector2 = rect_size + Vector2(EDGE_MARGIN * 2, _title_margin + (EDGE_MARGIN * 2))
	var delta_size_change: Vector2 = new_window_size - OS.window_size
	OS.window_size = new_window_size
	OS.window_position -= delta_size_change / 2


func _show_node_to_hide(show_node: bool):
	var node_to_hide: Node = get_node(node_to_hide_when_open)
	if node_to_hide && node_to_hide is CanvasItem:
		node_to_hide.visible = show_node

