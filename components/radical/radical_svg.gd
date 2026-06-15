extends Control

var hanzi_data: Dictionary = {
	"character": "㐭",
	"strokes": [
		"M 340 490 Q 380 506 572 528 Q 588 529 589 537 Q 590 550 573 559 Q 546 571 524 566 Q 424 545 358 531 L 308 521 Q 161 499 106 494 Q 93 493 90 485 Q 86 475 101 463 Q 135 438 190 450 Q 248 468 299 480 L 340 490 Z",
		"M 309 421 Q 310 425 314 431 Q 327 458 340 490 L 358 531 Q 362 541 369 550 Q 379 560 372 569 Q 362 582 338 594 L 306 589 Q 306 588 309 583 Q 316 564 308 521 L 299 480 Q 286 437 280 415 C 272 386 297 393 309 421 Z",
		"M 193 395 Q 181 401 157 405 Q 144 409 141 404 Q 134 398 142 382 Q 175 301 190 173 Q 191 134 212 108 Q 228 86 235 101 Q 238 111 240 125 L 240 148 Q 239 164 236 185 Q 214 326 210 364 C 207 389 207 389 193 395 Z",
		"M 458 157 Q 477 132 493 125 Q 503 118 519 140 Q 535 171 561 335 Q 568 366 592 393 Q 605 406 592 420 Q 576 436 532 462 Q 514 469 423 445 Q 413 445 309 421 L 280 415 Q 231 405 193 395 C 164 388 181 355 210 364 Q 295 391 447 418 Q 481 424 493 413 Q 509 395 507 377 Q 486 209 468 190 C 455 163 454 162 458 157 Z",
		"M 282 335 Q 275 338 262 340 Q 252 341 250 338 Q 246 334 252 322 Q 268 288 280 229 Q 281 213 292 201 Q 305 185 309 196 Q 310 203 312 215 L 310 241 Q 301 301 301 315 C 300 328 300 328 282 335 Z",
		"M 420 262 Q 432 304 446 317 Q 462 338 445 349 Q 429 356 408 370 Q 392 379 378 369 Q 362 357 338 350 Q 313 343 282 335 C 253 327 273 305 301 315 Q 316 321 365 330 Q 381 333 384 327 Q 390 321 378 261 C 372 232 411 233 420 262 Z",
		"M 312 215 Q 318 214 326 216 Q 360 226 436 235 Q 443 236 445 244 Q 445 250 420 262 L 378 261 Q 341 251 310 241 C 281 232 282 217 312 215 Z",
		"M 240 125 Q 247 124 260 126 Q 371 145 458 157 C 488 161 498 187 468 190 Q 452 193 419 185 Q 323 166 240 148 C 211 142 210 126 240 125 Z"
	]
}

var stroke_color: Color = Color.WHITE
var fit_padding: float = 0.8

func _ready() -> void:
	item_rect_changed.connect(queue_redraw)

# ------------------------------------------------------------------------------
# Draw svg
# ------------------------------------------------------------------------------
func _draw() -> void:
	var card_size = size
	if card_size.x <= 0 or card_size.y <= 0:
		return
	var processed_strokes: Array[PackedVector2Array] = []
	var min_p := Vector2(INF, INF)
	var max_p := Vector2(-INF, -INF)

	for stroke_str in hanzi_data["strokes"]:
		var raw_pts = parse_svg_string(stroke_str)
		var corrected_stroke := PackedVector2Array()
		for pt in raw_pts:
			# Structural dataset layout correction (-y + 900 offset header baseline shift)
			var corrected_pt = Vector2(pt.x, -pt.y + 900.0)
			corrected_stroke.append(corrected_pt)
			# Map out visual boundaries
			min_p.x = min(min_p.x, corrected_pt.x)
			min_p.y = min(min_p.y, corrected_pt.y)
			max_p.x = max(max_p.x, corrected_pt.x)
			max_p.y = max(max_p.y, corrected_pt.y)
		if not corrected_stroke.is_empty():
			processed_strokes.append(corrected_stroke)
	if processed_strokes.is_empty():
		return

	# Determine center coordinates
	var ink_size = max_p - min_p
	var ink_center = min_p + (ink_size / 2.0)
	# Scale by narrowest dimension of parent container (radical card)
	var scale_factor: float = min(card_size.x / ink_size.x, card_size.y / ink_size.y)
	scale_factor *= fit_padding
	var card_center = card_size / 2.0

	for stroke in processed_strokes:
		var visual_points := PackedVector2Array()
		for pt in stroke:
			var final_x = (pt.x - ink_center.x) * scale_factor + card_center.x
			var final_y = (pt.y - ink_center.y) * scale_factor + card_center.y
			visual_points.append(Vector2(final_x, final_y))
		if visual_points.size() > 2:
			draw_polygon(visual_points, [stroke_color])

# ------------------------------------------------------------------------------
# SVG string to vectors
# ------------------------------------------------------------------------------
func parse_svg_string(path_str: String) -> PackedVector2Array:
	var parsed_points := PackedVector2Array()
	var regex = RegEx.new()
	regex.compile("-?\\d+\\.?\\d*")
	var matches = regex.search_all(path_str)
	
	var i = 0
	while i < matches.size() - 1:
		var x_val = float(matches[i].get_string())
		var y_val = float(matches[i+1].get_string())
		parsed_points.append(Vector2(x_val, y_val))
		i += 2
		
	return parsed_points
