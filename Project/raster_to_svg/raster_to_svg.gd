extends Resource


enum ScanMode {
	NAIVE,
	HORIZONTAL,
	VERTICAL,
	HORIZONTAL_WAVEFORM,
	VERTICAL_WAVEFORM
}

const NaiveScanner: Script = preload("res://raster_to_svg/scanners/naive.gd")

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


func convert_image(raster_image: Image, scan_mode: int) -> String:
	_xml_writer.set_attribute("width", str(raster_image.get_width()), _svg)
	_xml_writer.set_attribute("height", str(raster_image.get_height()), _svg)

	var palette: Dictionary = palettize(raster_image)

	match scan_mode:
		ScanMode.NAIVE:
			var naive_scanner: NaiveScanner = NaiveScanner.new()

			for pixel_color in palette:
				var rects: Array = naive_scanner.get_vector_shapes(palette[pixel_color])
				for rect in rects:
					add_rect2(rect, pixel_color)
		_:
			pass

	return _xml_writer.output_xml()


func convert_image_threaded(args: Array) -> String:
	assert(args.size() == 4)

	var output: String = convert_image(args[0], args[1])
	args[2].call_deferred(args[3])

	return output


func palettize(raster_image: Image) -> Dictionary:
	var image_size: Vector2 = raster_image.get_size()
	var palette: Dictionary = {}

	raster_image.lock()

	for x in image_size.x:
		for y in image_size.y:
			var pixel_color: Color = raster_image.get_pixel(x, y)
			if pixel_color.a == 0:
				continue

			if !palette.has(pixel_color):
				palette[pixel_color] = []

			palette[pixel_color].append(Vector2(x, y))

	raster_image.unlock()
	return palette


func add_rect2(rect: Rect2, color: Color) -> void:
	var svg_rect: Dictionary = _xml_writer.add_element("rect", _svg)
	_xml_writer.set_attribute("x", str(rect.position.x), svg_rect)
	_xml_writer.set_attribute("y", str(rect.position.y), svg_rect)
	_xml_writer.set_attribute("width", "1", svg_rect)
	_xml_writer.set_attribute("height", "1", svg_rect)
	_xml_writer.set_attribute("fill", "#%s" % color.to_html(false), svg_rect)
	_xml_writer.set_attribute("fill-opacity", str(color.a), svg_rect)

