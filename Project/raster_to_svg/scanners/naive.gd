extends Resource


func get_vector_shapes(pixel_positions: Array) -> Array:
	var vector_shapes: Array = []

	for pixel in pixel_positions:
		vector_shapes.append(Rect2(pixel, Vector2(1, 1)))

	return vector_shapes

