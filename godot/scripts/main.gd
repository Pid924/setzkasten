extends Control
## Setzkasten: a German word-building tile game with a Classic mode and a Battle mode.
## The whole interface is built in code so the project needs no editor-made scenes.

const Fighter := preload("res://scripts/fighter.gd")

const COLS := 7
const ROWS := 7
const GAP := 6.0
const HINT_HP := 3
const HINT_PTS := 50
const VAL := {"e": 1, "n": 1, "s": 1, "i": 1, "r": 1, "t": 1, "u": 1, "a": 1, "d": 1, "h": 2, "g": 2, "l": 2, "o": 2,
	"m": 3, "b": 3, "w": 3, "z": 3, "c": 4, "f": 4, "k": 4, "p": 4, "ch": 4, "ä": 6, "j": 6, "ü": 6, "v": 6, "ö": 8, "x": 8, "q": 10, "y": 10}
# German letter frequencies (per mille); C mostly lives inside the CH sort.
const FREQ := {"e": 150, "n": 90, "i": 72, "s": 68, "r": 66, "a": 64, "t": 58, "d": 46, "h": 36, "u": 40, "l": 34, "g": 28,
	"o": 30, "m": 25, "b": 19, "w": 17, "f": 16, "k": 14, "z": 11, "p": 9, "v": 7, "ch": 22, "c": 3, "ü": 6, "ä": 5, "ö": 4,
	"j": 3, "y": 1, "x": 1, "q": 1}
const VOWELS := ["a", "e", "i", "o", "u", "ä", "ö", "ü"]
const LMULT := [0, 0, 0, 1.0, 1.25, 1.5, 2.0, 2.5, 3.0, 3.5, 4.0, 4.5, 5.0]
const FOES := [
	{"de": "Tintenklecks", "c": "3b3f6b", "f": "blob"}, {"de": "Bücherlaus", "c": "8a7a52", "f": "bug"},
	{"de": "Druckfehlerteufel", "c": "a3352a", "f": "horns"}, {"de": "Papiertiger", "c": "d8c49a", "f": "stripes"},
	{"de": "Rostgolem", "c": "9a5a32", "f": "square"}, {"de": "Schattenschrift", "c": "4b4553", "f": "ghost"},
	{"de": "Zensor", "c": "55606b", "f": "crown"}, {"de": "Bleidrache", "c": "6b7378", "f": "dragon"}]

# palette: walnut type case, lead sorts, proof paper, brass and rubrication red
const C_WOOD := Color("2a1d15")
const C_WOOD2 := Color("3a2a1f")
const C_GROOVE := Color("1a120c")
const C_EDGE := Color("4a3828")
const C_SORT := Color("e9dfc9")
const C_SORT_EDGE := Color("b9a888")
const C_INK := Color("1b1a1f")
const C_PAPER := Color("f3ecdc")
const C_BRASS := Color("c9a24a")
const C_RUBRIC := Color("b23a2b")
const C_OK := Color("5b8f4e")
const C_MUTED := Color("a8957a")

var f_body: Font = preload("res://fonts/IBMPlexSansThai-Regular.ttf")
var f_bold: Font = preload("res://fonts/IBMPlexSansThai-SemiBold.ttf")
var f_sort: Font = preload("res://fonts/ZillaSlab-Bold.ttf")
var f_display: FontVariation

# dictionary
var words := PackedStringArray()
var word_set := {}
var gloss := {}

# settings
var cfg := ConfigFile.new()
const CFG_PATH := "user://setzkasten.cfg"
var lang := "th"
var mode := "classic"

# game state
var grid := []
var sel := []
var score := 0
var chap := 1
var chap_score := 0
var lives := 3
var uid := 0
var best := 0
var found := []
var moves := 0
var busy := false
var php := 100
var pmax := 100
var foe := {}
var editing := ""
var pool := []

# ui
var ts := 80.0
var colw := 680.0
var scroll: ScrollContainer
var cols: GridContainer
var left: VBoxContainer
var title_lbl: RichTextLabel
var mode_lbl: Label
var mode_btn: Button
var stat_score: Label
var stat_chap: Label
var stat_chap_lbl: Label
var stat_lives: Label
var stat_lives_box: Control
var stat_best: Label
var stat_labels := {}
var prog: ProgressBar
var stage: Panel
var scene: Node2D
var fx: Node2D
var me_node: Node2D
var foe_node: Node2D
var me_info: VBoxContainer
var foe_info: VBoxContainer
var me_hp: ProgressBar
var me_hp_lbl: Label
var foe_hp: ProgressBar
var foe_hp_lbl: Label
var foe_name_lbl: Label
var foe_atk_lbl: Label
var me_name_lbl: Label
var tray: PanelContainer
var board: Control
var tiles_root: Control
var word_lbl: Label
var pts_lbl: Label
var word_panel: PanelContainer
var btn_submit: Button
var btn_clear: Button
var btn_hint: Button
var btn_shuffle: Button
var dict_panel: PanelContainer
var dict_title: Label
var dict_lang_btns := {}
var chapinfo: Label
var recent_box: VBoxContainer
var log_box: VBoxContainer
var log_scroll: ScrollContainer
var rules_btn: Button
var rules_lbl: Label
var overlay: Control
var ov_title: Label
var ov_body: Label
var ov_extra: VBoxContainer
var ov_buttons: HBoxContainer
var toast_panel: PanelContainer
var toast_lbl: Label
var toast_tween: Tween
var styles := {}
var drag := {}
var hint_tweens := []


func _ready() -> void:
	f_display = FontVariation.new()
	f_display.base_font = preload("res://fonts/GrenzeGotisch-VF.ttf")
	f_display.variation_opentype = {TextServerManager.get_primary_interface().name_to_tag("wght"): 700}
	f_display.fallbacks = [f_body]
	f_sort.fallbacks = [f_body]
	for k in FREQ:
		for i in FREQ[k]:
			pool.append(k)
	_load_settings()
	_load_dictionary()
	_build_styles()
	_build_ui()
	get_viewport().size_changed.connect(_layout)
	_layout()
	new_game(mode)
	pick_mode(false)
	if OS.has_feature("web") and str(JavaScriptBridge.eval("location.search")).contains("autotest"):
		_autotest()


# Plays a few battle turns by itself; only runs when the page URL contains ?autotest.
func _autotest() -> void:
	await get_tree().create_timer(1.0).timeout
	new_game("battle")
	for i in 6:
		await get_tree().create_timer(1.5).timeout
		if overlay.visible:
			close_overlay()
		var path := find_word(4)
		if path.is_empty():
			continue
		sel = path
		update_word()
		await get_tree().create_timer(0.4).timeout
		submit()


# ---------------- settings & data ----------------
func _load_settings() -> void:
	cfg.load(CFG_PATH)
	lang = cfg.get_value("settings", "lang", "th")
	if not lang in I18n.LANGS:
		lang = "th"
	mode = cfg.get_value("settings", "mode", "classic")


func _save() -> void:
	cfg.save(CFG_PATH)


func setting(key: String, def: Variant) -> Variant:
	return cfg.get_value("settings", key, def)


func set_setting(key: String, v: Variant) -> void:
	cfg.set_value("settings", key, v)
	_save()


func _load_dictionary() -> void:
	var f := FileAccess.open("res://data/words.txt", FileAccess.READ)
	words = f.get_as_text().split("\n", false)
	words.sort()
	for w in words:
		word_set[w] = true
	var g := FileAccess.open("res://data/gloss.json", FileAccess.READ)
	gloss = JSON.parse_string(g.get_as_text())


func is_word(w: String) -> bool:
	return w.length() >= 3 and word_set.has(w)


func has_prefix(pre: String) -> bool:
	var i := words.bsearch(pre)
	return i < words.size() and words[i].begins_with(pre)


func t(key: String, vars: Dictionary = {}) -> Variant:
	return I18n.get_text(lang, key, vars)


# ---------------- styling ----------------
func box(bg: Color, radius: float = 8.0, border: Color = Color.TRANSPARENT, bw: int = 0, shadow: int = 0, shadow_col: Color = Color(0, 0, 0, 0.45)) -> StyleBoxFlat:
	var s := StyleBoxFlat.new()
	s.bg_color = bg
	s.set_corner_radius_all(int(radius))
	if bw > 0:
		s.border_color = border
		s.set_border_width_all(bw)
	if shadow > 0:
		s.shadow_size = shadow
		s.shadow_color = shadow_col
		s.shadow_offset = Vector2(0, 3)
	s.content_margin_left = 10
	s.content_margin_right = 10
	s.content_margin_top = 6
	s.content_margin_bottom = 6
	return s


func _tile_style(top: Color, bottom_edge: Color) -> StyleBoxFlat:
	var s := box(top, 6, bottom_edge, 0, 4)
	s.border_width_bottom = 4
	s.border_color = bottom_edge
	return s


