extends Resource


func get_vector_shapes(pixel_positions: Array) -> Array:
	var vector_shapes: Array = []
	var sorted_pixels = pixel_positions.duplicate()
	sorted_pixels.sort_custom(self, "sort_pixels")

	var start_pixel: Vector2 = Vector2.INF
	var end_pixel: Vector2 = Vector2.INF

	for pixel in sorted_pixels:
		if start_pixel == Vector2.INF:
			start_pixel = pixel
			end_pixel = pixel

		if pixel.y != end_pixel.y || pixel.x > end_pixel.x + 1:
			vector_shapes.append(generate_rect(start_pixel, end_pixel))

			start_pixel = pixel
			end_pixel = pixel
		else:
			end_pixel = pixel

	vector_shapes.append(generate_rect(start_pixel, end_pixel))

	return vector_shapes


func generate_rect(start: Vector2, end: Vector2) -> Rect2:
	return Rect2(start, Vector2(end.x - start.x + 1, 1))


static func sort_pixels(a, b):
	if a.y < b.y || (a.y == b.y && a.x < b.x):
		return true

	return false

