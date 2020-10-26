extends Control


export(NodePath) var output_dir_check_box: NodePath
export(NodePath) var output_dir_line_edit: NodePath
export(NodePath) var browse_output_dir_btn: NodePath
export(NodePath) var convert_btn: NodePath

onready var _output_dir_check_box: CheckBox = get_node(output_dir_check_box) as CheckBox
onready var _output_dir_line_edit: LineEdit = get_node(output_dir_line_edit) as LineEdit
onready var _browse_output_dir_btn: Button = get_node(browse_output_dir_btn) as Button
onready var _convert_btn: Button = get_node(convert_btn) as Button

var _use_custom_output_dir: bool
var _custom_output_dir: String


func _ready() -> void:
	_sync_with_ui()


func get_output_path(for_file: String) -> String:
	if !_use_custom_output_dir || _custom_output_dir.empty():
		return "%s.svg" % [for_file.get_basename()]

	return "%s.svg" % [_custom_output_dir.plus_file(for_file.get_file())]


func _sync_with_ui() -> void:
	_use_custom_output_dir = !_output_dir_check_box.pressed
	_custom_output_dir = _output_dir_line_edit.text

	_browse_output_dir_btn.disabled = !_use_custom_output_dir
	_convert_btn.disabled = _use_custom_output_dir && _custom_output_dir.empty()

	if _convert_btn.disabled:
		_convert_btn.hint_tooltip = "Need valid output location to convert files."
	else:
		_convert_btn.hint_tooltip = "Convert files into SVG."


func _on_OutputDirCheckButton_toggled(_button_pressed: bool) -> void:
	_sync_with_ui()