func _build_styles() -> void:
	styles.tile = _tile_style(C_SORT, C_SORT_EDGE)
	styles.tile_sel = _tile_style(Color("fff2c4"), C_RUBRIC)
	styles.tile_sel.set_border_width_all(3)
	styles.tile_sel.border_width_bottom = 5
	styles.tile_red = _tile_style(Color("d98472"), Color("8e3e2e"))
	styles.tile_gold = _tile_style(Color("f2cf63"), Color("98741c"))
	styles.tile_heal = _tile_style(Color("a9cf8f"), Color("4f7a3b"))
	styles.tile_ink = _tile_style(Color("2c2a33"), Color("000000"))
	var th := Theme.new()
	th.default_font = f_body
	th.default_font_size = 22
	th.set_color("font_color", "Label", C_PAPER)
	var b := box(C_WOOD2, 8, Color("5a4632"), 1)
	b.content_margin_left = 14
	b.content_margin_right = 14
	b.content_margin_top = 10
	b.content_margin_bottom = 10
	var bh := b.duplicate()
	bh.border_color = C_BRASS
	var bd := b.duplicate()
	bd.bg_color = Color("2f2219")
	th.set_stylebox("normal", "Button", b)
	th.set_stylebox("hover", "Button", bh)
	th.set_stylebox("pressed", "Button", bh)
	th.set_stylebox("disabled", "Button", bd)
	th.set_stylebox("focus", "Button", box(Color.TRANSPARENT, 8, C_BRASS, 3))
	th.set_color("font_color", "Button", C_PAPER)
	th.set_color("font_hover_color", "Button", C_PAPER)
	th.set_color("font_pressed_color", "Button", C_PAPER)
	th.set_color("font_disabled_color", "Button", Color(C_PAPER, 0.4))
	th.set_font("font", "Button", f_bold)
	th.set_font_size("font_size", "Button", 22)
	th.set_stylebox("normal", "LineEdit", box(Color("fffdf6"), 6, C_INK, 2))
	th.set_stylebox("focus", "LineEdit", box(Color.TRANSPARENT, 6, C_BRASS, 2))
	th.set_color("font_color", "LineEdit", C_INK)
	th.set_color("font_placeholder_color", "LineEdit", Color(C_INK, 0.45))
	th.set_color("caret_color", "LineEdit", C_INK)
	th.set_font_size("font_size", "LineEdit", 22)
	th.set_color("font_color", "CheckBox", C_INK)
	th.set_color("font_hover_color", "CheckBox", C_INK)
	th.set_color("font_pressed_color", "CheckBox", C_INK)
	th.set_color("font_hover_pressed_color", "CheckBox", C_INK)
	th.set_stylebox("normal", "CheckBox", StyleBoxEmpty.new())
	th.set_stylebox("hover", "CheckBox", StyleBoxEmpty.new())
	th.set_stylebox("pressed", "CheckBox", StyleBoxEmpty.new())
	th.set_stylebox("hover_pressed", "CheckBox", StyleBoxEmpty.new())
	th.set_stylebox("focus", "CheckBox", box(Color.TRANSPARENT, 6, C_BRASS, 2))
	th.set_stylebox("background", "ProgressBar", box(Color("120c08"), 5, Color("5a4632"), 1))
	th.set_stylebox("fill", "ProgressBar", box(C_OK, 5))
	th.set_stylebox("panel", "ScrollContainer", StyleBoxEmpty.new())
	theme = th


func lbl(text: String = "", size: int = 22, col: Color = C_PAPER, font: Font = null) -> Label:
	var l := Label.new()
	l.text = text
	l.add_theme_font_size_override("font_size", size)
	l.add_theme_color_override("font_color", col)
	if font:
		l.add_theme_font_override("font", font)
	return l


func btn(text: String, cb: Callable) -> Button:
	var b := Button.new()
	b.text = text
	b.pressed.connect(cb)
	return b


func styled_btn(b: Button, bg: Color, fg: Color, border: Color = Color.TRANSPARENT) -> Button:
	var n := box(bg, 8, border, 2 if border.a > 0 else 0)
	n.content_margin_left = 14
	n.content_margin_right = 14
	n.content_margin_top = 10
	n.content_margin_bottom = 10
	var h := n.duplicate()
	h.bg_color = bg.lightened(0.08)
	var d := n.duplicate()
	d.bg_color = bg.darkened(0.45)
	b.add_theme_stylebox_override("normal", n)
	b.add_theme_stylebox_override("hover", h)
	b.add_theme_stylebox_override("pressed", h)
	b.add_theme_stylebox_override("disabled", d)
	for k in ["font_color", "font_hover_color", "font_pressed_color", "font_focus_color"]:
		b.add_theme_color_override(k, fg)
	b.add_theme_color_override("font_disabled_color", Color(fg, 0.45))
	return b


# ---------------- ui construction ----------------
func _build_ui() -> void:
	var bg := ColorRect.new()
	bg.color = C_WOOD
	bg.set_anchors_preset(Control.PRESET_FULL_RECT)
	add_child(bg)
	scroll = ScrollContainer.new()
	scroll.set_anchors_preset(Control.PRESET_FULL_RECT)
	scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	add_child(scroll)
	var outer := MarginContainer.new()
	outer.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	for side in ["left", "right", "top", "bottom"]:
		outer.add_theme_constant_override("margin_" + side, 18)
	scroll.add_child(outer)
	cols = GridContainer.new()
	cols.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	cols.add_theme_constant_override("h_separation", 26)
	cols.add_theme_constant_override("v_separation", 20)
	outer.add_child(cols)

	left = VBoxContainer.new()
	left.add_theme_constant_override("separation", 12)
	cols.add_child(left)

	# header
	var head := HBoxContainer.new()
	head.add_theme_constant_override("separation", 12)
	left.add_child(head)
	title_lbl = RichTextLabel.new()
	title_lbl.bbcode_enabled = true
	title_lbl.fit_content = true
	title_lbl.scroll_active = false
	title_lbl.autowrap_mode = TextServer.AUTOWRAP_OFF
	title_lbl.add_theme_font_override("normal_font", f_display)
	title_lbl.add_theme_font_size_override("normal_font_size", 58)
	title_lbl.text = "Setz[color=#b23a2b]k[/color]asten"
	title_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	head.add_child(title_lbl)
	var hr := VBoxContainer.new()
	hr.alignment = BoxContainer.ALIGNMENT_CENTER
	head.add_child(hr)
	mode_lbl = lbl("", 18, C_MUTED)
	mode_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	hr.add_child(mode_lbl)
	mode_btn = btn("", func(): pick_mode(true))
	mode_btn.add_theme_font_size_override("font_size", 18)
	hr.add_child(mode_btn)

	# stats
	var stats := HBoxContainer.new()
	stats.add_theme_constant_override("separation", 8)
	left.add_child(stats)
	var mk_stat := func(key: String) -> Array:
		var p := PanelContainer.new()
		p.add_theme_stylebox_override("panel", box(C_GROOVE, 6, C_EDGE, 1))
		p.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		var v := VBoxContainer.new()
		v.add_theme_constant_override("separation", 0)
		p.add_child(v)
		var cap := lbl("", 18, C_MUTED)
		var val := lbl("0", 30, C_PAPER, f_sort)
		v.add_child(cap)
		v.add_child(val)
		stats.add_child(p)
		stat_labels[key] = cap
		return [p, cap, val]
	stat_score = mk_stat.call("score")[2]
	var sc: Array = mk_stat.call("chap")
	stat_chap_lbl = sc[1]
	stat_chap = sc[2]
	var sl: Array = mk_stat.call("lives")
	stat_lives_box = sl[0]
	stat_lives = sl[2]
	stat_lives.add_theme_color_override("font_color", C_RUBRIC)
	stat_best = mk_stat.call("best")[2]

	prog = ProgressBar.new()
	prog.show_percentage = false
	prog.custom_minimum_size.y = 10
	prog.add_theme_stylebox_override("fill", box(C_BRASS, 5))
	left.add_child(prog)

	_build_stage()

	# board tray
	tray = PanelContainer.new()
	var ts_box := box(C_GROOVE, 10, C_EDGE, 2)
	ts_box.set_content_margin_all(10)
	tray.add_theme_stylebox_override("panel", ts_box)
	tray.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	left.add_child(tray)
	board = Control.new()
	board.mouse_filter = Control.MOUSE_FILTER_STOP
	board.gui_input.connect(_on_board_input)
	tray.add_child(board)
	tiles_root = Control.new()
	tiles_root.mouse_filter = Control.MOUSE_FILTER_IGNORE
	board.add_child(tiles_root)

	# composing stick: current word and buttons
	word_panel = PanelContainer.new()
	word_panel.add_theme_stylebox_override("panel", box(C_WOOD2, 8, C_EDGE, 1))
	word_panel.custom_minimum_size.y = 66
	left.add_child(word_panel)
	var wh := HBoxContainer.new()
	word_panel.add_child(wh)
	word_lbl = lbl("", 34, C_MUTED, f_sort)
	word_lbl.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	word_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	word_lbl.autowrap_mode = TextServer.AUTOWRAP_ARBITRARY
	wh.add_child(word_lbl)
	pts_lbl = lbl("", 24, C_BRASS, f_sort)
	pts_lbl.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	wh.add_child(pts_lbl)
	var brow := HBoxContainer.new()
	brow.add_theme_constant_override("separation", 8)
	left.add_child(brow)
	btn_submit = styled_btn(btn("", submit), C_BRASS, C_INK)
	btn_submit.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	brow.add_child(btn_submit)
	btn_clear = btn("", func(): sel = []; update_word())
	brow.add_child(btn_clear)
	btn_hint = btn("", _on_hint)
	brow.add_child(btn_hint)
	btn_shuffle = btn("", _on_shuffle)
	brow.add_child(btn_shuffle)

	_build_dict()
	_build_overlay()
	_build_toast()


