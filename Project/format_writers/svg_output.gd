extends Node


func _ready() -> void:
	output_svg()


func output_svg() -> String:
	var xml_writer: XMLWriter = XMLWriter.new()

	xml_writer.add_declaration("xml_doc")
	xml_writer.set_declaration_attribute("xml_doc", "version", "1.0")
	xml_writer.set_declaration_attribute("xml_doc", "encoding", "UTF-8")
	xml_writer.set_declaration_attribute("xml_doc", "standalone", "no")

	var svg: Dictionary = xml_writer.add_element("svg")
	xml_writer.set_attribute("width", "5cm", svg)
	xml_writer.set_attribute("height", "4cm", svg)
	xml_writer.set_attribute("version", "1.1", svg)
	xml_writer.set_attribute("xmlns", "http://www.w3.org/2000/svg", svg)

	var description: Dictionary = xml_writer.add_element("desc", svg)
	xml_writer.set_content("Four separate rectangles", description)

	var rect1: Dictionary = xml_writer.add_element("rect", svg)
	xml_writer.set_attribute("x", "0.5cm", rect1)
	xml_writer.set_attribute("y", "0.5cm", rect1)
	xml_writer.set_attribute("width", "2cm", rect1)
	xml_writer.set_attribute("height", "1cm", rect1)

	var rect2: Dictionary = xml_writer.add_element("rect", svg)
	xml_writer.set_attribute("x", "0.5cm", rect2)
	xml_writer.set_attribute("y", "2cm", rect2)
	xml_writer.set_attribute("width", "1cm", rect2)
	xml_writer.set_attribute("height", "1.5cm", rect2)

	var rect3: Dictionary = xml_writer.add_element("rect", svg)
	xml_writer.set_attribute("x", "3cm", rect3)
	xml_writer.set_attribute("y", "0.5cm", rect3)
	xml_writer.set_attribute("width", "1.5cm", rect3)
	xml_writer.set_attribute("height", "2cm", rect3)

	var rect4: Dictionary = xml_writer.add_element("rect", svg)
	xml_writer.set_attribute("x", "3.5cm", rect4)
	xml_writer.set_attribute("y", "3cm", rect4)
	xml_writer.set_attribute("width", "1cm", rect4)
	xml_writer.set_attribute("height", "0.5cm", rect4)

	var outline: Dictionary = xml_writer.add_element("rect", svg)
	xml_writer.set_attribute("x", ".01cm", outline)
	xml_writer.set_attribute("y", ".01cm", outline)
	xml_writer.set_attribute("width", "4.98cm", outline)
	xml_writer.set_attribute("height", "3.98cm", outline)
	xml_writer.set_attribute("fill", "none", outline)
	xml_writer.set_attribute("stroke", "blue", outline)
	xml_writer.set_attribute("stroke-width", ".02cm", outline)


	print(xml_writer.output_xml())
	return xml_writer.output_xml()

