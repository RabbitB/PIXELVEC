extends MarginContainer


const RasterToSVG: Script = preload("res://raster_to_svg/raster_to_svg.gd")
const SourceImages: Script = preload("res://main_ui/source_images/source_images.gd")
const OutputControls: Script = preload("res://main_ui/output_controls/output_controls.gd")

export(NodePath) var source_images_ui: NodePath
export(NodePath) var output_ui: NodePath

onready var _source_images_ui: SourceImages = get_node(source_images_ui) as SourceImages
onready var _output_ui: OutputControls = get_node(output_ui) as OutputControls


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