func _build_stage() -> void:
	stage = Panel.new()
	var sb := box(Color("3a2a1f"), 10, C_EDGE, 2)
	stage.add_theme_stylebox_override("panel", sb)
	stage.clip_contents = true
	stage.custom_minimum_size.y = 270
	left.add_child(stage)
	var floor := ColorRect.new()
	floor.color = Color("24180f")
	floor.anchor_left = 0
	floor.anchor_right = 1
	floor.anchor_top = 1
	floor.anchor_bottom = 1
	floor.offset_top = -46
	floor.offset_left = 2
	floor.offset_right = -2
	floor.offset_bottom = -2
	floor.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(floor)
	var glow := ColorRect.new()
	glow.color = Color(1, 0.85, 0.6, 0.05)
	glow.set_anchors_preset(Control.PRESET_TOP_WIDE)
	glow.offset_bottom = 120
	glow.mouse_filter = Control.MOUSE_FILTER_IGNORE
	stage.add_child(glow)
	scene = Node2D.new()
	stage.add_child(scene)
	me_node = Fighter.new()
	me_node.setup("me")
	scene.add_child(me_node)
	foe_node = Fighter.new()
	scene.add_child(foe_node)
	fx = Node2D.new()
	fx.z_index = 5
	scene.add_child(fx)
	var mk_info := func(is_me: bool) -> Array:
		var v := VBoxContainer.new()
		v.add_theme_constant_override("separation", 2)
		v.mouse_filter = Control.MOUSE_FILTER_IGNORE
		stage.add_child(v)
		var name := lbl("", 18, C_PAPER)
		name.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		name.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		v.add_child(name)
		var bar := ProgressBar.new()
		bar.show_percentage = false
		bar.custom_minimum_size.y = 14
		bar.max_value = 100
		if not is_me:
			bar.add_theme_stylebox_override("fill", box(C_RUBRIC, 5))
		v.add_child(bar)
		var hp := lbl("", 18, C_MUTED)
		hp.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		hp.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		v.add_child(hp)
		return [v, name, bar, hp]
	var a: Array = mk_info.call(true)
	me_info = a[0]
	me_name_lbl = a[1]
	me_hp = a[2]
	me_hp_lbl = a[3]
	var b: Array = mk_info.call(false)
	foe_info = b[0]
	foe_name_lbl = b[1]
	foe_hp = b[2]
	foe_hp_lbl = b[3]
	foe_atk_lbl = lbl("", 18, Color("ff8f7a"))
	foe_atk_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	foe_atk_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	foe_info.add_child(foe_atk_lbl)


func _build_dict() -> void:
	dict_panel = PanelContainer.new()
	var ps := box(C_PAPER, 4, Color.TRANSPARENT, 0, 14)
	ps.set_content_margin_all(20)
	dict_panel.add_theme_stylebox_override("panel", ps)
	cols.add_child(dict_panel)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 10)
	dict_panel.add_child(v)
	var h := HBoxContainer.new()
	v.add_child(h)
	dict_title = lbl("Wörterbuch", 38, C_INK, f_display)
	dict_title.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	h.add_child(dict_title)
	var lb := HBoxContainer.new()
	lb.add_theme_constant_override("separation", 0)
	h.add_child(lb)
	for l in I18n.LANGS:
		var b := btn(l.to_upper() if l != "th" else "ไทย", set_lang.bind(l))
		b.add_theme_font_size_override("font_size", 18)
		lb.add_child(b)
		dict_lang_btns[l] = b
	chapinfo = lbl("", 20, Color("6d6252"))
	chapinfo.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	v.add_child(chapinfo)
	var rp := PanelContainer.new()
	var rs := box(Color(1, 1, 1, 0.45), 4, C_INK, 2)
	rs.set_content_margin_all(12)
	rp.add_theme_stylebox_override("panel", rs)
	v.add_child(rp)
	recent_box = VBoxContainer.new()
	recent_box.add_theme_constant_override("separation", 4)
	rp.add_child(recent_box)
	log_scroll = ScrollContainer.new()
	log_scroll.custom_minimum_size.y = 320
	log_scroll.horizontal_scroll_mode = ScrollContainer.SCROLL_MODE_DISABLED
	v.add_child(log_scroll)
	log_box = VBoxContainer.new()
	log_box.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	log_box.add_theme_constant_override("separation", 8)
	log_scroll.add_child(log_box)
	rules_btn = btn("", func(): rules_lbl.visible = not rules_lbl.visible)
	styled_btn(rules_btn, Color.TRANSPARENT, C_INK, C_INK)
	rules_btn.add_theme_font_size_override("font_size", 18)
	rules_btn.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
	v.add_child(rules_btn)
	rules_lbl = lbl("", 18, Color("3d372f"))
	rules_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	rules_lbl.visible = false
	v.add_child(rules_lbl)


func _build_overlay() -> void:
	overlay = Control.new()
	overlay.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.z_index = 50
	overlay.visible = false
	add_child(overlay)
	var dim := ColorRect.new()
	dim.color = Color(0.06, 0.04, 0.02, 0.8)
	dim.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(dim)
	var cc := CenterContainer.new()
	cc.set_anchors_preset(Control.PRESET_FULL_RECT)
	overlay.add_child(cc)
	var card := PanelContainer.new()
	var cs := box(C_PAPER, 8, Color.TRANSPARENT, 0, 30, Color(0, 0, 0, 0.6))
	cs.set_content_margin_all(28)
	card.add_theme_stylebox_override("panel", cs)
	card.custom_minimum_size.x = 560
	cc.add_child(card)
	var v := VBoxContainer.new()
	v.add_theme_constant_override("separation", 12)
	card.add_child(v)
	ov_title = lbl("", 46, C_INK, f_display)
	ov_title.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	v.add_child(ov_title)
	ov_body = lbl("", 22, C_INK)
	ov_body.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	ov_body.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	ov_body.custom_minimum_size.x = 500
	v.add_child(ov_body)
	ov_extra = VBoxContainer.new()
	ov_extra.add_theme_constant_override("separation", 10)
	v.add_child(ov_extra)
	ov_buttons = HBoxContainer.new()
	ov_buttons.add_theme_constant_override("separation", 10)
	v.add_child(ov_buttons)


func _build_toast() -> void:
	toast_panel = PanelContainer.new()
	var s := box(C_INK, 8, C_BRASS, 1)
	s.set_content_margin_all(14)
	toast_panel.add_theme_stylebox_override("panel", s)
	toast_panel.z_index = 60
	toast_panel.visible = false
	toast_panel.mouse_filter = Control.MOUSE_FILTER_IGNORE
	add_child(toast_panel)
	toast_lbl = lbl("", 20, C_PAPER)
	toast_lbl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
	toast_lbl.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	toast_panel.add_child(toast_lbl)


func _layout() -> void:
	var vw := get_viewport_rect().size.x
	var two := vw >= 1180
	cols.columns = 2 if two else 1
	colw = min(vw - 36.0, 680.0)
	left.custom_minimum_size.x = colw
	dict_panel.custom_minimum_size.x = 440.0 if two else colw
	ts = floor(min(86.0, (colw - 24.0 - GAP * (COLS - 1)) / COLS))
	var bw := COLS * ts + (COLS - 1) * GAP
	board.custom_minimum_size = Vector2(bw, ROWS * ts + (ROWS - 1) * GAP)
	_position_stage()
	ov_body.custom_minimum_size.x = min(500.0, vw - 120.0)
	ov_body.get_parent().get_parent().custom_minimum_size.x = min(560.0, vw - 40.0)
	toast_panel.custom_minimum_size.x = min(560.0, vw - 40.0)
	for c in COLS:
		for r in ROWS:
			if grid.size() == COLS and grid[c][r]:
				place(grid[c][r], c, r, false)


