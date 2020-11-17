extends Resource


# The horizontal waveform scanner attempts to simplify blocks of pixels into groupings that have no holes in them.
# The guaranteed lack of holes, greatly simplifies the path generation. SVG output without clipping also tends to be
# more performant. The scanner gets its name from its output tending to look like output from an audio visualizer.
# The algorithm works by taking pixels already grouped into horizontal rects, starting with the first one, and then
# finding all adjacent rects to it. All of these adjacent rects are converted into a path, and the process is repeated
# until no rects are left.
func get_vector_shapes(horizontal_rects: Array, scale: float, overdraw: float) -> Array:
	var paths: Array = []
	var sorted_rects: Array = horizontal_rects.duplicate()
	sorted_rects.sort_custom(self, "sort_rects")

	var idx: int = 0
	var rects_for_path: Array = []
	while !sorted_rects.empty():
		# If this array is empty, then we're starting a new path, and can safely add the first rect available,
		# and then work on finding all adjacent rects to it.
		if rects_for_path.empty():
			rects_for_path.append(sorted_rects.pop_front())
			idx = 0
			continue

		# If we've iterated through the entire list of all rects available, then there are no more adjacent rects
		# to be found for our current path. Go ahead and build the path, then reset and prepare to start a new path.
		if idx >= sorted_rects.size():
			paths.append(generate_path(rects_for_path, scale, overdraw))
			rects_for_path.clear()
			idx = 0
			continue

		var current_rect: Rect2 = sorted_rects[idx]
		var last_rect_in_path: Rect2 = rects_for_path[-1]

		# This algorithm prohibits holes, so we can only use one rect per row. Skip over any rects that are on the
		# same row as the last rect we've added to the path.
		if current_rect.position.y == last_rect_in_path.position.y:
			idx += 1
			continue

		# If we're more than one row down from the last rect added to the path, then there's no more adjacent rects
		# for this path. Go ahead and build the path, then reset and prepare to start a new path.
		if current_rect.position.y > last_rect_in_path.position.y + 1:
			paths.append(generate_path(rects_for_path, scale, overdraw))
			rects_for_path.clear()
			idx = 0
			continue

		# Check if this rect is adjacent to the last rect we added to the path, by seeing if they share any overlap.
		# If they don't overlap, skip it and move to the next rect.
		if (current_rect.end.x < last_rect_in_path.position.x) || (current_rect.position.x > last_rect_in_path.end.x):
			idx += 1
			continue

		# At this point, we've found an adjacent rect, so add it to the current path.
		rects_for_path.append(sorted_rects[idx])
		sorted_rects.remove(idx)

	# We're out of any additional rects to build into paths. Go ahead and build the last path we were working on,
	# if it contains any rects.
	if !rects_for_path.empty():
		paths.append(generate_path(rects_for_path, scale, overdraw))

	return paths


func generate_path(rects: Array, scale: float, overdraw: float) -> Array:
	var path: Array = []

#	var bounds: Rect2 = Rect2(0, 0, 0, 0)
#	for rect in rects:
#		bounds.position.x = min(bounds.position.x, rect.position.x)
#		bounds.position.y = min(bounds.position.y, rect.position.y)
#		bounds.end.x = max(bounds.end.x, rect.end.x)
#		bounds.end.y = max(bounds.end.y, rect.end.y)
#	scale += overdraw

	for rect in rects:
		var top_right: Vector2 = Vector2(rect.end.x, rect.position.y)
		var bottom_right: Vector2 = rect.end

		path.append(top_right * scale)
		path.append(bottom_right * scale)

	for idx in range(rects.size() - 1, -1, -1):
		var rect: Rect2 = rects[idx]
		var top_left: Vector2 = rect.position
		var bottom_left: Vector2 = Vector2(rect.position.x, rect.end.y)

		path.append(bottom_left * scale)
		path.append(top_left * scale)

	return simplify_path(path, scale, overdraw)


func simplify_path(path: Array, scale: float, overdraw: float) -> Array:
	var top_right_vec: Vector2 = Vector2(overdraw, -overdraw)
	var bottom_right_vec: Vector2 = Vector2(overdraw, overdraw)
	var top_left_vec: Vector2 = Vector2(-overdraw, -overdraw)
	var bottom_left_vec: Vector2 = Vector2(-overdraw, overdraw)

	var simplified_path: Array = []

	var start_point: Vector2 = path[0]
	var end_point: Vector2 = Vector2.INF
	var prev_end_point: Vector2 = Vector2.INF

	for idx in range(1, path.size()):
		var point: Vector2 = path[idx]

		if end_point == Vector2.INF || is_equal_approx(end_point.x, point.x):
			end_point = point
		else:
			# Right side of path.
			if idx < path.size() / 2:
				if prev_end_point == Vector2.INF || prev_end_point.x < start_point.x:
					start_point += top_right_vec
				else:
					start_point += bottom_right_vec

				if point.x < end_point.x:
					end_point += bottom_right_vec
				else:
					end_point += top_right_vec

			# Left side of path.
			else:
				if prev_end_point == Vector2.INF || prev_end_point.x < start_point.x:
					start_point += top_left_vec
				else:
					start_point += bottom_left_vec

				if point.x < end_point.x:
					end_point += bottom_left_vec
				else:
					end_point += top_left_vec

			simplified_path.append(start_point)
			simplified_path.append(end_point)

			start_point = point
			prev_end_point = end_point
			end_point = Vector2.INF

	if start_point != Vector2.INF:
		if prev_end_point == Vector2.INF || prev_end_point.x < start_point.x:
			start_point += top_left_vec
		else:
			start_point += bottom_left_vec

		simplified_path.append(start_point)

	if end_point != Vector2.INF:
		end_point += top_left_vec
		simplified_path.append(end_point)

	return simplified_path


static func sort_rects(a: Rect2, b: Rect2) -> bool:
	if a.position.y < b.position.y || (a.position.y == b.position.y && a.position.x < b.position.x):
		return true

	return false

