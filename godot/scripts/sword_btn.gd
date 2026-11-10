extends Button
## Round sword button shown on the battle stage while the selected letters form a word.
## Tapping it sends the word. `label` shows the damage under the blade.

var font: Font
var label := ""
var _t := 0.0

const GOLD := Color("c9a24a")
const STEEL := Color("dfe6ea")
const STEEL_DARK := Color("9aa6ad")
const INK := Color("1b1a1f")


func _init() -> void:
	custom_minimum_size = Vector2(76, 76)
	size = Vector2(76, 76)
	pivot_offset = size / 2
	focus_mode = Control.FOCUS_NONE
	flat = true
	mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND


func _process(delta: float) -> void:
	if not visible:
		return
	_t += delta
	scale = Vector2.ONE * (1.0 + 0.06 * sin(_t * 6.0))
	queue_redraw()


func _draw() -> void:
	var c := size / 2
	var glow := 0.35 + 0.15 * sin(_t * 6.0)
	draw_circle(c, 37, Color(1.0, 0.75, 0.3, glow * 0.5))
	draw_circle(c, 32, Color("4a2a22"))
	draw_arc(c, 32, 0, TAU, 40, GOLD, 3.0, true)
	# diagonal sword pointing up-right, towards the enemy
	var dir := Vector2(1, -1).normalized()
	var nrm := Vector2(dir.y, -dir.x) * -1.0
	var hilt := c - dir * 13
	var tip := c + dir * 22
	draw_colored_polygon(PackedVector2Array([hilt + nrm * 4.5, tip - dir * 6 + nrm * 4.5, tip, tip - dir * 6 - nrm * 4.5, hilt - nrm * 4.5]), STEEL)
	draw_line(hilt, tip - dir * 4, STEEL_DARK, 1.5, true)
	draw_line(hilt + nrm * 11, hilt - nrm * 11, GOLD, 5.0, true)
	draw_line(hilt, hilt - dir * 11, Color("6b3b22"), 5.0, true)
	draw_circle(hilt - dir * 13, 3.5, GOLD)
	if font and label != "":
		var fs := 16
		var w := font.get_string_size(label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs).x
		var p := Vector2(c.x - w / 2, size.y + 14)
		draw_string_outline(font, p, label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, 6, Color(0, 0, 0, 0.85))
		draw_string(font, p, label, HORIZONTAL_ALIGNMENT_LEFT, -1, fs, Color("ffd27a"))
