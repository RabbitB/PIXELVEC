extends Resource


enum ScanMode {
	NAIVE,
	HORIZONTAL,
	VERTICAL,
	HORIZONTAL_WAVEFORM,
	VERTICAL_WAVEFORM
}

enum Unit {
	PX,
	PT,
	PC,
	MM,
	CM,
	IN,
	EM,
	EX
}

const NaiveScanner: Script = preload("res://raster_to_svg/scanners/naive.gd")
const HorizontalScanner: Script = preload("res://raster_to_svg/scanners/horizontal.gd")
const VerticalScanner: Script = preload("res://raster_to_svg/scanners/vertical.gd")
const HorizontalWaveformScanner: Script = preload("res://raster_to_svg/scanners/horizontal_waveform.gd")

var _xml_writer: XMLWriter
var _svg: Dictionary


func _init() -> void:
	_xml_writer = XMLWriter.new()

	_xml_writer.add_declaration("xml_doc")
	_xml_writer.set_declaration_attribute("xml_doc", "version", "1.0")
	_xml_writer.set_declaration_attribute("xml_doc", "encoding", "UTF-8")
	_xml_writer.set_declaration_attribute("xml_doc", "standalone", "no")

	_svg = _xml_writer.add_element("svg")
	_xml_writer.set_attribute("version", "1.1", _svg)
	_xml_writer.set_attribute("xmlns", "http://www.w3.org/2000/svg", _svg)


func convert_image(raster_image: Image, scan_mode: int, unit: int, scale: float, overdraw: float) -> String:
	var unit_str: String = unit_to_str(unit)

	_xml_writer.set_attribute("width", "%f%s" % [(raster_image.get_width() * scale), unit_str], _svg)
	_xml_writer.set_attribute("height", "%f%s" % [(raster_image.get_height() * scale), unit_str], _svg)

	var palette: Dictionary = palettize(raster_image)

	match scan_mode:
		ScanMode.NAIVE:
			var naive_scanner: NaiveScanner = NaiveScanner.new()

			for pixel_color in palette:
				var rects: Array = naive_scanner.get_vector_shapes(palette[pixel_color])
				for rect in rects:
					add_rect2(rect, pixel_color, unit_str, scale, overdraw)

		ScanMode.HORIZONTAL:
			var horizontal_scanner: HorizontalScanner = HorizontalScanner.new()

			for pixel_color in palette:
				var rects: Array = horizontal_scanner.get_vector_shapes(palette[pixel_color])
				for rect in rects:
					add_rect2(rect, pixel_color, unit_str, scale, overdraw)

		ScanMode.VERTICAL:
			var vertical_scanner: VerticalScanner = VerticalScanner.new()

			for pixel_color in palette:
				var rects: Array = vertical_scanner.get_vector_shapes(palette[pixel_color])
				for rect in rects:
					add_rect2(rect, pixel_color, unit_str, scale, overdraw)

		ScanMode.HORIZONTAL_WAVEFORM:
			var horizontal_waveform_scanner: HorizontalWaveformScanner = HorizontalWaveformScanner.new()
			var horizontal_scanner: HorizontalScanner = HorizontalScanner.new()

			for pixel_color in palette:
				var rects: Array = horizontal_scanner.get_vector_shapes(palette[pixel_color])
				var paths: Array = horizontal_waveform_scanner.get_vector_shapes(rects, scale, overdraw)

				for path in paths:
					add_path(path, pixel_color, unit_str)

		_:
			pass

	return _xml_writer.output_xml()


func convert_image_threaded(args: Array) -> String:
	assert(args.size() == 7)

	var output: String = convert_image(args[0], args[1], args[2], args[3], args[4])
	args[5].call_deferred(args[6])

	return output


func palettize(raster_image: Image) -> Dictionary:
	var image_size: Vector2 = raster_image.get_size()
	var palette: Dictionary = {}

	raster_image.lock()

	for y in image_size.y:
		for x in image_size.x:
			var pixel_color: Color = raster_image.get_pixel(x, y)
			if pixel_color.a == 0:
				continue

			if !palette.has(pixel_color):
				palette[pixel_color] = []

			palette[pixel_color].append(Vector2(x, y))

	raster_image.unlock()
	return palette


func add_rect2(rect: Rect2, color: Color, unit_str: String, scale: float, overdraw: float) -> void:
	rect.position *= scale
	rect.size *= scale
	rect.position -= Vector2(overdraw, overdraw)
	rect.size += Vector2(overdraw, overdraw)

	var svg_rect: Dictionary = _xml_writer.add_element("rect", _svg)
	_xml_writer.set_attribute("x", "%f%s" % [rect.position.x, unit_str], svg_rect)
	_xml_writer.set_attribute("y", "%f%s" % [rect.position.y, unit_str], svg_rect)
	_xml_writer.set_attribute("width", "%f%s" % [rect.size.x, unit_str], svg_rect)
	_xml_writer.set_attribute("height", "%f%s" % [rect.size.y, unit_str], svg_rect)
	_xml_writer.set_attribute("fill", "#%s" % color.to_html(false), svg_rect)
	_xml_writer.set_attribute("fill-opacity", str(color.a), svg_rect)


# warning-ignore:unused_argument
func add_path(path: Array, color: Color, unit_str: String) -> void:
	var path_format: String = "M %f %f %s z"
	var point_format: String = "L %f %f".repeat(path.size() - 1)
	var point_components: Array = []

	# The first point in the path is used in the move-to command, so we don't include it here.
	for idx in range(1, path.size()):
		point_components.append(path[idx].x)
		point_components.append(path[idx].y)

	var all_points: String = point_format % point_components

	var svg_path: Dictionary = _xml_writer.add_element("path", _svg)
	_xml_writer.set_attribute("d", path_format % [path[0].x, path[0].y, all_points], svg_path)
	_xml_writer.set_attribute("fill", "#%s" % color.to_html(false), svg_path)
	_xml_writer.set_attribute("fill-opacity", str(color.a), svg_path)


func unit_to_str(unit: int) -> String:
	match (unit):
		Unit.PX:
			return "px"
		Unit.PT:
			return "pt"
		Unit.PC:
			return "pc"
		Unit.MM:
			return "mm"
		Unit.CM:
			return "cm"
		Unit.IN:
			return "in"
		Unit.EM:
			return "em"
		Unit.EX:
			return "ex"
		_:
			return ""

