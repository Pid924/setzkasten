extends Button
## Small round icon button drawn in code, used on the battle stage.
## icon: "hint" (light bulb), "shuffle" (two arrows), "clear" (cross).

var icon_kind := "hint"

const GOLD := Color("c9a24a")
const PAPER := Color("f3ecdc")


func _init() -> void:
	custom_minimum_size = Vector2(46, 46)
	size = Vector2(46, 46)
	focus_mode = Control.FOCUS_NONE
	flat = true
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func set_off(off: bool) -> void:
	disabled = off
	modulate.a = 0.35 if off else 1.0


func _draw() -> void:
	var c := size / 2
	draw_circle(c, 22, Color(0.1, 0.07, 0.05, 0.82))
	draw_arc(c, 22, 0, TAU, 36, GOLD, 2.0, true)
	match icon_kind:
		"hint":
			draw_circle(c + Vector2(0, -4), 9, Color("ffd27a"))
			draw_rect(Rect2(c + Vector2(-5, 4), Vector2(10, 7)), Color("bfc4c7"))
			draw_line(c + Vector2(-5, 7), c + Vector2(5, 7), Color("6d7174"), 1.5)
			draw_line(c + Vector2(-3, -5), c + Vector2(0, -1), Color("b2771e"), 1.5, true)
			draw_line(c + Vector2(3, -5), c + Vector2(0, -1), Color("b2771e"), 1.5, true)
		"shuffle":
			_arrow(c, 11, -2.7, -0.4)
			_arrow(c, 11, 0.45, 2.75)
		"clear":
			draw_line(c + Vector2(-8, -8), c + Vector2(8, 8), Color("ff8f7a"), 4.0, true)
			draw_line(c + Vector2(8, -8), c + Vector2(-8, 8), Color("ff8f7a"), 4.0, true)


func _arrow(c: Vector2, r: float, a0: float, a1: float) -> void:
	draw_arc(c, r, a0, a1, 16, PAPER, 3.0, true)
	var tip := c + Vector2(cos(a1), sin(a1)) * r
	var tg := Vector2(-sin(a1), cos(a1))
	var nr := Vector2(cos(a1), sin(a1))
	draw_colored_polygon(PackedVector2Array([tip + tg * 6, tip - nr * 5, tip + nr * 5]), PAPER)
