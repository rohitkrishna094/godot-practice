extends RefCounted

const SIZE := 32

static func make_noise(x: int, y: int, seed_val: int) -> float:
	var h = (x * 374761393 + y * 668265263 + seed_val) % 2147483647
	h = (h ^ (h >> 13)) * 1274126177
	return float(h & 0x7fffffff) / 1073741824.0 - 1.0

static func fbm(x: int, y: int, octaves: int = 3) -> float:
	var v := 0.0
	var amp := 1.0
	var freq := 1
	for _i in range(octaves):
		v += make_noise(x * freq, y * freq, 12345 + _i * 1000) * amp
		amp *= 0.5
		freq *= 2
	return v / (2.0 - pow(0.5, octaves - 1))

static func lerp_color(a: Color, b: Color, t: float) -> Color:
	return Color(a.r + (b.r - a.r) * t, a.g + (b.g - a.g) * t, a.b + (b.b - a.b) * t, a.a + (b.a - a.a) * t)

static func set_pixel(img: Image, x: int, y: int, c: Color):
	img.set_pixel(x, y, c)

static func solid(c: Color) -> Image:
	var img = Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	img.fill(c)
	return img

static func noise_texture(base: Color, variation: Color, seed: int = 42, strength: float = 0.15) -> Image:
	var img = Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	for y in range(SIZE):
		for x in range(SIZE):
			var n = fbm(x, y, 2) * strength
			var c = Color(base.r + n, base.g + n, base.b + n, base.a)
			set_pixel(img, x, y, c)
	return img

static func four_color_noise(
	xx: int, yy: int, c0: Color, c1: Color, c2: Color, c3: Color
) -> Image:
	var img = Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	for y in range(SIZE):
		for x in range(SIZE):
			var n = fbm(x + xx, y + yy, 3)
			var t = n * 0.5 + 0.5
			var c: Color
			if t < 0.25:
				c = lerp_color(c0, c1, t / 0.25)
			elif t < 0.5:
				c = lerp_color(c1, c2, (t - 0.25) / 0.25)
			elif t < 0.75:
				c = lerp_color(c2, c3, (t - 0.5) / 0.25)
			else:
				c = lerp_color(c3, c2, (t - 0.75) / 0.25)
			set_pixel(img, x, y, c)
	return img

static func brick_pattern(base: Color, mortar: Color, brick_w: int = 8, brick_h: int = 6) -> Image:
	var img = Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	for y in range(SIZE):
		for x in range(SIZE):
			var row = y / brick_h
			var col = x / brick_w
			var offset = (row % 2) * (brick_w / 2)
			var in_mortar = false
			if y % brick_h < 1:
				in_mortar = true
			elif (x + offset) % brick_w < 1:
				in_mortar = true
			var c = mortar if in_mortar else base
			var n = fbm(x, y, 1) * 0.06
			set_pixel(img, x, y, Color(c.r + n, c.g + n, c.b + n, c.a))
	return img

static func plank_pattern(base: Color, line: Color) -> Image:
	var img = Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	for y in range(SIZE):
		for x in range(SIZE):
			var c = base
			if y % 8 < 1 or y % 8 > 6:
				c = line
			var n = fbm(x * 2, y, 2) * 0.04
			set_pixel(img, x, y, Color(c.r + n, c.g + n, c.b + n, c.a))
	return img

static func log_top(base: Color, ring: Color) -> Image:
	var img = Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	var cx = SIZE / 2
	var cy = SIZE / 2
	for y in range(SIZE):
		for x in range(SIZE):
			var dx = x - cx
			var dy = y - cy
			var dist = sqrt(dx * dx + dy * dy)
			var is_ring = int(dist) % 4 == 0 or int(dist) % 4 == 1
			var c = ring if is_ring else base
			var n = fbm(x, y, 1) * 0.05
			set_pixel(img, x, y, Color(c.r + n, c.g + n, c.b + n, c.a))
	return img