func stage_floor() -> float:
	return stage.custom_minimum_size.y - 34.0


func _position_stage() -> void:
	var w := colw
	var fs := 1.9 if w > 560 else 1.35
	me_node.scale = Vector2(fs, fs)
	foe_node.scale = Vector2(fs * 1.1, fs * 1.1)
	stage.custom_minimum_size.y = 270 if w > 560 else 262
	me_node.position = Vector2(w * 0.23, stage_floor())
	foe_node.position = Vector2(w * 0.77, stage_floor())
	if foe_node.has_method("start_idle") and not busy:
		me_node.start_idle(1.2)
		foe_node.start_idle(0.95)
	var iw := w * 0.44
	me_info.position = Vector2(w * 0.23 - iw / 2, 8)
	me_info.size = Vector2(iw, 0)
	me_info.custom_minimum_size.x = iw
	foe_info.position = Vector2(w * 0.77 - iw / 2, 8)
	foe_info.custom_minimum_size.x = iw
	foe_info.size = Vector2(iw, 0)


# ---------------- tiles ----------------
func rand_letter() -> String:
	var vc := 0
	var n := 0
	for col in grid:
		for x in col:
			if x:
				n += 1
				if x.l in VOWELS:
					vc += 1
	if n > 10 and float(vc) / n < 0.3 and randf() < 0.6:
		return ["e", "e", "e", "a", "i", "u", "o", "e", "a", "i"].pick_random()
	if n > 10 and float(vc) / n > 0.5 and randf() < 0.5:
		return ["n", "s", "r", "t", "d", "h", "l", "g"].pick_random()
	return pool.pick_random()


func mk_tile(l: String = "") -> Dictionary:
	uid += 1
	var x := {"id": uid, "l": l if l != "" else rand_letter(), "bonus": 0, "ink": 0, "heal": 0, "c": 0, "r": 0}
	var p := Panel.new()
	p.mouse_filter = Control.MOUSE_FILTER_IGNORE
	p.pivot_offset = Vector2(ts / 2, ts / 2)
	tiles_root.add_child(p)
	var letter := lbl("", 40, C_INK, f_sort)
	letter.set_anchors_preset(Control.PRESET_FULL_RECT)
	letter.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	letter.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
	p.add_child(letter)
	var val := lbl("", 15, Color(C_INK, 0.6), f_sort)
	val.set_anchors_preset(Control.PRESET_BOTTOM_RIGHT)
	val.horizontal_alignment = HORIZONTAL_ALIGNMENT_RIGHT
	p.add_child(val)
	var badge := lbl("", 15, C_INK, f_bold)
	badge.position = Vector2(5, 1)
	p.add_child(badge)
	x.node = p
	x.letter = letter
	x.val = val
	x.badge = badge
	paint(x)
	return x


func paint(x: Dictionary, selected: bool = false) -> void:
	var st: StyleBoxFlat = styles.tile
	if x.ink > 0:
		st = styles.tile_ink
	elif x.heal > 0:
		st = styles.tile_heal
	elif x.bonus == 2:
		st = styles.tile_red
	elif x.bonus == 3:
		st = styles.tile_gold
	if selected:
		st = styles.tile_sel
	x.node.add_theme_stylebox_override("panel", st)
	var L: String = "CH" if x.l == "ch" else x.l.to_upper()
	x.letter.text = L
	x.letter.add_theme_font_size_override("font_size", int(ts * (0.36 if x.l == "ch" else 0.5)))
	var dark: bool = x.ink > 0 and not selected
	x.letter.add_theme_color_override("font_color", C_PAPER if dark else C_INK)
	x.val.text = str(VAL[x.l])
	x.val.add_theme_font_size_override("font_size", int(ts * 0.19))
	x.val.add_theme_color_override("font_color", Color(C_PAPER if dark else C_INK, 0.6))
	x.val.position = Vector2(ts - ts * 0.2 - 6, ts - ts * 0.3 - 4)
	x.val.size = Vector2(ts * 0.2, ts * 0.26)
	var badge := ""
	var bcol := C_INK
	if x.ink > 0:
		badge = str(x.ink)
		bcol = Color("ff8f7a")
	elif x.heal > 0:
		badge = "+" + str(x.heal)
		bcol = Color("1d4a12")
	elif x.bonus > 0:
		badge = "×" + str(x.bonus)
	x.badge.text = badge
	x.badge.add_theme_font_size_override("font_size", int(ts * 0.2))
	x.badge.add_theme_color_override("font_color", bcol)


func decorate(x: Dictionary) -> void:
	if mode != "battle" or x.bonus or x.heal:
		return
	var r := randf()
	if r < 0.07:
		x.heal = 6 + chap
	elif r < 0.105:
		x.bonus = 2
	else:
		return
	paint(x)


func tile_pos(c: int, r: int) -> Vector2:
	return Vector2(c * (ts + GAP), r * (ts + GAP))


func place(x: Dictionary, c: int, r: int, animate: bool = true) -> void:
	x.c = c
	x.r = r
	x.node.size = Vector2(ts, ts)
	x.node.pivot_offset = Vector2(ts / 2, ts / 2)
	var target := tile_pos(c, r)
	if animate and x.node.position != target:
		var tw := create_tween()
		tw.tween_property(x.node, "position", target, 0.32).set_trans(Tween.TRANS_BACK).set_ease(Tween.EASE_OUT)
	else:
		x.node.position = target
	paint(x, x in sel)


# ---------------- game setup ----------------
func best_key() -> String:
	return "best_battle" if mode == "battle" else "best_classic"


func new_game(m: String) -> void:
	mode = m
	set_setting("mode", mode)
	best = setting(best_key(), 0)
	stop_hint()
	for ch in tiles_root.get_children():
		ch.queue_free()
	for ch in fx.get_children():
		ch.queue_free()
	grid = []
	sel = []
	score = 0
	chap = 1
	chap_score = 0
	lives = 3
	found = []
	moves = 0
	busy = false
	php = 100
	pmax = 100
	editing = ""
	stage.visible = mode == "battle"
	prog.visible = mode != "battle"
	stat_lives_box.visible = mode != "battle"
	if mode == "battle":
		spawn_foe()
	for c in COLS:
		var col := []
		for r in ROWS:
			col.append(null)
		grid.append(col)
	for c in COLS:
		for r in ROWS:
			var x := mk_tile()
			grid[c][r] = x
			decorate(x)
	for c in COLS:
		for r in ROWS:
			place(grid[c][r], c, r, false)
	ensure_playable()
	close_overlay()
	apply_lang()


func foe_stats(s: int) -> Dictionary:
	return {"hp": 50 + 35 * (s - 1) + 6 * (s - 1) * (s - 1), "atk": 5 + 3 * (s - 1), "every": 3 if s <= 2 else 2}


func foe_name() -> String:
	return foe.de + ((" " + "I".repeat(foe.lap + 1)) if foe.lap > 0 else "")


func foe_sub() -> String:
	return t("foe")[foe.k]


func spawn_foe() -> void:
	var k := (chap - 1) % FOES.size()
	var st := foe_stats(chap)
	foe = {"de": FOES[k].de, "k": k, "lap": int((chap - 1) / FOES.size()), "hp": st.hp, "max": st.hp, "atk": st.atk, "every": st.every, "cd": st.every}
	foe_node.setup(FOES[k].f, Color(FOES[k].c))
	foe_node.modulate = Color(1, 1, 1, 0)
	foe_node.rotation = 0
	foe_node.scale = me_node.scale * 1.1
	var home: Vector2 = Vector2(colw * 0.77, stage_floor())
	foe_node.position = home + Vector2(60, 0)
	var tw := create_tween().set_parallel()
	tw.tween_property(foe_node, "position", home, 0.5).set_ease(Tween.EASE_OUT)
	tw.tween_property(foe_node, "modulate", Color.WHITE, 0.5)
	tw.chain().tween_callback(func(): foe_node.start_idle(0.95))


# ---------------- language & ui refresh ----------------
func set_lang(l: String) -> void:
	lang = l
	set_setting("lang", l)
	apply_lang()


