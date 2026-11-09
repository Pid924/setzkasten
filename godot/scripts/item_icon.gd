extends Button
## Square item button that draws its own icon, a count badge and an "armed"/"used" state.
## kind: 0 +20 HP, 1 shield, 2 reroll plain letters, 3 replace dead letters, 4 colour a letter,
## 5 +15 damage, 6 ×2 damage, 7 +3 per letter, 8 attack again, 9 drain.

var kind := 0
var count := 0
var armed := false
var used := false
var font: Font
var instant := true

const INK := Color("1b1a1f")
const PAPER := Color("f3ecdc")
const GOLD := Color("c9a24a")
const RED := Color("b23a2b")
const GREEN := Color("6fbf4f")


func _init() -> void:
	custom_minimum_size = Vector2(60, 60)
	focus_mode = Control.FOCUS_NONE


func refresh(k: int, n: int, is_armed: bool, is_used: bool) -> void:
	kind = k
	count = n
	armed = is_armed
	used = is_used
	instant = kind < 5
	var sb := StyleBoxFlat.new()
	sb.set_corner_radius_all(10)
	sb.set_border_width_all(2)
	if armed:
		sb.bg_color = Color("f0cd6e")
		sb.border_color = Color("fff3d6")
		sb.shadow_color = Color(1, 0.8, 0.3, 0.6)
		sb.shadow_size = 6
	elif instant:
		sb.bg_color = Color("2f4a3a")
		sb.border_color = Color("5e8a6c")
	else:
		sb.bg_color = Color("4a2a22")
		sb.border_color = Color("9a5a42")
	for st in ["normal", "hover", "pressed", "focus", "disabled"]:
		add_theme_stylebox_override(st, sb)
	modulate = Color(1, 1, 1, 0.4) if used else Color.WHITE
	queue_redraw()


func _txt(s: String, pos: Vector2, size: int, col: Color) -> void:
	if font == null:
		return
	var w := font.get_string_size(s, HORIZONTAL_ALIGNMENT_LEFT, -1, size).x
	draw_string_outline(font, pos - Vector2(w / 2, 0), s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, 4, Color(0, 0, 0, 0.6))
	draw_string(font, pos - Vector2(w / 2, 0), s, HORIZONTAL_ALIGNMENT_LEFT, -1, size, col)


func _tile(center: Vector2, s: float, col: Color, letter: String = "") -> void:
	draw_rect(Rect2(center - Vector2(s, s) / 2 + Vector2(0, 2), Vector2(s, s)), Color(0, 0, 0, 0.35))
	draw_rect(Rect2(center - Vector2(s, s) / 2, Vector2(s, s)), col)
	if letter != "":
		_txt(letter, center + Vector2(0, s * 0.3), int(s * 0.75), INK)


func _arrow_arc(c: Vector2, r: float, a0: float, a1: float, col: Color) -> void:
	draw_arc(c, r, a0, a1, 20, col, 3.0, true)
	var tip := c + Vector2(cos(a1), sin(a1)) * r
	var tan: Vector2 = Vector2(-sin(a1), cos(a1)) * signf(a1 - a0)
	var nrm := Vector2(cos(a1), sin(a1))
	draw_colored_polygon(PackedVector2Array([tip + tan * 6, tip - nrm * 5, tip + nrm * 5]), col)


func _draw() -> void:
	var c := size / 2 - Vector2(0, 2)
	match kind:
		0:
			var h := PackedVector2Array()
			for i in 40:
				var t := TAU * i / 40.0
				h.append(c + Vector2(16 * pow(sin(t), 3), -(13 * cos(t) - 5 * cos(2 * t) - 2 * cos(3 * t) - cos(4 * t))) * 1.05)
			draw_colored_polygon(h, Color("d8443a"))
			_txt("+20", c + Vector2(0, 6), 15, PAPER)
		1:
			var sh := PackedVector2Array([c + Vector2(-15, -16), c + Vector2(15, -16), c + Vector2(14, 2), c + Vector2(0, 18), c + Vector2(-14, 2)])
			draw_colored_polygon(sh, Color("7a9cc0"))
			draw_polyline(sh + PackedVector2Array([sh[0]]), Color("dfe9f3"), 2.0, true)
			_txt("−10", c + Vector2(0, 5), 14, INK)
		2:
			_tile(c + Vector2(-7, -5), 18, PAPER, "A")
			_tile(c + Vector2(7, 7), 18, PAPER, "B")
			_arrow_arc(c, 20, -2.6, -0.6, GOLD)
			_arrow_arc(c, 20, 0.6, 2.6, GOLD)
		3:
			_tile(c + Vector2(-2, -2), 24, PAPER, "?")
			draw_line(c + Vector2(-14, -14), c + Vector2(10, 10), RED, 4.0, true)
			draw_line(c + Vector2(10, -14), c + Vector2(-14, 10), RED, 4.0, true)
			draw_circle(c + Vector2(14, -14), 9, GOLD)
			_txt("6", c + Vector2(14, -9), 14, INK)
		4:
			_tile(c + Vector2(-9, -8), 15, Color("e08a7a"))
			_tile(c + Vector2(9, -8), 15, Color("a8e08a"))
			_tile(c + Vector2(0, 8), 15, Color("f0cd6e"))
			draw_circle(c + Vector2(15, 12), 5, PAPER)
		5:
			draw_line(c + Vector2(-14, 14), c + Vector2(12, -12), Color("cfd6da"), 5.0, true)
			draw_line(c + Vector2(-16, 6), c + Vector2(-6, 16), GOLD, 4.0, true)
			_txt("+15", c + Vector2(4, 8), 18, Color("ffd27a"))
		6:
			_txt("×2", c + Vector2(0, 10), 28, Color("ff8f6a"))
		7:
			_tile(c + Vector2(-10, -6), 13, PAPER, "a")
			_tile(c + Vector2(4, -6), 13, PAPER, "b")
			_txt("+3", c + Vector2(0, 18), 18, Color("ffd27a"))
		8:
			for dx in [-9, 5]:
				draw_colored_polygon(PackedVector2Array([c + Vector2(dx - 4, -13), c + Vector2(dx + 10, 0), c + Vector2(dx - 4, 13), c + Vector2(dx + 1, 0)]), Color("ffd27a"))
		9:
			draw_colored_polygon(PackedVector2Array([c + Vector2(0, -17), c + Vector2(10, 1), c + Vector2(-10, 1)]), Color("a3201a"))
			draw_circle(c + Vector2(0, 5), 11, Color("a3201a"))
			draw_circle(c + Vector2(-4, 3), 3, Color(1, 1, 1, 0.45))
			_txt("50%", c + Vector2(0, 26), 11, PAPER)
	if count > 1:
		draw_circle(Vector2(size.x - 9, size.y - 9), 9, INK)
		draw_arc(Vector2(size.x - 9, size.y - 9), 9, 0, TAU, 20, GOLD, 1.5, true)
		_txt(str(count), Vector2(size.x - 9, size.y - 4), 13, PAPER)