static func bark_texture(base: Color, dark: Color) -> Image:
	var img = Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	for y in range(SIZE):
		for x in range(SIZE):
			var n = fbm(x, y * 2, 2) * 0.3
			var stripe = abs(sin(x * 0.8)) * 0.3
			var c = lerp_color(base, dark, n * 0.5 + stripe)
			set_pixel(img, x, y, c)
	return img

static func roof_tiles(base: Color, dark: Color) -> Image:
	var img = Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	for y in range(SIZE):
		for x in range(SIZE):
			var tile_row = y / 6
			var tile_col = x / 8
			var ly = y % 6
			var lx = x % 8
			var curve = abs(lx - 4) / 4.0
			var shade = 1.0 - (ly / 6.0) * 0.3 + curve * 0.2
			var c = Color(base.r * shade, base.g * shade, base.b * shade)
			if ly < 1:
				c = dark
			var n = fbm(x, y, 1) * 0.04
			set_pixel(img, x, y, Color(c.r + n, c.g + n, c.b + n, c.a))
	return img

static func gravel_texture() -> Image:
	var img = Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	for y in range(SIZE):
		for x in range(SIZE):
			var n = make_noise(x, y, 7)
			var bright = 0.4 + n * 0.3
			var c = Color(bright * 0.8, bright * 0.7, bright * 0.6)
			if abs(n) > 0.5:
				var dot = make_noise(x * 3, y * 3, 13)
				c = Color(0.6 + dot * 0.2, 0.5 + dot * 0.2, 0.4 + dot * 0.2)
				if abs(make_noise(x * 5, y * 5, 42)) > 0.6:
					c = Color(0.4, 0.35, 0.3)
			set_pixel(img, x, y, c)
	return img

static func marble_texture() -> Image:
	var img = Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	for y in range(SIZE):
		for x in range(SIZE):
			var n = fbm(x * 2, y * 2, 4) * 0.5
			var v = 0.9 + n * 0.1
			set_pixel(img, x, y, Color(v, v, v))
	return img

static func moss_texture(base: Image, moss_color: Color) -> Image:
	var img = base.duplicate()
	for y in range(SIZE):
		for x in range(SIZE):
			var n = fbm(x * 3, y * 3, 3)
			if n > 0.2:
				var t = clamp((n - 0.2) / 0.5, 0.0, 1.0)
				var orig = img.get_pixel(x, y)
				set_pixel(img, x, y, lerp_color(orig, moss_color, t * 0.7))
	return img

static func water_texture() -> Image:
	var img = Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	for y in range(SIZE):
		for x in range(SIZE):
			var n = fbm(x * 3, y * 3, 3) * 0.3
			var b = 0.6 + n
			set_pixel(img, x, y, Color(0.1, 0.3 + n * 0.3, b, 0.7))
	return img

static func glass_texture() -> Image:
	var img = Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	for y in range(SIZE):
		for x in range(SIZE):
			var n = fbm(x * 4, y * 4, 2) * 0.05
			var v = 0.9 + n
			var dist = Vector2(x - SIZE / 2, y - SIZE / 2).length() / (SIZE / 2)
			var alpha = 0.85 - dist * 0.15
			set_pixel(img, x, y, Color(v * 0.8, v * 0.85, v, alpha))
	return img

static func ice_texture() -> Image:
	var img = Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	for y in range(SIZE):
		for x in range(SIZE):
			var n = fbm(x * 2, y * 2, 3) * 0.1
			var v = 0.85 + n
			var alpha = 0.75
			set_pixel(img, x, y, Color(v * 0.7, v * 0.8, v, alpha))
	return img