func apply_lang() -> void:
	mode_btn.text = t("changeMode")
	mode_lbl.text = t("tagB") if mode == "battle" else t("tagC")
	stat_labels.score.text = t("score")
	stat_labels.lives.text = t("lives")
	stat_labels.best.text = t("best")
	stat_chap_lbl.text = t("stage") if mode == "battle" else t("chapter")
	btn_submit.text = t("submit") + "  ·  Setzen"
	btn_clear.text = t("clear")
	btn_shuffle.text = t("shuffle")
	rules_btn.text = t("howto")
	rules_lbl.text = t("rules")
	me_name_lbl.text = "Setzer · " + t("you")
	for l in dict_lang_btns:
		var b: Button = dict_lang_btns[l]
		if l == lang:
			styled_btn(b, C_INK, C_PAPER, C_INK)
		else:
			styled_btn(b, Color.TRANSPARENT, C_INK, C_INK)
	update_ui()
	render_dict()


func target() -> int:
	return 1000 + (chap - 1) * 500


func update_ui() -> void:
	stat_score.text = str(score)
	stat_chap.text = str(chap)
	stat_best.text = str(max(best, score))
	stat_lives.text = str(lives) + " / 3"
	btn_hint.text = t("hint") + (" −%d HP" % HINT_HP if mode == "battle" else " −%d" % HINT_PTS)
	prog.max_value = target()
	prog.value = min(chap_score, target())
	if mode == "battle" and not foe.is_empty():
		chapinfo.text = t("stageInfo", {"c": chap, "n": foe_name() + " (" + foe_sub() + ")"})
		me_hp.max_value = pmax
		me_hp.value = php
		var ratio := float(php) / pmax
		var fill := C_OK if ratio >= 0.6 else (C_BRASS if ratio >= 0.3 else C_RUBRIC)
		me_hp.add_theme_stylebox_override("fill", box(fill, 5))
		me_hp_lbl.text = t("hp") + " " + str(php) + " / " + str(pmax)
		foe_name_lbl.text = foe_name() + "\n" + foe_sub()
		foe_hp.max_value = foe.max
		foe_hp.value = foe.hp
		foe_hp_lbl.text = t("hp") + " " + str(foe.hp) + " / " + str(foe.max)
		foe_atk_lbl.text = t("atkNext", {"a": foe.atk}) if foe.cd <= 1 else t("atkIn", {"n": foe.cd, "a": foe.atk})
	else:
		chapinfo.text = t("chapInfo", {"c": chap, "s": chap_score, "t": target()})
	update_word()


func word_of(s: Array) -> String:
	var w := ""
	for x in s:
		w += x.l
	return w


func calc(s: Array) -> int:
	var base := 0
	var mult := 1
	var inkb := 0
	for x in s:
		base += VAL[x.l]
		if x.bonus:
			mult *= x.bonus
		if x.ink:
			inkb += 1
	var n: int = min(word_of(s).length(), 12)
	return int(round(base * LMULT[n] * mult * 10)) + inkb * 50


func dmg_of(p: int) -> int:
	return max(1, int(round(p / 10.0)))


func update_word() -> void:
	var w := word_of(sel)
	var ok := is_word(w)
	word_lbl.text = w.to_upper() if sel.size() > 0 else t("tap")
	word_lbl.add_theme_color_override("font_color", C_PAPER if ok else C_MUTED)
	if ok and mode == "battle":
		var h := 0
		for x in sel:
			h += x.heal
		pts_lbl.text = str(dmg_of(calc(sel))) + " " + t("dmg") + (("  +" + str(h) + " HP") if h > 0 else "")
	elif ok:
		pts_lbl.text = "+" + str(calc(sel))
	else:
		pts_lbl.text = t("notword") if w.length() >= 3 else ""
	btn_submit.disabled = not ok or busy
	for col in grid:
		for x in col:
			if x:
				paint(x, x in sel)


# ---------------- input ----------------
func tile_at(pos: Vector2, strict: bool) -> Variant:
	var fxp := pos.x / (ts + GAP)
	var fyp := pos.y / (ts + GAP)
	var c := int(floor(fxp))
	var r := int(floor(fyp))
	if c < 0 or r < 0 or c >= COLS or r >= ROWS:
		return null
	if strict:
		var half := ts / (ts + GAP) / 2.0
		if Vector2(fxp - c - half, fyp - r - half).length() > 0.4:
			return null
	return grid[c][r]


func adj(a: Dictionary, b: Dictionary) -> bool:
	return a.id != b.id and abs(a.c - b.c) <= 1 and abs(a.r - b.r) <= 1


func _on_board_input(ev: InputEvent) -> void:
	if busy or overlay.visible:
		return
	if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT:
		if ev.pressed:
			stop_hint()
			var x = tile_at(ev.position, false)
			if x == null:
				return
			drag = {"moved": false, "start": x, "was_last": sel.size() > 0 and sel[-1] == x, "added": false}
			if not x in sel:
				if sel.is_empty() or adj(sel[-1], x):
					sel.append(x)
				else:
					sel = [x]
				drag.added = true
			update_word()
		elif not drag.is_empty():
			var d := drag
			drag = {}
			if d.moved:
				if is_word(word_of(sel)):
					submit()
				return
			if not d.added:
				var i := sel.find(d.start)
				if d.was_last:
					sel.pop_back()
				elif i >= 0:
					sel = sel.slice(0, i + 1)
				update_word()
	elif ev is InputEventMouseMotion and not drag.is_empty():
		var x = tile_at(ev.position, true)
		if x == null or sel.is_empty():
			return
		if x == sel[-1]:
			return
		if sel.size() > 1 and x == sel[-2]:
			sel.pop_back()
			drag.moved = true
			update_word()
			return
		if not x in sel and adj(sel[-1], x):
			sel.append(x)
			drag.moved = true
			update_word()


func _unhandled_input(ev: InputEvent) -> void:
	if overlay.visible or not (ev is InputEventKey) or not ev.pressed:
		return
	if ev.keycode == KEY_ENTER and not btn_submit.disabled:
		submit()
	elif ev.keycode == KEY_ESCAPE:
		sel = []
		update_word()
	elif ev.keycode == KEY_BACKSPACE and sel.size() > 0:
		sel.pop_back()
		update_word()


# ---------------- hint & shuffle ----------------
func _on_hint() -> void:
	if busy:
		return
	if mode == "battle" and php <= HINT_HP:
		toast(t("hintLow"))
		return
	if mode != "battle" and score < HINT_PTS:
		toast(t("hintPts"))
		return
	var body: String = t("cfHintB", {"n": HINT_HP}) if mode == "battle" else t("cfHintC", {"n": HINT_PTS})
	confirm_step("hint", t("cfHintT"), body, _do_hint)


# The hinted tiles keep wiggling until the player touches the board, shuffles or submits.
func stop_hint() -> void:
	for pair in hint_tweens:
		pair[0].kill()
		if is_instance_valid(pair[1]):
			pair[1].rotation = 0.0
	hint_tweens.clear()


func _do_hint() -> void:
	var path := find_word(5)
	if path.is_empty():
		toast(t("noWords"))
		shuffle(false)
		return
	if mode == "battle":
		php = max(1, php - HINT_HP)
		float_text(me_node.position + Vector2(0, -150), "−" + str(HINT_HP), Color("ff8f7a"), 30)
	else:
		score = max(0, score - HINT_PTS)
	sel = []
	update_ui()
	stop_hint()
	for x in path:
		var n: Panel = x.node
		var tw := create_tween().set_loops()
		tw.tween_property(n, "rotation", 0.15, 0.08)
		tw.tween_property(n, "rotation", -0.15, 0.16)
		tw.tween_property(n, "rotation", 0.0, 0.08)
		tw.tween_interval(0.35)
		hint_tweens.append([tw, n])
	toast(t("hintToast", {"l": path[0].l.to_upper(), "n": path.size()}))


func _on_shuffle() -> void:
	if busy:
		return
	var body: String = t("cfShuffleB") if mode == "battle" else t("cfShuffleC")
	if mode == "battle" and foe.cd <= 1:
		body += "\n\n" + t("cfShuffleWarn", {"a": foe.atk})
	confirm_step("shuffle", t("cfShuffleT"), body, func(): shuffle(true))


func shuffle(costs_turn: bool) -> void:
	if busy:
		return
	busy = true
	stop_hint()
	var all := []
	for col in grid:
		for x in col:
			all.append(x)
	all.shuffle()
	for c in COLS:
		for r in ROWS:
			grid[c][r] = all[c * ROWS + r]
	sel = []
	for c in COLS:
		for r in ROWS:
			place(grid[c][r], c, r, true)
	ensure_playable()
	if costs_turn:
		moves += 1
		if mode == "battle":
			await get_tree().create_timer(0.35).timeout
			await enemy_turn()
		else:
			tick()
			maybe_ink(0)
	busy = false
	update_ui()
	check_over()


func ensure_playable() -> void:
	var tries := 0
	while find_word(3).is_empty() and tries < 20:
		for k in 4:
			var x: Dictionary = grid[randi() % COLS][randi() % ROWS]
			if not x.ink and not x.bonus and not x.heal:
				x.l = rand_letter()
				paint(x)
		tries += 1


