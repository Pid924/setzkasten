extends Node
## Sound effects synthesised in code at startup (no audio files). play("name", pitch, volume_db).

const SR := 22050
var sounds := {}
var players: Array[AudioStreamPlayer] = []
var muted := false
var _next := 0
var _rng := RandomNumberGenerator.new()


func _ready() -> void:
	_rng.seed = 924
	for i in 10:
		var p := AudioStreamPlayer.new()
		add_child(p)
		players.append(p)
	_make_all()


func play(name: String, pitch: float = 1.0, vol_db: float = 0.0) -> void:
	if muted or not sounds.has(name):
		return
	var p := players[_next]
	_next = (_next + 1) % players.size()
	p.stream = sounds[name]
	p.pitch_scale = pitch
	p.volume_db = vol_db
	p.play()


func _wav(buf: PackedFloat32Array) -> AudioStreamWAV:
	var bytes := PackedByteArray()
	bytes.resize(buf.size() * 2)
	var peak := 0.001
	for v in buf:
		peak = max(peak, abs(v))
	var g := 0.85 / peak if peak > 0.85 else 1.0
	for i in buf.size():
		bytes.encode_s16(i * 2, int(clamp(buf[i] * g, -1.0, 1.0) * 32000.0))
	var w := AudioStreamWAV.new()
	w.format = AudioStreamWAV.FORMAT_16_BITS
	w.mix_rate = SR
	w.stereo = false
	w.data = bytes
	return w


func _buf(dur: float) -> PackedFloat32Array:
	var b := PackedFloat32Array()
	b.resize(int(dur * SR))
	return b


## Adds a sine tone sweeping from f0 to f1 with an exponential decay (k per second).
func _tone(b: PackedFloat32Array, start: float, dur: float, f0: float, f1: float, amp: float, k: float, attack: float = 0.004, shape: String = "sine") -> void:
	var s0 := int(start * SR)
	var n := int(dur * SR)
	var ph := 0.0
	for i in n:
		if s0 + i >= b.size():
			break
		var t := float(i) / SR
		var f := f0 + (f1 - f0) * (t / dur)
		ph += TAU * f / SR
		var v := sin(ph)
		if shape == "tri":
			v = asin(v) * 0.6366
		elif shape == "square":
			v = clamp(v * 3.0, -1.0, 1.0)
		var env: float = min(1.0, t / attack) * exp(-k * t)
		b[s0 + i] += v * amp * env


## Adds low-passed noise. cut0/cut1 are filter coefficients (0..1, higher = brighter).
func _noise(b: PackedFloat32Array, start: float, dur: float, amp: float, k: float, cut0: float, cut1: float, attack: float = 0.002) -> void:
	var s0 := int(start * SR)
	var n := int(dur * SR)
	var y := 0.0
	for i in n:
		if s0 + i >= b.size():
			break
		var t := float(i) / SR
		var c: float = lerp(cut0, cut1, t / dur)
		y += c * (_rng.randf_range(-1.0, 1.0) - y)
		var env: float = min(1.0, t / attack) * exp(-k * t)
		b[s0 + i] += y * amp * env


