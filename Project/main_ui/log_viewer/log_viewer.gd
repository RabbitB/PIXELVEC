extends PanelContainer


signal log_will_close()

const ALERT_ICON: Texture = preload("res://main_ui/log_viewer/alert_icon_modulate.png")

export(NodePath) var log_list: NodePath
export(Color) var error_color: Color = Color("D32734")
export(Color) var warning_color: Color = Color("DA7d22")

onready var _log_list: ItemList = get_node("HBoxContainer/ItemList") as ItemList


func log_error(error_msg: String) -> void:
	_log_list.add_item(error_msg)
	var msg_idx: int = _log_list.get_item_count() - 1

	_log_list.set_item_icon(msg_idx, ALERT_ICON)
	_log_list.set_item_icon_modulate(msg_idx, error_color)


func log_warning(warning_msg: String) -> void:
	_log_list.add_item(warning_msg)
	var msg_idx: int = _log_list.get_item_count() - 1

	_log_list.set_item_icon(msg_idx, ALERT_ICON)
	_log_list.set_item_icon_modulate(msg_idx, warning_color)


func log_msg(msg: String) -> void:
	_log_list.add_item(msg)


func show_log() -> void:
	visible = true


func close_log() -> void:
	visible = false
	emit_signal("log_will_close")


func _on_Clear_pressed() -> void:
	_log_list.clear()
	close_log()


func _on_Close_pressed() -> void:
	close_log()

