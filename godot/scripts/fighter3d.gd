extends Node3D
## A character built from primitive meshes. Feet sit at the origin, the body is about 2 units tall
## and the front faces +Z. kind: "me" for the typesetter hero, otherwise an enemy body
## ("blob", "bug", "horns", "stripes", "square", "ghost", "crown", "dragon").

var kind := "me"
var body_color := Color("3b3f6b")
var rig: Node3D
var parts := []  # [MeshInstance3D, StandardMaterial3D, base Color]
var tint := Color.WHITE
var face: Node3D
var hurt_face: Node3D
var _hurt_tw: Tween
var _mats := {}


func setup(k: String, c: Color = Color.WHITE) -> void:
	kind = k
	body_color = c
	if rig:
		rig.queue_free()
	parts.clear()
	_mats.clear()
	face = null
	hurt_face = null
	rig = Node3D.new()
	add_child(rig)
	if kind == "me":
		_build_me()
	else:
		_build_enemy()
	tint = Color.WHITE
	set_tint(Color.WHITE, true)
	if hurt_face:
		hurt_face.visible = false


## Flinch: lean away from the hit (dir = +1 pushes towards +X), squash, wince face. strength 0..1.5.
func hurt(dir: float, strength: float = 1.0) -> void:
	if not rig:
		return
	if _hurt_tw:
		_hurt_tw.kill()
	rig.rotation = Vector3.ZERO
	rig.position = Vector3.ZERO
	rig.scale = Vector3.ONE
	if face and hurt_face:
		face.visible = false
		hurt_face.visible = true
	var lean := -dir * (0.35 + 0.2 * strength)
	_hurt_tw = create_tween()
	_hurt_tw.tween_property(rig, "rotation:z", lean, 0.07).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	_hurt_tw.parallel().tween_property(rig, "rotation:x", -0.25 * strength, 0.07)
	_hurt_tw.parallel().tween_property(rig, "position:x", dir * 0.3 * strength, 0.07)
	_hurt_tw.parallel().tween_property(rig, "scale", Vector3(1.12, 0.86, 1.12), 0.07)
	_hurt_tw.tween_property(rig, "scale", Vector3(0.94, 1.06, 0.94), 0.1)
	# wobble back upright
	_hurt_tw.tween_property(rig, "rotation:z", -lean * 0.35, 0.16).set_trans(Tween.TRANS_SINE)
	_hurt_tw.parallel().tween_property(rig, "rotation:x", 0.06, 0.16)
	_hurt_tw.parallel().tween_property(rig, "position:x", 0.0, 0.3)
	_hurt_tw.parallel().tween_property(rig, "scale", Vector3.ONE, 0.2)
	_hurt_tw.tween_property(rig, "rotation:z", lean * 0.12, 0.14).set_trans(Tween.TRANS_SINE)
	_hurt_tw.parallel().tween_property(rig, "rotation:x", 0.0, 0.14)
	_hurt_tw.tween_property(rig, "rotation:z", 0.0, 0.14).set_trans(Tween.TRANS_SINE)
	_hurt_tw.tween_interval(0.25 + 0.2 * strength)
	_hurt_tw.tween_callback(func():
		if face and hurt_face:
			face.visible = true
			hurt_face.visible = false)


## Short wind-up used before attacking: crouch then stretch.
func windup() -> void:
	if not rig:
		return
	var tw := create_tween()
	tw.tween_property(rig, "scale", Vector3(1.1, 0.88, 1.1), 0.09)
	tw.tween_property(rig, "scale", Vector3(0.92, 1.12, 0.92), 0.08)
	tw.tween_property(rig, "scale", Vector3.ONE, 0.15)


## Squeezed ">  <" eyes and an open "ouch" mouth.
func _make_hurt_face(parent: Node3D, y: float, z: float, spread: float, size: float, mouth_y: float) -> void:
	hurt_face = Node3D.new()
	hurt_face.visible = false
	parent.add_child(hurt_face)
	var ink := Color("1b1a1f")
	for sx in [-spread, spread]:
		var side := -1.0 if sx < 0 else 1.0
		for up in [1.0, -1.0]:
			add(cube(size * 1.5, size * 0.32, size * 0.3), ink, Vector3(sx, y + up * size * 0.32, z + size * 1.0), Vector3(0, 0, up * side * 28), Vector3.ONE, hurt_face)
	add(sphere(size * 0.9), Color("3a0f0c"), Vector3(0, mouth_y, z + size * 0.5), Vector3.ZERO, Vector3(1.1, 0.85, 0.45), hurt_face, 0.3)


