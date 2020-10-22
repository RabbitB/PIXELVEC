extends CenterContainer


export(NodePath) var file_dialog: NodePath

onready var _file_dialog: FileDialog = get_node(file_dialog)


func _ready() -> void:
	get_tree().get_root().transparent_bg = true
	OS.window_per_pixel_transparency_enabled = true


func _on_Convert_pressed() -> void:
	_file_dialog.popup()
	#_file_dialog.popup(get_viewport_rect())