static func lantern_texture() -> Image:
	var img = Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	for y in range(SIZE):
		for x in range(SIZE):
			var dx = x - SIZE / 2
			var dy = y - SIZE / 2
			var dist = sqrt(dx * dx + dy * dy) / (SIZE / 2)
			var bars = false
			if abs(dx) > 10 or abs(dy) > 10:
				bars = true
			var n = fbm(x * 3, y * 3, 2) * 0.1
			if bars:
				set_pixel(img, x, y, Color(0.3 + n, 0.2 + n, 0.1 + n))
			else:
				var glow = 1.0 - dist * 0.3
				set_pixel(img, x, y, Color(1.0, 0.7 + glow * 0.3 + n, 0.1 + n))
	return img

static func grass_top() -> Image:
	var img = Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	for y in range(SIZE):
		for x in range(SIZE):
			var n = fbm(x * 4, y * 4, 3)
			var g = 0.35 + n * 0.35
			set_pixel(img, x, y, Color(0.1, g, 0.1))
	return img

static func grass_side() -> Image:
	var img = Image.create(SIZE, SIZE, false, Image.FORMAT_RGBA8)
	for y in range(SIZE):
		for x in range(SIZE):
			var n = fbm(x * 2, y * 2, 2) * 0.1
			if y < 10:
				set_pixel(img, x, y, Color(0.1 + n, 0.4 + n, 0.1 + n))
			else:
				set_pixel(img, x, y, Color(0.4 + n, 0.25 + n, 0.1 + n))
	return img

static func generate_all() -> Dictionary:
	var dir = "res://resources/blocks/textures/"
	DirAccess.make_dir_recursive_absolute(dir)

	var textures = {
		"grass_top": grass_top(),
		"grass_side": grass_side(),
		"dirt": noise_texture(Color(0.45, 0.28, 0.12), Color(0.1, 0.05, 0.02), 1, 0.12),
		"stone": noise_texture(Color(0.5, 0.48, 0.45), Color(0.1, 0.08, 0.05), 2, 0.08),
		"cobblestone": four_color_noise(5, 8, Color(0.5,0.48,0.45), Color(0.4,0.38,0.35), Color(0.55,0.52,0.5), Color(0.35,0.33,0.3)),
		"stone_brick": brick_pattern(Color(0.55, 0.52, 0.48), Color(0.4, 0.38, 0.35), 8, 6),
		"marble": marble_texture(),
		"planks": plank_pattern(Color(0.55, 0.38, 0.22), Color(0.35, 0.25, 0.15)),
		"log_top": log_top(Color(0.6, 0.42, 0.22), Color(0.45, 0.3, 0.15)),
		"log_side": bark_texture(Color(0.5, 0.32, 0.18), Color(0.3, 0.2, 0.1)),
		"roof_tile": roof_tiles(Color(0.5, 0.5, 0.5), Color(0.15, 0.15, 0.15)),
		"brick": brick_pattern(Color(0.65, 0.2, 0.15), Color(0.4, 0.35, 0.3), 9, 5),
		"concrete": noise_texture(Color(0.6, 0.6, 0.6), Color(0.05, 0.05, 0.05), 3, 0.04),
		"sand": noise_texture(Color(0.76, 0.7, 0.5), Color(0.1, 0.08, 0.05), 4, 0.08),
		"gravel": gravel_texture(),
		"glass": glass_texture(),
		"ice": ice_texture(),
		"steel": noise_texture(Color(0.55, 0.55, 0.58), Color(0.05, 0.05, 0.08), 5, 0.03),
		"copper": noise_texture(Color(0.72, 0.45, 0.2), Color(0.1, 0.05, 0.02), 6, 0.06),
		"mossy_stone": moss_texture(noise_texture(Color(0.5, 0.48, 0.45), Color(0.1, 0.08, 0.05), 2, 0.08), Color(0.15, 0.5, 0.15)),
		"lantern": lantern_texture(),
		"water": water_texture(),
	}

	var saved := {}
	for name in textures:
		var path = dir + name + ".png"
		var err = textures[name].save_png(path)
		saved[name] = err
	return saved
