class_name XMLWriter
extends Resource


export(Array) var elements: Array
export(Dictionary) var declarations: Dictionary


func _init() -> void:
	elements = []
	declarations = {}


func output_xml() -> String:
	return "%s%s" % [_declarations_to_string(), _elements_to_string()]


func add_element(element_name: String, to_element: Dictionary = {}) -> Dictionary:
	var new_element = _create_element(element_name)

	if to_element.empty():
		elements.push_back(new_element)
	else:
		to_element.children.push_back(new_element)

	return new_element


func set_attribute(attribute_name: String, content: String, to_element: Dictionary) -> void:
	to_element.attributes[attribute_name] = content


func set_content(content: String, to_element: Dictionary) -> void:
	var new_element = _create_element(content)
	new_element.is_content = true

	to_element.children.push_back(new_element)


func add_declaration(declaration_name: String) -> void:
	declarations[declaration_name] = {}
	declarations[declaration_name].attributes = {}


func set_declaration_attribute(declaration_name: String, attribute_name: String, content: String) -> void:
	declarations[declaration_name].attributes[attribute_name] = content


func _create_element(element_name: String) -> Dictionary:
	var new_element: Dictionary = {}
	new_element.name = element_name
	new_element.attributes = {}
	new_element.children = []
	new_element.is_content = false

	return new_element


func _declarations_to_string() -> String:
	var complete_format: String = '%s\n'.repeat(declarations.size())

	var format_args_array: Array = []
	for declaration_key in declarations:
		format_args_array.push_back(_declaration_to_string(declarations[declaration_key]))

	return complete_format % format_args_array


func _declaration_to_string(declaration: Dictionary) -> String:
	var attributes_format: String = '%s="%s" '.repeat(declaration.attributes.size()).strip_edges()
	var complete_format: String = '<?xml %s ?>' % attributes_format

	var format_args_array: Array = []
	for attribute_key in declaration.attributes:
		format_args_array.push_back(attribute_key)
		format_args_array.push_back(declaration.attributes[attribute_key])

	return complete_format % format_args_array


func _elements_to_string() -> String:
	var complete_format: String = '%s\n'.repeat(elements.size())

	var format_args_array: Array = []
	for element in elements:
		format_args_array.push_back(_element_to_string(element))

	return complete_format % format_args_array


func _element_to_string(element: Dictionary, nested: bool = false) -> String:
	var attributes_format: String = '%s="%s" '.repeat(element.attributes.size()).strip_edges()

	var attributes_format_args: Array = []
	for attribute_key in element.attributes:
		attributes_format_args.push_back(attribute_key)
		attributes_format_args.push_back(element.attributes[attribute_key])

	var attributes_output: String = attributes_format % attributes_format_args
	var spacing: String = " " if !attributes_format.empty() else ""

	var element_output: String

	if element.is_content:
		element_output = element.name
	elif element.children.empty():
		element_output = '<%s%s%s />' % [element.name, spacing, attributes_output]
	else:
		var children_format: String = '\t%s\n'.repeat(element.children.size())

		var children_format_args: Array = []
		for child in element.children:
			children_format_args.push_back(_element_to_string(child, true))

		var children_output: String = children_format % children_format_args

		if nested:
			element_output = '<%s%s%s>\n\t%s\t</%s>' \
					% [element.name, spacing, attributes_output, children_output, element.name]
		else:
			element_output = '<%s%s%s>\n%s</%s>' \
					% [element.name, spacing, attributes_output, children_output, element.name]

	return element_output

