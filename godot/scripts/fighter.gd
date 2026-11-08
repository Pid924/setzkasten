extends Node2D
## Vector-drawn character. Origin is at the feet; the drawing spans x -32..32, y -64..0 in local units.
## kind: "me" for the typesetter hero, otherwise an enemy body ("blob", "bug", "horns", "stripes",
## "square", "ghost", "crown", "dragon").

var kind := "me"
var body_color := Color("3b3f6b")
var _bob: Tween


func setup(k: String, c: Color = Color.WHITE) -> void:
	kind = k
	body_color = c
	queue_redraw()


func start_idle(speed: float = 1.2) -> void:
	if _bob:
		_bob.kill()
	_bob = create_tween().set_loops()
	_bob.tween_property(self, "position:y", position.y - 5.0, speed).set_trans(Tween.TRANS_SINE)
	_bob.tween_property(self, "position:y", position.y, speed).set_trans(Tween.TRANS_SINE)


func stop_idle() -> void:
	if _bob:
		_bob.kill()
		_bob = null


# SVG-space helper: converts 0..64 artwork coordinates to the feet-origin frame.
func p(x: float, y: float) -> Vector2:
	return Vector2(x - 32.0, y - 64.0)


func pts(arr: Array) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in range(0, arr.size(), 2):
		out.append(p(arr[i], arr[i + 1]))
	return out


func ellipse(cx: float, cy: float, rx: float, ry: float, n: int = 28) -> PackedVector2Array:
	var out := PackedVector2Array()
	for i in n:
		var a := TAU * i / n
		out.append(p(cx + cos(a) * rx, cy + sin(a) * ry))
	return out


func _draw() -> void:
	draw_colored_polygon(ellipse(32, 61, 17, 3), Color(0, 0, 0, 0.35))
	if kind == "me":
		_draw_me()
	else:
		_draw_enemy()


func _draw_me() -> void:
	var skin := Color("e8b88f")
	var cream := Color("e9dfc9")
	# coat and apron
	draw_colored_polygon(pts([20, 60, 20, 44, 24, 37, 32, 34, 40, 37, 44, 44, 44, 60]), Color("3d5a73"))
	draw_colored_polygon(pts([24, 60, 24, 42, 26, 38, 38, 38, 40, 42, 40, 60]), cream)
	draw_line(p(26, 40), p(24, 34), Color("b9a888"), 1.0)
	draw_line(p(38, 40), p(40, 34), Color("b9a888"), 1.0)
	# head and hair
	draw_circle(p(32, 26), 11, skin)
	draw_colored_polygon(pts([21, 23, 23, 17, 28, 14, 36, 14, 41, 17, 43, 23, 38, 20, 26, 20]), Color("5a3b26"))
	# folded paper printer's hat
	draw_colored_polygon(pts([17, 19, 32, 4, 47, 19]), Color("f3ecdc"))
	draw_polyline(pts([17, 19, 32, 4, 47, 19, 17, 19]), Color("b9a888"), 1.2)
	draw_line(p(22, 14), p(42, 14), Color("b9a888"), 1.0)
	# face
	draw_circle(p(28, 27), 1.7, Color("1b1a1f"))
	draw_circle(p(36, 27), 1.7, Color("1b1a1f"))
	draw_arc(p(32, 29), 3.5, 0.35, PI - 0.35, 10, Color("1b1a1f"), 1.5)
	draw_circle(p(25, 30.5), 2.0, Color(0.9, 0.6, 0.48, 0.6))
	draw_circle(p(39, 30.5), 2.0, Color(0.9, 0.6, 0.48, 0.6))
	# composing stick with three brass sorts
	draw_rect(Rect2(p(42, 38), Vector2(16, 5)), Color("9aa3a8"))
	draw_rect(Rect2(p(42, 38), Vector2(16, 5)), Color("5f676b"), false, 1.0)
	for x in [44.0, 48.0, 52.0]:
		draw_rect(Rect2(p(x, 34.5), Vector2(3, 4)), Color("c9a24a"))
	draw_circle(p(44, 44), 3.5, skin)
	draw_circle(p(20, 46), 3.5, skin)


func _draw_enemy() -> void:
	var c := body_color
	var dark := Color("2a1d15")
	match kind:
		"square":
			draw_rect(Rect2(p(12, 14), Vector2(40, 40)), c)
			draw_line(p(16, 22), p(22, 22), Color("5e3218"), 2)
			draw_line(p(42, 46), p(48, 46), Color("5e3218"), 2)
		"ghost":
			draw_colored_polygon(pts([12, 56, 12, 30, 15, 20, 22, 12, 32, 10, 42, 12, 49, 20, 52, 30, 52, 56, 45, 51, 39, 56, 32, 51, 26, 56, 19, 51]), c)
		"bug":
			for leg in [[14, 30, 6, 26], [14, 38, 5, 38], [14, 46, 6, 50], [50, 30, 58, 26], [50, 38, 59, 38], [50, 46, 58, 50], [26, 22, 22, 11], [38, 22, 42, 11]]:
				draw_line(p(leg[0], leg[1]), p(leg[2], leg[3]), c, 3)
			draw_colored_polygon(ellipse(32, 36, 18, 16), c)
		"dragon":
			draw_colored_polygon(pts([52, 30, 62, 22, 59, 34]), Color("4a5054"))
			draw_colored_polygon(pts([12, 30, 2, 22, 5, 34]), Color("4a5054"))
			draw_colored_polygon(ellipse(32, 33, 22, 23), c)
		_:
			draw_colored_polygon(pts([32, 10, 44, 13, 52, 22, 54, 34, 50, 47, 41, 55, 32, 56, 21, 54, 13, 46, 10, 34, 14, 25, 18, 22, 21, 15]), c)
			draw_circle(p(52, 54), 3, c)
			draw_circle(p(10, 52), 2, c)
	if kind == "horns" or kind == "dragon":
		draw_colored_polygon(pts([18, 22, 12, 8, 24, 17]), dark)
		draw_colored_polygon(pts([46, 22, 52, 8, 40, 17]), dark)
	if kind == "stripes":
		for s in [[14, 30, 22, 30], [14, 38, 21, 38], [50, 30, 42, 30], [50, 38, 43, 38], [30, 12, 30, 18], [36, 12, 36, 18]]:
			draw_line(p(s[0], s[1]), p(s[2], s[3]), dark, 3)
	if kind == "crown":
		draw_colored_polygon(pts([18, 16, 23, 6, 28, 13, 32, 4, 36, 13, 41, 6, 46, 16]), Color("c9a24a"))
		draw_rect(Rect2(p(18, 40), Vector2(28, 5)), Color("1b1a1f"))
	if kind == "dragon":
		draw_colored_polygon(pts([22, 50, 25, 55, 28, 50, 32, 55, 36, 50, 39, 55, 42, 50]), Color("e9dfc9"))
	# eyes, angry brows, frown
	var eye := Color("f3ecdc")
	var ink := Color("1b1a1f")
	draw_circle(p(25, 32), 5, eye)
	draw_circle(p(39, 32), 5, eye)
	draw_circle(p(24, 33), 2.3, ink)
	draw_circle(p(38, 33), 2.3, ink)
	draw_line(p(20, 25), p(28, 28), ink, 2)
	draw_line(p(44, 25), p(36, 28), ink, 2)
	draw_arc(p(32, 49), 8, PI + 0.6, TAU - 0.6, 12, ink, 2.5)