func find_word(min_len: int) -> Array:
	var best_p := []
	var seen := {}
	var stack_best := [best_p]
	for col in grid:
		for x in col:
			if x:
				_dfs(x, "", [], seen, stack_best)
			if stack_best[0].size() > 0 and word_of(stack_best[0]).length() >= min_len:
				return stack_best[0]
	return stack_best[0]


func _dfs(x: Dictionary, pre: String, path: Array, seen: Dictionary, out: Array) -> void:
	var w: String = pre + x.l
	if not has_prefix(w):
		return
	path.append(x)
	seen[x.id] = true
	if w.length() >= 3 and word_set.has(w):
		if out[0].is_empty() or w.length() > word_of(out[0]).length():
			out[0] = path.duplicate()
	if path.size() < 8:
		for dc in [-1, 0, 1]:
			for dr in [-1, 0, 1]:
				var c: int = x.c + dc
				var r: int = x.r + dr
				if c < 0 or r < 0 or c >= COLS or r >= ROWS:
					continue
				var u = grid[c][r]
				if u and not seen.has(u.id):
					_dfs(u, w, path, seen, out)
	path.pop_back()
	seen.erase(x.id)


# ---------------- turn flow ----------------
func submit() -> void:
	var w := word_of(sel)
	if busy or not is_word(w):
		return
	busy = true
	var pts := calc(sel)
	stop_hint()
	var used := sel.duplicate()
	sel = []
	var crit := false
	var heal := 0
	for x in used:
		if x.bonus:
			crit = true
		heal += x.heal
	score += pts
	chap_score += pts
	moves += 1
	var last: Dictionary = used[-1]
	float_text_board(last.node.position + Vector2(ts / 2, 0), "+" + str(pts))
	log_word(w, pts)
	for x in used:
		grid[x.c][x.r] = null
		x.node.queue_free()
	var reward := 3 if w.length() >= 7 else (2 if w.length() >= 5 else 0)
	refill(reward, last.c, 0.18 if used.size() <= 3 else 0.0)
	update_word()
	if mode == "battle":
		var dmg := dmg_of(pts)
		if heal > 0:
			php = min(pmax, php + heal)
		await player_attack(w, dmg, crit, heal)
		foe.hp = max(0, foe.hp - dmg)
		update_ui()
		if foe.hp <= 0:
			await foe_dies()
			busy = false
			foe_defeated()
			return
		await enemy_turn()
		busy = false
		update_ui()
		check_over()
		return
	tick()
	busy = false
	update_ui()
	if chap_score >= target():
		next_chapter()
	else:
		check_over()


func refill(reward: int, rc: int, extra_ink: float) -> void:
	for c in COLS:
		var keep := []
		for x in grid[c]:
			if x:
				keep.append(x)
		var miss := ROWS - keep.size()
		var col := []
		for i in miss:
			var x := mk_tile()
			if reward and c == rc and i == miss - 1:
				x.bonus = reward
				reward = 0
				paint(x)
			else:
				decorate(x)
			x.node.size = Vector2(ts, ts)
			x.node.position = tile_pos(c, -(miss - i))
			col.append(x)
		grid[c] = col + keep
	for c in COLS:
		for r in ROWS:
			place(grid[c][r], c, r, true)
	maybe_ink(extra_ink)
	ensure_playable()


func maybe_ink(extra: float) -> void:
	if mode == "battle":
		return
	var n := 0
	for col in grid:
		for x in col:
			if x.ink:
				n += 1
	var cap := 1 + int(chap / 2)
	var p := 0.06 + 0.04 * chap + extra
	if n < cap and moves > 1 and randf() < p:
		var cands := []
		for c in COLS:
			for r in 2:
				var x: Dictionary = grid[c][r]
				if not x.ink and not x.bonus:
					cands.append(x)
		if cands.size() > 0:
			var x: Dictionary = cands.pick_random()
			x.ink = max(4, 9 - chap)
			paint(x)


func tick() -> void:
	var lost := 0
	for col in grid:
		for x in col:
			if x.ink > 0:
				x.ink -= 1
				if x.ink <= 0:
					lost += 1
					x.ink = 0
					x.l = rand_letter()
				paint(x)
	if lost > 0:
		lives = max(0, lives - lost)
		toast(t("inkLost", {"n": lost}))


func enemy_turn() -> void:
	foe.cd -= 1
	update_ui()
	if foe.cd <= 0:
		foe.cd = foe.every
		await enemy_attack()
		php = max(0, php - foe.atk)
		toast(t("foeHits", {"n": foe_name(), "a": foe.atk}))
		update_ui()


func foe_defeated() -> void:
	var old := foe_name() + " (" + foe_sub() + ")"
	chap += 1
	php = min(pmax, php + 20)
	spawn_foe()
	update_ui()
	var st := foe_stats(chap)
	show_dialog("Sieg!", t("winB", {"o": old, "c": chap, "n": foe_name(), "h": st.hp, "a": st.atk, "e": st.every}), [[t("fight"), close_overlay, true]])


func next_chapter() -> void:
	chap += 1
	chap_score = 0
	lives = min(3, lives + 1)
	update_ui()
	show_dialog("Kapitel " + str(chap), t("chapB", {"p": chap - 1}), [[t("go"), close_overlay, true]])


func check_over() -> void:
	if (php > 0) if mode == "battle" else (lives > 0):
		return
	if score > best:
		best = score
		set_setting(best_key(), best)
	var top := {}
	for f in found:
		if top.is_empty() or f.pts > top.pts:
			top = f
	var where: String = t("reachedB", {"c": chap, "n": foe_name()}) if mode == "battle" else t("reachedC", {"c": chap})
	var body: String = t("overB", {"s": score, "where": where, "n": found.size()})
	if not top.is_empty():
		body += "\n" + t("bestW", {"w": top.w.to_upper(), "p": top.pts})
	show_dialog("Niederlage" if mode == "battle" else "Ende", body, [[t("again"), func(): pick_mode(false), true]])


# ---------------- battle effects ----------------
func float_text(pos: Vector2, text: String, col: Color, size: int = 34) -> void:
	var l := lbl(text, size, col, f_sort)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", 6)
	l.position = pos - Vector2(60, 0)
	l.size = Vector2(120, 50)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.pivot_offset = Vector2(60, 25)
	l.scale = Vector2(0.6, 0.6)
	fx.add_child(l)
	var tw := create_tween()
	tw.tween_property(l, "scale", Vector2(1.15, 1.15), 0.18)
	tw.parallel().tween_property(l, "position:y", pos.y - 20, 0.18)
	tw.tween_property(l, "position:y", pos.y - 70, 0.8)
	tw.parallel().tween_property(l, "modulate:a", 0.0, 0.8)
	tw.tween_callback(l.queue_free)


func float_text_board(pos: Vector2, text: String) -> void:
	var l := lbl(text, 32, C_BRASS, f_sort)
	l.add_theme_color_override("font_outline_color", Color.BLACK)
	l.add_theme_constant_override("outline_size", 6)
	l.position = pos - Vector2(50, 10)
	l.size = Vector2(100, 40)
	l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
	l.z_index = 10
	tiles_root.add_child(l)
	var tw := create_tween()
	tw.tween_property(l, "position:y", pos.y - 70, 0.9)
	tw.parallel().tween_property(l, "modulate:a", 0.0, 0.9)
	tw.tween_callback(l.queue_free)


func burst(pos: Vector2, colors: Array, amount: int) -> void:
	var p := CPUParticles2D.new()
	p.position = pos
	p.one_shot = true
	p.explosiveness = 1.0
	p.amount = amount
	p.lifetime = 0.8
	p.spread = 180.0
	p.direction = Vector2(0, -1)
	p.initial_velocity_min = 120.0
	p.initial_velocity_max = 260.0
	p.gravity = Vector2(0, 420)
	p.angular_velocity_min = -360
	p.angular_velocity_max = 360
	p.scale_amount_min = 5.0
	p.scale_amount_max = 10.0
	var grad := Gradient.new()
	grad.set_color(0, colors[0])
	grad.set_color(1, Color(colors[-1], 0.0))
	if colors.size() > 2:
		grad.add_point(0.5, colors[1])
	p.color_ramp = grad
	var ramp := Gradient.new()
	ramp.set_color(0, Color.WHITE)
	ramp.set_color(1, Color.WHITE)
	fx.add_child(p)
	p.emitting = true
	get_tree().create_timer(1.2).timeout.connect(p.queue_free)


func shake(node: CanvasItem, strength: float = 7.0) -> void:
	var home: Vector2 = node.position
	var tw := create_tween()
	for i in 5:
		var k := strength * (1.0 - i / 5.0)
		tw.tween_property(node, "position", home + Vector2(randf_range(-k, k), randf_range(-k / 2, k / 2)), 0.05)
	tw.tween_property(node, "position", home, 0.05)