## Multiplies every part's colour by c; alpha below 1 switches the materials to transparent.
func set_tint(c: Color, force: bool = false) -> void:
	if not force and c.is_equal_approx(tint):
		return
	tint = c
	var see_through := c.a < 0.995
	for pr in parts:
		var m: StandardMaterial3D = pr[1]
		var base: Color = pr[2]
		m.albedo_color = Color(base.r * c.r, base.g * c.g, base.b * c.b, base.a * c.a)
		m.transparency = BaseMaterial3D.TRANSPARENCY_ALPHA if (see_through or base.a < 1.0) else BaseMaterial3D.TRANSPARENCY_DISABLED
		m.emission_enabled = c.g < 0.6 and c.r > 0.9
		if m.emission_enabled:
			m.emission = Color(0.7, 0.05, 0.02)
			m.emission_energy_multiplier = 0.6


func mat(c: Color, rough: float = 0.65, metal: float = 0.0) -> StandardMaterial3D:
	var m := StandardMaterial3D.new()
	m.albedo_color = c
	m.roughness = rough
	m.metallic = metal
	m.rim_enabled = true
	m.rim = 0.25
	m.rim_tint = 0.4
	return m


func add(mesh: Mesh, c: Color, pos: Vector3, rot_deg: Vector3 = Vector3.ZERO, scl: Vector3 = Vector3.ONE, parent: Node3D = null, rough: float = 0.65, metal: float = 0.0) -> MeshInstance3D:
	var mi := MeshInstance3D.new()
	mi.mesh = mesh
	var m := mat(c, rough, metal)
	mi.material_override = m
	mi.position = pos
	mi.rotation_degrees = rot_deg
	mi.scale = scl
	(parent if parent else rig).add_child(mi)
	parts.append([mi, m, c])
	return mi


func sphere(r: float) -> SphereMesh:
	var s := SphereMesh.new()
	s.radius = r
	s.height = r * 2.0
	s.radial_segments = 24
	s.rings = 12
	return s


func capsule(r: float, h: float) -> CapsuleMesh:
	var c := CapsuleMesh.new()
	c.radius = r
	c.height = h
	c.radial_segments = 20
	c.rings = 6
	return c


func cyl(top: float, bottom: float, h: float, seg: int = 20) -> CylinderMesh:
	var c := CylinderMesh.new()
	c.top_radius = top
	c.bottom_radius = bottom
	c.height = h
	c.radial_segments = seg
	c.rings = 1
	return c


func cube(x: float, y: float, z: float) -> BoxMesh:
	var b := BoxMesh.new()
	b.size = Vector3(x, y, z)
	return b


func prism(x: float, y: float, z: float) -> PrismMesh:
	var p := PrismMesh.new()
	p.size = Vector3(x, y, z)
	return p


