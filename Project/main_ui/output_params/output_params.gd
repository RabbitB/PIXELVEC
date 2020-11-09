extends PanelContainer


export(NodePath) var scan_mode_option_btn: NodePath
export(NodePath) var unit_option_btn: NodePath
export(NodePath) var scale_spin_box: NodePath
export(NodePath) var overdraw_spin_box: NodePath

onready var _scan_mode_option_btn: OptionButton = get_node(scan_mode_option_btn) as OptionButton
onready var _unit_option_btn: OptionButton = get_node(unit_option_btn) as OptionButton
onready var _scale_spin_box: SpinBox = get_node(scale_spin_box) as SpinBox
onready var _overdraw_spin_box: SpinBox = get_node(overdraw_spin_box) as SpinBox


func get_scan_mode() -> int:
	return _scan_mode_option_btn.selected


func get_unit() -> int:
	return _unit_option_btn.selected


func get_svg_scale() -> float:
	return _scale_spin_box.value


func get_overdraw_amount() -> float:
	return _overdraw_spin_box.value

