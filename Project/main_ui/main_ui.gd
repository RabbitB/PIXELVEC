extends MarginContainer


const RasterToSVG: Script = preload("res://raster_to_svg/raster_to_svg.gd")
const SourceImages: Script = preload("res://main_ui/source_images/source_images.gd")
const OutputControls: Script = preload("res://main_ui/output_controls/output_controls.gd")
const LogViewer: Script = preload("res://main_ui/log_viewer/log_viewer.gd")

export(NodePath) var source_images_ui: NodePath
export(NodePath) var output_ui: NodePath
export(NodePath) var log_viewer: NodePath

onready var _source_images_ui: SourceImages = get_node(source_images_ui) as SourceImages
onready var _output_ui: OutputControls = get_node(output_ui) as OutputControls
onready var _log_viewer: LogViewer = get_node(log_viewer) as LogViewer


func view_log(show: bool) -> void:
	if show:
		_log_viewer.show_log()
		_source_images_ui.visible = false
	else:
		_log_viewer.close_log()
		_source_images_ui.visible = true


func _on_OutputControls_convert_files() -> void:
	var files_to_convert: Array = _source_images_ui.get_files()

	for file in files_to_convert:
		var output_path: String = _output_ui.get_output_path(file)
		var source_image: Image = Image.new()

		var err: int = source_image.load(file)
		if err:
			print(err)

		var raster_to_svg: RasterToSVG = RasterToSVG.new()
		var svg_output: String = raster_to_svg.convert_image(source_image, raster_to_svg.ScanMode.NAIVE)

		var output_file: File = File.new()
		output_file.open(output_path, File.WRITE)
		output_file.store_string(svg_output)
		output_file.close()
		
		view_log(true)


func _on_OutputControls_view_log() -> void:
	view_log(true)


func _on_Log_log_will_close() -> void:
	view_log(false)