func _build_me() -> void:
	var skin := Color("e8b88f")
	var coat := Color("3d5a73")
	var cream := Color("efe6d2")
	var ink := Color("1b1a1f")
	# legs and shoes
	for sx in [-0.17, 0.17]:
		add(cyl(0.11, 0.12, 0.5), Color("2b2e38"), Vector3(sx, 0.3, 0))
		add(cube(0.22, 0.12, 0.34), Color("3a2414"), Vector3(sx, 0.06, 0.06), Vector3.ZERO, Vector3.ONE, null, 0.4)
	# coat and apron
	add(cyl(0.3, 0.42, 0.78), coat, Vector3(0, 0.92, 0))
	add(cube(0.5, 0.66, 0.06), cream, Vector3(0, 0.84, 0.36), Vector3(-8, 0, 0))
	add(cube(0.18, 0.12, 0.03), Color("d9cdb2"), Vector3(0, 0.72, 0.4), Vector3(-8, 0, 0))
	# head, hair, nose, ears
	var head := Node3D.new()
	head.position = Vector3(0, 1.58, 0)
	rig.add_child(head)
	add(sphere(0.33), skin, Vector3.ZERO, Vector3.ZERO, Vector3.ONE, head)
	add(sphere(0.34), Color("5a3b26"), Vector3(0, 0.08, -0.06), Vector3.ZERO, Vector3(1.0, 0.75, 0.95), head)
	add(sphere(0.07), Color("dc9f78"), Vector3(0, -0.02, 0.32), Vector3.ZERO, Vector3.ONE, head)
	for sx in [-0.32, 0.32]:
		add(sphere(0.07), skin, Vector3(sx, 0, 0), Vector3.ZERO, Vector3(0.6, 1, 1), head)
	# eyes, cheeks, smile
	face = Node3D.new()
	head.add_child(face)
	for sx in [-0.12, 0.12]:
		add(sphere(0.055), Color.WHITE, Vector3(sx, 0.06, 0.29), Vector3.ZERO, Vector3.ONE, face, 0.2)
		add(sphere(0.032), ink, Vector3(sx, 0.06, 0.335), Vector3.ZERO, Vector3.ONE, face, 0.2)
		add(sphere(0.06), Color(0.93, 0.58, 0.5), Vector3(sx * 1.6, -0.08, 0.25), Vector3.ZERO, Vector3(1, 0.6, 0.4), head)
	var smile := TorusMesh.new()
	smile.inner_radius = 0.07
	smile.outer_radius = 0.09
	add(smile, Color("7a2f22"), Vector3(0, -0.13, 0.29), Vector3(80, 0, 0), Vector3(1, 1, 0.5), face)
	_make_hurt_face(head, 0.06, 0.27, 0.12, 0.06, -0.14)
	# folded paper printer's hat
	add(prism(0.82, 0.46, 0.42), Color("f6f0e2"), Vector3(0, 0.4, -0.02), Vector3(-6, 0, 0), Vector3.ONE, head, 0.9)
	add(cube(0.82, 0.08, 0.06), Color("dcd2bb"), Vector3(0, 0.2, 0.2), Vector3.ZERO, Vector3.ONE, head, 0.9)
	# arms
	add(capsule(0.09, 0.55), coat, Vector3(-0.42, 1.0, 0.04), Vector3(0, 0, -14))
	add(sphere(0.1), skin, Vector3(-0.49, 0.72, 0.08))
	add(capsule(0.09, 0.52), coat, Vector3(0.4, 1.06, 0.2), Vector3(-60, 0, 18))
	add(sphere(0.1), skin, Vector3(0.48, 0.94, 0.42))
	# composing stick with brass sorts
	add(cube(0.56, 0.08, 0.14), Color("a9b2b7"), Vector3(0.62, 0.98, 0.45), Vector3(0, 0, 8), Vector3.ONE, null, 0.25, 0.8)
	for i in 3:
		add(cube(0.08, 0.13, 0.09), Color("c9a24a"), Vector3(0.5 + i * 0.11, 1.08 + i * 0.015, 0.45), Vector3(0, 0, 8), Vector3.ONE, null, 0.3, 0.9)


func _eyes(y: float, z: float, spread: float, size: float) -> void:
	var ink := Color("1b1a1f")
	face = Node3D.new()
	rig.add_child(face)
	_make_hurt_face(rig, y, z, spread, size, y - size * 2.4)
	for sx in [-spread, spread]:
		add(sphere(size), Color("f6f0e2"), Vector3(sx, y, z), Vector3.ZERO, Vector3.ONE, face, 0.2)
		add(sphere(size * 0.5), ink, Vector3(sx * 0.92, y - size * 0.15, z + size * 0.72), Vector3.ZERO, Vector3.ONE, face, 0.1)
		add(cube(size * 2.0, size * 0.35, size * 0.4), ink, Vector3(sx * 1.05, y + size * 1.15, z + size * 0.5), Vector3(0, 0, 22 if sx < 0 else -22), Vector3.ONE, face)
	var frown := TorusMesh.new()
	frown.inner_radius = size * 0.9
	frown.outer_radius = size * 1.25
	add(frown, ink, Vector3(0, y - size * 2.4, z - 0.02), Vector3(80, 0, 0), Vector3(1.2, 1, 0.5), face)


