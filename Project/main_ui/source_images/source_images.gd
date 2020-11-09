extends Control


const OutputParams: Script = preload("res://main_ui/output_params/output_params.gd")

export(NodePath) var choose_files_dialog: NodePath
export(NodePath) var item_list: NodePath
export(NodePath) var remove_file_btn: NodePath
export(NodePath) var busy_indicator: NodePath
export(NodePath) var output_params_ui: NodePath

onready var _choose_files_dialog: FileDialog = get_node(choose_files_dialog) as FileDialog
onready var _item_list: ItemList = get_node(item_list) as ItemList
onready var _remove_file_btn: Button = get_node(remove_file_btn) as Button
onready var _busy_indicator: AnimatedSprite = get_node(busy_indicator) as AnimatedSprite
onready var _output_params_ui: OutputParams = get_node(output_params_ui) as OutputParams


func _input(event: InputEvent) -> void:
	if event.is_action_pressed("select_all"):
		get_tree().set_input_as_handled()

		for i in _item_list.get_item_count():
			_item_list.select(i, false)
			_item_list_selection_changed()

	elif event.is_action_pressed("deselect_all"):
		get_tree().set_input_as_handled()

		_item_list.unselect_all()
		_item_list_selection_changed()

	elif event.is_action_pressed("delete_selected"):
		get_tree().set_input_as_handled()
		_on_RemoveFile_pressed()


func get_files() -> Array:
	var file_list: Array = []
	for i in _item_list.get_item_count():
		file_list.append(_item_list.get_item_text(i))

	return file_list


func is_in_list(path: String) -> bool:
	for i in _item_list.get_item_count():
		if _item_list.get_item_text(i) == path:
			return true

	return false


func busy(is_busy: bool) -> void:
	if is_busy:
		_busy_indicator.play("spinning")
	else:
		_busy_indicator.play("idle")


func scan_mode() -> int:
	return _output_params_ui.get_scan_mode()


func unit_of_measurement() -> int:
	return _output_params_ui.get_unit()


func output_scale() -> float:
	return _output_params_ui.get_svg_scale()


func overdraw_amount() -> float:
	return _output_params_ui.get_overdraw_amount()


func _item_list_selection_changed() -> void:
	_remove_file_btn.disabled = !_item_list.is_anything_selected()


func _on_AddFiles_pressed() -> void:
	_choose_files_dialog.popup()


func _on_RemoveFile_pressed() -> void:
	var selected_items: PoolIntArray = _item_list.get_selected_items()
	selected_items.invert()

	for i in selected_items:
		_item_list.remove_item(i)

	_item_list_selection_changed()


func _on_ChooseFilesDialog_file_selected(path: String) -> void:
	if !is_in_list(path):
		_item_list.add_item(path)


func _on_ChooseFilesDialog_files_selected(paths: PoolStringArray) -> void:
	for path in paths:
		if !is_in_list(path):
			_item_list.add_item(path)


func _on_ItemList_item_selected(_index: int) -> void:
	_item_list_selection_changed()


func _on_ItemList_multi_selected(_index: int, _selected: bool) -> void:
	_item_list_selection_changed()


func _on_ItemList_nothing_selected() -> void:
	_item_list.unselect_all()
	_item_list_selection_changed()