func _make_all() -> void:
	var b := _buf(0.09)
	_noise(b, 0, 0.05, 0.6, 90, 0.7, 0.4)
	_tone(b, 0, 0.09, 1100, 900, 0.5, 60)
	sounds.pick = _wav(b)

	b = _buf(0.08)
	_noise(b, 0, 0.04, 0.5, 120, 0.5, 0.3)
	_tone(b, 0, 0.08, 620, 520, 0.35, 70)
	sounds.tap = _wav(b)

	b = _buf(0.3)
	_tone(b, 0, 0.12, 150, 140, 0.5, 8, 0.004, "square")
	_tone(b, 0.14, 0.15, 120, 110, 0.5, 8, 0.004, "square")
	sounds.bad = _wav(b)

	b = _buf(0.4)
	_noise(b, 0, 0.4, 0.7, 6, 0.05, 0.5, 0.15)
	sounds.whoosh = _wav(b)

	b = _buf(0.25)
	_tone(b, 0, 0.25, 170, 55, 0.9, 16)
	_noise(b, 0, 0.06, 0.5, 60, 0.6, 0.2)
	sounds.hit_l = _wav(b)

	b = _buf(0.6)
	for f in [523.0, 1231.0, 1897.0, 2650.0]:
		_tone(b, 0, 0.6, f, f * 0.995, 0.25, 7)
	_tone(b, 0, 0.2, 200, 70, 0.7, 14)
	_noise(b, 0, 0.05, 0.5, 70, 0.8, 0.4)
	sounds.hit_m = _wav(b)

	b = _buf(0.9)
	_tone(b, 0, 0.9, 95, 32, 1.0, 4.5)
	_noise(b, 0, 0.8, 0.9, 5, 0.25, 0.03)
	_noise(b, 0, 0.04, 0.6, 50, 0.9, 0.5)
	for i in b.size():
		b[i] = tanh(b[i] * 1.8)
	sounds.hit_h = _wav(b)

	b = _buf(0.9)
	_tone(b, 0, 0.9, 1760, 1760, 0.4, 4)
	_tone(b, 0, 0.9, 2637, 2637, 0.3, 5)
	_tone(b, 0.05, 0.85, 3520, 3520, 0.2, 6)
	sounds.ring = _wav(b)

	b = _buf(0.35)
	_noise(b, 0, 0.3, 0.9, 14, 0.35, 0.05)
	_tone(b, 0, 0.15, 420, 90, 0.5, 18)
	sounds.ink = _wav(b)

	b = _buf(0.3)
	var ph := 0.0
	for i in b.size():
		var t := float(i) / SR
		var f := 300.0 - 140.0 * t / 0.3 + sin(t * 60.0) * 12.0
		ph += TAU * f / SR
		var v := sin(ph) + 0.5 * sin(ph * 2.0) + 0.3 * sin(ph * 3.0)
		b[i] = v * 0.4 * min(1.0, t / 0.02) * exp(-7.0 * t)
	sounds.hurt = _wav(b)

	b = _buf(0.3)
	_tone(b, 0, 0.3, 240, 120, 0.6, 9, 0.01, "tri")
	_noise(b, 0, 0.08, 0.3, 40, 0.4, 0.2)
	sounds.grunt = _wav(b)

	b = _buf(0.5)
	var notes := [880.0, 1108.7, 1318.5, 1760.0]
	for i in notes.size():
		_tone(b, i * 0.06, 0.3, notes[i], notes[i], 0.35, 9)
	sounds.heal = _wav(b)

	b = _buf(1.1)
	var jingle := [523.25, 659.25, 783.99, 1046.5]
	for i in jingle.size():
		_tone(b, i * 0.12, 0.7 if i == 3 else 0.2, jingle[i], jingle[i], 0.45, 4 if i == 3 else 9, 0.005, "tri")
	sounds.win = _wav(b)

	b = _buf(1.3)
	var sad := [392.0, 329.6, 261.6, 196.0]
	for i in sad.size():
		_tone(b, i * 0.25, 0.6, sad[i], sad[i] * 0.98, 0.45, 3, 0.01, "tri")
	sounds.lose = _wav(b)

	b = _buf(0.5)
	for i in 9:
		var at := i * 0.045 + _rng.randf_range(0, 0.02)
		_noise(b, at, 0.03, 0.5, 120, 0.7, 0.5)
		_tone(b, at, 0.04, _rng.randf_range(700, 1300), 600, 0.25, 80)
	sounds.shuffle = _wav(b)

	b = _buf(0.8)
	_tone(b, 0, 0.8, 1318.5, 1318.5, 0.4, 5)
	_tone(b, 0.08, 0.7, 1975.5, 1975.5, 0.3, 6)
	sounds.hint = _wav(b)

	b = _buf(0.5)
	_tone(b, 0, 0.5, 1500, 350, 0.35, 1.5, 0.05)
	sounds.drop = _wav(b)

	b = _buf(0.45)
	_noise(b, 0, 0.45, 0.6, 2, 0.2, 0.35, 0.05)
	for i in b.size():
		b[i] *= 0.5 + 0.5 * sin(TAU * 22.0 * i / SR)
	sounds.spin = _wav(b)

	b = _buf(0.25)
	_noise(b, 0, 0.2, 0.5, 20, 0.15, 0.6, 0.08)
	sounds.throw = _wav(b)

	# tier 3: a rattle of small lead pieces
	b = _buf(0.85)
	for i in 14:
		var at2 := i * 0.05 + _rng.randf_range(0, 0.02)
		_noise(b, at2, 0.04, 0.55, 90, 0.8, 0.5)
		_tone(b, at2, 0.07, _rng.randf_range(1500, 2600), 1200, 0.3, 45)
		_tone(b, at2, 0.08, 220, 120, 0.3, 35)
	sounds.hail = _wav(b)

	# tier 4: an iron press slamming shut
	b = _buf(1.2)
	_tone(b, 0, 1.2, 70, 28, 1.0, 3.5)
	_noise(b, 0, 0.5, 1.0, 9, 0.5, 0.04)
	for f in [311.0, 466.0, 733.0, 1108.0]:
		_tone(b, 0, 1.0, f, f * 0.99, 0.22, 5, 0.002, "tri")
	_noise(b, 0, 0.03, 0.9, 80, 0.95, 0.6)
	for i in b.size():
		b[i] = tanh(b[i] * 2.0)
	sounds.slam = _wav(b)

	# tier 5: rising charge, then a thunder crack with a long rumble
	b = _buf(0.65)
	_tone(b, 0, 0.65, 220, 1500, 0.4, -2.5, 0.2)
	_tone(b, 0, 0.65, 330, 2250, 0.25, -2.5, 0.2)
	_noise(b, 0, 0.65, 0.3, -2.0, 0.1, 0.7, 0.3)
	sounds.charge = _wav(b)

	b = _buf(1.9)
	_noise(b, 0, 0.12, 1.2, 25, 1.0, 0.7, 0.001)
	_noise(b, 0.02, 1.85, 1.0, 2.2, 0.3, 0.015)
	_tone(b, 0, 1.6, 60, 24, 1.0, 2.5)
	_tone(b, 0, 0.3, 900, 120, 0.5, 14)
	for i in b.size():
		var tt := float(i) / SR
		b[i] = tanh(b[i] * 2.2 * (1.0 + 0.3 * sin(tt * 37.0)))
	sounds.thunder = _wav(b)