func bezier(a: Vector2, ctrl: Vector2, b: Vector2, k: float) -> Vector2:
	return a.lerp(ctrl, k).lerp(ctrl.lerp(b, k), k)


func player_attack(word: String, dmg: int, crit: bool, heal: int) -> void:
	var a := me_node.position + Vector2(0, -70 * me_node.scale.y)
	var b := foe_node.position + Vector2(0, -60 * foe_node.scale.y)
	if heal > 0:
		burst(a, [Color("e9f7d9"), Color("a8e08a"), Color("6fbf4f")], 18)
		float_text(a + Vector2(0, -30), "+" + str(heal) + " HP", Color("a8e08a"))
	me_node.stop_idle()
	var home := me_node.position
	var lunge := create_tween()
	lunge.tween_property(me_node, "position", home + Vector2(24, 0), 0.12)
	lunge.tween_property(me_node, "rotation", 0.12, 0.08)
	lunge.tween_property(me_node, "position", home, 0.2)
	lunge.parallel().tween_property(me_node, "rotation", 0.0, 0.2)
	lunge.tween_callback(func(): me_node.start_idle(1.2))
	var letters := []
	var i := 0
	var up := word.to_upper()
	while i < up.length() and letters.size() < 8:
		if up.substr(i, 2) == "CH":
			letters.append("CH")
			i += 2
		else:
			letters.append(up[i])
			i += 1
	var last_tw: Tween
	for j in letters.size():
		var pnl := Panel.new()
		pnl.add_theme_stylebox_override("panel", box(Color("f6a24a") if crit else Color("f0cd6e"), 5, Color("8e6f2a"), 1, 8, Color(1, 0.8, 0.4, 0.7)))
		pnl.size = Vector2(36, 36)
		pnl.pivot_offset = Vector2(18, 18)
		var l := lbl(letters[j], 22 if letters[j] != "CH" else 16, C_INK, f_sort)
		l.set_anchors_preset(Control.PRESET_FULL_RECT)
		l.horizontal_alignment = HORIZONTAL_ALIGNMENT_CENTER
		l.vertical_alignment = VERTICAL_ALIGNMENT_CENTER
		pnl.add_child(l)
		pnl.modulate.a = 0
		fx.add_child(pnl)
		var start := a + Vector2(0, (j % 3 - 1) * 10)
		var ctrl := (start + b) / 2 + Vector2(0, -90)
		var tw := create_tween()
		tw.tween_interval(j * 0.06)
		tw.tween_property(pnl, "modulate:a", 1.0, 0.05)
		tw.parallel().tween_method(func(k: float): pnl.position = bezier(start, ctrl, b, k) - Vector2(18, 18); pnl.rotation = k * TAU, 0.0, 1.0, 0.42).set_trans(Tween.TRANS_SINE)
		tw.tween_callback(pnl.queue_free)
		last_tw = tw
	if last_tw:
		await last_tw.finished
	var cols_fx := [Color.WHITE, Color("ffb35a"), Color("e3742f")] if crit else [Color("f3ecdc"), Color("ffd27a"), Color("c9a24a")]
	burst(b, cols_fx, 30 if crit else 18)
	float_text(b + Vector2(0, -20), "−" + str(dmg), Color("ffb35a") if crit else Color("ffd27a"), 46 if crit else 36)
	var fh := create_tween()
	fh.tween_property(foe_node, "modulate", Color(1, 0.35, 0.35), 0.06)
	fh.tween_property(foe_node, "modulate", Color.WHITE, 0.25)
	shake(foe_node, 10.0)
	if crit:
		shake(scene, 9.0)
	await get_tree().create_timer(0.3).timeout


func enemy_attack() -> void:
	var a := me_node.position + Vector2(0, -60 * me_node.scale.y)
	var b := foe_node.position + Vector2(0, -60 * foe_node.scale.y)
	foe_node.stop_idle()
	var home := foe_node.position
	var tw := create_tween()
	tw.tween_property(foe_node, "position", home + Vector2(-28, 0), 0.15)
	tw.parallel().tween_property(foe_node, "scale", foe_node.scale * 1.08, 0.15)
	tw.tween_property(foe_node, "position", home, 0.18)
	tw.parallel().tween_property(foe_node, "scale", foe_node.scale, 0.18)
	await tw.finished
	foe_node.start_idle(0.95)
	var ball := Panel.new()
	var bs := box(Color("201d28"), 20, Color("5b5670"), 2, 10, Color(0, 0, 0, 0.8))
	ball.add_theme_stylebox_override("panel", bs)
	ball.size = Vector2(40, 40)
	fx.add_child(ball)
	var ctrl := (a + b) / 2 + Vector2(0, -100)
	var bt := create_tween()
	bt.tween_method(func(k: float): ball.position = bezier(b, ctrl, a, k) - Vector2(20, 20), 0.0, 1.0, 0.45).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_IN)
	await bt.finished
	ball.queue_free()
	burst(a, [Color("5b5670"), Color("3b3f6b"), Color("121016")], 22)
	float_text(a + Vector2(0, -20), "−" + str(foe.atk), Color("ff8f7a"), 40)
	var mh := create_tween()
	mh.tween_property(me_node, "modulate", Color(1, 0.3, 0.3), 0.06)
	mh.tween_property(me_node, "modulate", Color.WHITE, 0.35)
	shake(scene, 10.0)
	shake(tiles_root, 8.0)
	_ink_splat()
	await get_tree().create_timer(0.25).timeout


func _ink_splat() -> void:
	var holder := Control.new()
	holder.mouse_filter = Control.MOUSE_FILTER_IGNORE
	holder.z_index = 20
	tiles_root.add_child(holder)
	var bw := COLS * ts + (COLS - 1) * GAP
	for i in 6:
		var d := Panel.new()
		var r := randf_range(18, 48)
		d.add_theme_stylebox_override("panel", box(Color(0.07, 0.06, 0.09, 0.6), r))
		d.size = Vector2(r * 2, r * 2)
		d.position = Vector2(randf_range(0, bw - r * 2), randf_range(0, bw - r * 2))
		d.mouse_filter = Control.MOUSE_FILTER_IGNORE
		holder.add_child(d)
	var tw := create_tween()
	tw.tween_interval(0.6)
	tw.tween_property(holder, "modulate:a", 0.0, 0.5)
	tw.tween_callback(holder.queue_free)


func foe_dies() -> void:
	var b := foe_node.position + Vector2(0, -50 * foe_node.scale.y)
	foe_node.stop_idle()
	burst(b, [Color("f3ecdc"), Color("b9a888"), Color("1b1a1f")], 40)
	var tw := create_tween().set_parallel()
	tw.tween_property(foe_node, "rotation", 0.5, 0.6).set_ease(Tween.EASE_IN)
	tw.tween_property(foe_node, "scale", foe_node.scale * 0.3, 0.6).set_ease(Tween.EASE_IN)
	tw.tween_property(foe_node, "position:y", foe_node.position.y + 20, 0.6)
	tw.tween_property(foe_node, "modulate:a", 0.0, 0.6)
	await tw.finished


# ---------------- dialogs ----------------
func close_overlay() -> void:
	overlay.visible = false


func show_dialog(title: String, body: String, buttons: Array, extra: Array = []) -> void:
	ov_title.text = title
	ov_body.text = body
	ov_body.visible = body != ""
	for ch in ov_extra.get_children():
		ch.queue_free()
	for ch in ov_buttons.get_children():
		ch.queue_free()
	for e in extra:
		ov_extra.add_child(e)
	ov_extra.visible = extra.size() > 0
	var first: Button = null
	for spec in buttons:
		var b := btn(spec[0], spec[1])
		b.size_flags_horizontal = Control.SIZE_EXPAND_FILL
		if spec[2]:
			styled_btn(b, C_INK, C_PAPER, C_INK)
		else:
			styled_btn(b, Color.TRANSPARENT, C_INK, C_INK)
		ov_buttons.add_child(b)
		if spec[2]:
			first = b
	ov_buttons.visible = buttons.size() > 0
	overlay.visible = true
	if first:
		first.call_deferred("grab_focus")


func confirm_step(key: String, title: String, body: String, fn: Callable) -> void:
	if setting("skip_" + key, false):
		fn.call()
		return
	var cb := CheckBox.new()
	cb.text = t("dontAsk")
	cb.size_flags_horizontal = Control.SIZE_SHRINK_CENTER
	cb.add_theme_font_size_override("font_size", 20)
	var ok := func():
		if cb.button_pressed:
			set_setting("skip_" + key, true)
		close_overlay()
		fn.call()
	show_dialog(title, body, [[t("cancel"), close_overlay, false], [t("confirm"), ok, true]], [cb])


