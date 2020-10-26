extends Control


export(NodePath) var output_dir_check_btn: NodePath
export(NodePath) var output_dir_line_edit: NodePath
export(NodePath) var browse_output_dir_btn: NodePath

onready var _output_dir_check_btn: CheckButton = get_node(output_dir_check_btn) as CheckButton
onready var _output_dir_line_edit: LineEdit = get_node(output_dir_line_edit) as LineEdit
onready var _browse_output_dir_btn: Button = get_node(browse_output_dir_btn) as Button


func _on_OutputDirCheckButton_toggled(button_pressed: bool) -> void:
	_browse_output_dir_btn.disabled = button_pressed

