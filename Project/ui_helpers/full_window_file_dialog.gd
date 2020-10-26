extends FileDialog


var _title_margin: int = get_stylebox("panel").expand_margin_top


func _ready() -> void:
# warning-ignore:return_value_discarded
	self.connect("about_to_show", self, "_on_about_to_show")
# warning-ignore:return_value_discarded
	get_viewport().connect("size_changed", self, "_on_viewport_resized")


func resize_to_viewport() -> void:
	rect_size = get_viewport_rect().size - Vector2(0, _title_margin)
	rect_global_position = Vector2(0, _title_margin)


func _on_about_to_show() -> void:
	resize_to_viewport()


func _on_viewport_resized() -> void:
	resize_to_viewport()