func _build_enemy() -> void:
	var c := body_color
	var dark := Color("2a1d15")
	var white := Color("f3ecdc")
	match kind:
		"square":
			add(cube(0.42, 0.5, 0.42), c.darkened(0.15), Vector3(-0.3, 0.25, 0), Vector3.ZERO, Vector3.ONE, null, 0.8, 0.4)
			add(cube(0.42, 0.5, 0.42), c.darkened(0.15), Vector3(0.3, 0.25, 0), Vector3.ZERO, Vector3.ONE, null, 0.8, 0.4)
			add(cube(1.25, 1.2, 0.9), c, Vector3(0, 1.1, 0), Vector3.ZERO, Vector3.ONE, null, 0.7, 0.5)
			for sx in [-0.8, 0.8]:
				add(cube(0.3, 0.9, 0.36), c.darkened(0.1), Vector3(sx, 0.95, 0), Vector3(0, 0, -8 if sx < 0 else 8), Vector3.ONE, null, 0.7, 0.5)
			for p in [Vector3(-0.5, 1.6, 0.46), Vector3(0.5, 1.6, 0.46), Vector3(-0.5, 0.6, 0.46), Vector3(0.5, 0.6, 0.46)]:
				add(sphere(0.05), Color("c9a24a"), p, Vector3.ZERO, Vector3.ONE, null, 0.3, 0.9)
			add(cube(0.5, 0.05, 0.02), Color("5e3218"), Vector3(-0.2, 0.9, 0.46), Vector3(0, 0, 12))
			_eyes(1.35, 0.42, 0.25, 0.12)
		"ghost":
			add(sphere(0.62), c, Vector3(0, 1.35, 0), Vector3.ZERO, Vector3(1, 1.05, 0.9), null, 0.4)
			add(cyl(0.62, 0.72, 0.95), c, Vector3(0, 0.82, 0), Vector3.ZERO, Vector3(1, 1, 0.9), null, 0.4)
			for i in 6:
				var a := TAU * i / 6.0
				add(cyl(0.13, 0.0, 0.32), c, Vector3(cos(a) * 0.55, 0.26, sin(a) * 0.5), Vector3(180, 0, 0), Vector3.ONE, null, 0.4)
			for sx in [-0.85, 0.85]:
				add(capsule(0.11, 0.5), c, Vector3(sx, 1.1, 0.15), Vector3(-30, 0, -50 if sx < 0 else 50), Vector3.ONE, null, 0.4)
			_eyes(1.42, 0.52, 0.22, 0.13)
		"bug":
			add(sphere(0.62), c, Vector3(0, 0.82, -0.1), Vector3.ZERO, Vector3(1.05, 0.85, 1.25), null, 0.35)
			add(sphere(0.42), c.darkened(0.2), Vector3(0, 1.25, 0.35), Vector3.ZERO, Vector3.ONE, null, 0.35)
			add(cube(0.03, 0.9, 1.2), c.darkened(0.45), Vector3(0, 0.95, -0.15), Vector3(-12, 0, 0), Vector3(1, 0.6, 0.9))
			for side in [-1.0, 1.0]:
				for i in 3:
					var z := -0.35 + i * 0.35
					add(cyl(0.04, 0.03, 0.75), c.darkened(0.35), Vector3(side * 0.72, 0.4, z), Vector3(0, 0, side * -55))
				add(cyl(0.025, 0.02, 0.6), c.darkened(0.35), Vector3(side * 0.2, 1.75, 0.5), Vector3(20, 0, side * -25))
				add(sphere(0.06), dark, Vector3(side * 0.33, 2.02, 0.6))
			_eyes(1.32, 0.68, 0.17, 0.11)
		"dragon":
			add(capsule(0.2, 0.7), c.darkened(0.2), Vector3(0, 0.6, -0.75), Vector3(-70, 0, 0), Vector3.ONE, null, 0.5, 0.4)
			add(sphere(0.78), c, Vector3(0, 1.05, 0), Vector3.ZERO, Vector3(1, 1, 0.95), null, 0.5, 0.45)
			add(sphere(0.5), c.lightened(0.15), Vector3(0, 0.85, 0.4), Vector3.ZERO, Vector3(1, 1, 0.6), null, 0.6, 0.3)
			for side in [-1.0, 1.0]:
				add(prism(1.1, 0.9, 0.04), Color("4a5054"), Vector3(side * 0.95, 1.55, -0.3), Vector3(10, side * 25, side * -35), Vector3.ONE, null, 0.6, 0.4)
				add(cyl(0.0, 0.1, 0.4), dark, Vector3(side * 0.42, 1.85, 0), Vector3(0, 0, side * -25))
				add(cube(0.24, 0.3, 0.32), c.darkened(0.2), Vector3(side * 0.42, 0.15, 0.1), Vector3.ZERO, Vector3.ONE, null, 0.5, 0.4)
			for i in 5:
				add(cyl(0.0, 0.04, 0.1), white, Vector3(-0.2 + i * 0.1, 0.72, 0.72), Vector3(180, 0, 0))
			_eyes(1.32, 0.66, 0.24, 0.13)
		_:
			# blob body (Tintenklecks, Druckfehlerteufel, Papiertiger, Zensor)
			add(sphere(0.75), c, Vector3(0, 0.88, 0), Vector3.ZERO, Vector3(1.05, 1.1, 0.95), null, 0.25 if kind == "blob" else 0.6)
			if kind == "blob":
				for d in [Vector3(0.82, 0.18, 0.2), Vector3(-0.7, 0.12, 0.45), Vector3(0.3, 0.1, 0.8), Vector3(-0.25, 0.08, -0.85)]:
					add(sphere(0.13), c, d, Vector3.ZERO, Vector3(1, 0.5, 1), null, 0.25)
				add(cyl(0.95, 0.95, 0.04), c, Vector3(0, 0.02, 0), Vector3.ZERO, Vector3(1, 1, 0.9), null, 0.15)
			else:
				for sx in [-0.3, 0.3]:
					add(cube(0.24, 0.24, 0.3), c.darkened(0.25), Vector3(sx, 0.12, 0.05))
			_eyes(1.05, 0.68, 0.24, 0.14)
	if kind == "horns":
		for side in [-1.0, 1.0]:
			add(cyl(0.0, 0.13, 0.55), dark, Vector3(side * 0.42, 1.78, 0), Vector3(0, 0, side * -28))
		add(cyl(0.0, 0.05, 0.4), dark, Vector3(0.0, 0.4, -0.8), Vector3(-60, 0, 0))
	if kind == "stripes":
		for i in 5:
			var y := 0.45 + i * 0.22
			add(cube(0.08, 0.1, 0.9), dark, Vector3(-0.72 + abs(i - 2) * 0.05, y, 0), Vector3(0, 0, 10))
			add(cube(0.08, 0.1, 0.9), dark, Vector3(0.72 - abs(i - 2) * 0.05, y, 0), Vector3(0, 0, -10))
		for side in [-1.0, 1.0]:
			add(cyl(0.0, 0.14, 0.26), c, Vector3(side * 0.42, 1.78, 0), Vector3(0, 0, side * -20))
	if kind == "crown":
		add(cyl(0.38, 0.4, 0.14), Color("c9a24a"), Vector3(0, 1.76, 0), Vector3.ZERO, Vector3.ONE, null, 0.25, 0.9)
		for i in 5:
			var a := TAU * i / 5.0 + PI / 2
			add(cyl(0.0, 0.08, 0.24), Color("c9a24a"), Vector3(cos(a) * 0.33, 1.94, sin(a) * 0.33), Vector3.ZERO, Vector3.ONE, null, 0.25, 0.9)
		add(sphere(0.06), Color("b23a2b"), Vector3(0, 1.78, 0.4), Vector3.ZERO, Vector3.ONE, null, 0.1)
		add(cube(0.7, 0.14, 0.1), Color("111014"), Vector3(0, 0.62, 0.72), Vector3(-10, 0, 0))
