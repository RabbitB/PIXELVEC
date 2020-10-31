extends Control


signal convert_files()

export(NodePath) var output_dir_dialog: NodePath
export(NodePath) var output_dir_check_box: NodePath
export(NodePath) var output_dir_line_edit: NodePath
export(NodePath) var browse_output_dir_btn: NodePath
export(NodePath) var convert_btn: NodePath

var _use_custom_output_dir: bool
var _custom_output_dir: String

onready var _output_dir_dialog: FileDialog = get_node(output_dir_dialog) as FileDialog
onready var _output_dir_check_box: CheckBox = get_node(output_dir_check_box) as CheckBox
onready var _output_dir_line_edit: LineEdit = get_node(output_dir_line_edit) as LineEdit
onready var _browse_output_dir_btn: Button = get_node(browse_output_dir_btn) as Button
onready var _convert_btn: Button = get_node(convert_btn) as Button


func _ready() -> void:
	_sync_with_ui()


func get_output_path(for_file: String) -> String:
	if !_use_custom_output_dir || _custom_output_dir.empty():
		return "%s.svg" % [for_file.get_basename()]

	var base_file_name: String = for_file.get_file().rstrip(".%s" % for_file.get_extension())
	return "%s.svg" % [_custom_output_dir.plus_file(base_file_name)]


func _sync_with_ui() -> void:
	_use_custom_output_dir = !_output_dir_check_box.pressed
	_custom_output_dir = _output_dir_line_edit.text

	_output_dir_line_edit.visible = _use_custom_output_dir
	_browse_output_dir_btn.visible = _use_custom_output_dir

	_browse_output_dir_btn.disabled = !_use_custom_output_dir
	_convert_btn.disabled = _use_custom_output_dir && _custom_output_dir.empty()

	if _convert_btn.disabled:
		_convert_btn.hint_tooltip = "Need valid output location to convert files."
	else:
		_convert_btn.hint_tooltip = "Convert files into SVG."


func _on_OutputDirCheckButton_toggled(_button_pressed: bool) -> void:
	_sync_with_ui()


func _on_BrowseButton_pressed() -> void:
	_output_dir_dialog.popup()


func _on_OutputDirDialog_dir_selected(dir: String) -> void:
	_output_dir_line_edit.text = dir
	_sync_with_ui()


func _on_ConvertButton_pressed() -> void:
	emit_signal("convert_files")