func pick_mode(cancelable: bool) -> void:
	var row := HBoxContainer.new()
	row.alignment = BoxContainer.ALIGNMENT_CENTER
	row.add_theme_constant_override("separation", 0)
	for l in I18n.LANGS:
		var b := btn(I18n.LANG_NAMES[l], func(): set_lang(l); pick_mode(cancelable))
		if l == lang:
			styled_btn(b, C_INK, C_PAPER, C_INK)
		else:
			styled_btn(b, Color.TRANSPARENT, C_INK, C_INK)
		row.add_child(b)
	var items: Array = [row]
	for m in [["classic", "Klassisch", t("modeC")], ["battle", "Kampf", t("modeB")]]:
		var b := PanelContainer.new()
		var normal := box(Color("fbf6ea"), 8, C_INK, 2)
		normal.set_content_margin_all(14)
		var hover := normal.duplicate()
		hover.bg_color = Color("fff3d6")
		hover.border_color = C_RUBRIC
		b.add_theme_stylebox_override("panel", normal)
		b.mouse_default_cursor_shape = Control.CURSOR_POINTING_HAND
		b.mouse_entered.connect(func(): b.add_theme_stylebox_override("panel", hover))
		b.mouse_exited.connect(func(): b.add_theme_stylebox_override("panel", normal))
		b.gui_input.connect(func(ev):
			if ev is InputEventMouseButton and ev.button_index == MOUSE_BUTTON_LEFT and not ev.pressed:
				new_game(m[0]))
		var v := VBoxContainer.new()
		v.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var tl := lbl(m[1], 32, C_INK, f_display)
		tl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		var dl := lbl(m[2], 19, Color("3d372f"))
		dl.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		dl.mouse_filter = Control.MOUSE_FILTER_IGNORE
		v.add_child(tl)
		v.add_child(dl)
		b.add_child(v)
		items.append(b)
	var buttons := []
	if cancelable:
		buttons.append([t("back"), close_overlay, false])
	show_dialog("Spielmodus", t("pickB"), buttons, items)


# ---------------- dictionary panel ----------------
func norm(s: String) -> String:
	return s.to_lower().replace("ß", "ss")


func tr_of(w: String) -> Dictionary:
	var g = gloss.get(w)
	if g and g[I18n.GLOSS_INDEX[lang]] != "":
		return {"text": g[I18n.GLOSS_INDEX[lang]], "user": false}
	var u: String = cfg.get_value("usertr", lang + "|" + w, "")
	if u != "":
		return {"text": u, "user": true}
	return {"text": "", "user": false}


func de_bbcode(w: String) -> Dictionary:
	var g = gloss.get(w)
	if not g:
		return {"de": w.to_upper(), "form": ""}
	var parts := []
	for x in g[0].split(" / "):
		var sp: PackedStringArray = x.split(" ", true, 1)
		if sp.size() == 2 and sp[0] in ["der", "die", "das"]:
			parts.append("[color=#b23a2b]" + sp[0] + "[/color] " + sp[1])
		else:
			parts.append(x)
	var lem: String = g[0].split(" / ")[0].split(" ")[-1]
	return {"de": " / ".join(parts), "form": w.to_upper() if norm(lem) != w else ""}


func rich(text: String, size: int, font: Font = null) -> RichTextLabel:
	var r := RichTextLabel.new()
	r.bbcode_enabled = true
	r.fit_content = true
	r.scroll_active = false
	r.text = text
	r.add_theme_color_override("default_color", C_INK)
	r.add_theme_font_size_override("normal_font_size", size)
	if font:
		r.add_theme_font_override("normal_font", font)
	r.size_flags_horizontal = Control.SIZE_EXPAND_FILL
	r.mouse_filter = Control.MOUSE_FILTER_IGNORE
	return r


func render_dict() -> void:
	for ch in recent_box.get_children():
		ch.queue_free()
	for ch in log_box.get_children():
		ch.queue_free()
	if found.is_empty():
		var e := lbl(t("dictEmpty"), 19, Color("6d6252"))
		e.autowrap_mode = TextServer.AUTOWRAP_WORD_SMART
		recent_box.add_child(e)
	else:
		var w: String = found[-1].w
		var d := de_bbcode(w)
		var tr := tr_of(w)
		if d.form != "":
			recent_box.add_child(lbl(d.form + " →", 16, Color("6d6252")))
		recent_box.add_child(rich(d.de, 32, f_sort))
		if editing == w:
			var row := HBoxContainer.new()
			row.add_theme_constant_override("separation", 6)
			var le := LineEdit.new()
			le.text = cfg.get_value("usertr", lang + "|" + w, "")
			le.placeholder_text = t("trPh", {"w": w.to_upper()})
			le.max_length = 80
			le.size_flags_horizontal = Control.SIZE_EXPAND_FILL
			var save := func():
				var v := le.text.strip_edges()
				if v != "":
					cfg.set_value("usertr", lang + "|" + w, v)
				elif cfg.has_section_key("usertr", lang + "|" + w):
					cfg.erase_section_key("usertr", lang + "|" + w)
				_save()
				editing = ""
				render_dict()
			le.text_submitted.connect(func(_s): save.call())
			row.add_child(le)
			row.add_child(styled_btn(btn(t("save"), save), C_INK, C_PAPER, C_INK))
			row.add_child(styled_btn(btn(t("cancel"), func(): editing = ""; render_dict()), Color.TRANSPARENT, C_INK, C_INK))
			recent_box.add_child(row)
			le.call_deferred("grab_focus")
		elif tr.text != "":
			var r := rich(tr.text + ((" [i][color=#6d6252](" + t("fromPlayer") + ")[/color][/i]") if tr.user else ""), 22)
			recent_box.add_child(r)
			if tr.user:
				var eb := styled_btn(btn(t("edit"), func(): editing = w; render_dict()), Color.TRANSPARENT, C_RUBRIC, C_RUBRIC)
				eb.add_theme_font_size_override("font_size", 17)
				eb.size_flags_horizontal = Control.SIZE_SHRINK_BEGIN
				recent_box.add_child(eb)
		else:
			recent_box.add_child(lbl(t("noTr"), 18, Color("6d6252")))
			var row2 := HBoxContainer.new()
			row2.add_theme_constant_override("separation", 8)
			var ab := styled_btn(btn(t("addTr"), func(): editing = w; render_dict()), Color.TRANSPARENT, C_RUBRIC, C_RUBRIC)
			ab.add_theme_font_size_override("font_size", 18)
			row2.add_child(ab)
			var wb := styled_btn(btn(t("wiki"), func(): OS.shell_open("https://de.wiktionary.org/wiki/Spezial:Suche?search=" + w.uri_encode())), Color.TRANSPARENT, Color("6d6252"), Color("b9a888"))
			wb.add_theme_font_size_override("font_size", 18)
			row2.add_child(wb)
			recent_box.add_child(row2)
	for i in range(found.size() - 1, -1, -1):
		var f: Dictionary = found[i]
		var d := de_bbcode(f.w)
		var tr := tr_of(f.w)
		var v := VBoxContainer.new()
		v.add_theme_constant_override("separation", 0)
		var h := HBoxContainer.new()
		var head: String = (("[color=#6d6252]" + d.form + " → [/color]") if d.form != "" else "") + d.de
		h.add_child(rich(head, 22, f_sort))
		h.add_child(lbl("+" + str(f.pts), 20, Color("6d6252"), f_sort))
		v.add_child(h)
		if tr.text != "":
			v.add_child(rich(tr.text + ((" [i][color=#6d6252](" + t("fromPlayer") + ")[/color][/i]") if tr.user else ""), 18))
		var sep := ColorRect.new()
		sep.color = Color(C_INK, 0.15)
		sep.custom_minimum_size.y = 1
		v.add_child(sep)
		log_box.add_child(v)


func log_word(w: String, pts: int) -> void:
	found.append({"w": w, "pts": pts})
	editing = ""
	render_dict()


func toast(m: String) -> void:
	toast_lbl.text = m
	toast_panel.visible = true
	toast_panel.modulate.a = 1.0
	await get_tree().process_frame
	var vs := get_viewport_rect().size
	toast_panel.size = Vector2(min(560.0, vs.x - 40.0), 0)
	toast_panel.reset_size()
	toast_panel.position = Vector2((vs.x - toast_panel.size.x) / 2, vs.y - toast_panel.size.y - 30)
	if toast_tween:
		toast_tween.kill()
	toast_tween = create_tween()
	toast_tween.tween_interval(2.6)
	toast_tween.tween_property(toast_panel, "modulate:a", 0.0, 0.3)
	toast_tween.tween_callback(func(): toast_panel.visible = false)
