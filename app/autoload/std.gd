extends Node

const UNIQUE_KEY_CHAR_SET: String = "abcdefghijklmnopqrstuvwxyz0123456789"


class SelfDestructingTimer extends Timer:
	var target: Callable
	
	func arm(lambda: Callable, seconds: float):
		connect("timeout", lambda)
		set("target", target)
		wait_time = seconds
		one_shot = true
		autostart = true

	func trigger():
		target.call()
		queue_free()


func unique_id() -> String:
	randomize()
	var id = ""
	for n in [8, 4, 4, 4, 12]:
		for _j in range(n):
			id += UNIQUE_KEY_CHAR_SET[randi() % len(UNIQUE_KEY_CHAR_SET)]
		if n != 12:
			id += "-"
	return id


func encrypt(value: String, salt: String) -> String:
	return (value + salt).sha256_text()
	
	
func get_file_name_from_path(path: String) -> String:
	var parts: PackedStringArray = path.split("/")
	return parts[parts.size() - 1]

func where(filter: Dictionary, use_or: bool = false) -> String:
	var result: String = ""
	var i: int = 0
	for key in filter.keys():
		match typeof(filter[key]):
			TYPE_STRING:
				result += key + "='" + filter[key] + "' "
			_:
				result += key + "=" + str(filter[key]) + " "
		i += 1
		if i < filter.size():
			result += "and " if !use_or else "or "	
	return result
	
	
func get_region(index: int, columns: int, size: Vector2i) -> Rect2i:
		return Rect2i(Vector2i((index % columns) * size.x, (index / columns) * size.y), size) 
	
func build_frame(index: int, columns: int, size: Vector2i, source: String) -> AtlasTexture:
	var external_texture: Texture
	var texture: AtlasTexture
	if Cache.textures.has(source):
		external_texture = Cache.textures[source]
	else:
		Cache.textures[source] = io.load_asset(Cache.campaign + source).unwrap_or_else(func(): push_error("Unable to load texture."))
	texture = AtlasTexture.new()
	texture.set_atlas(external_texture)
	texture.set_region(std.get_region(index, columns, size))
	return texture
	
func vec2i_from(value) -> Vector2i:
	var vec: Vector2i = Vector2i()
	match typeof(value):
		TYPE_ARRAY:
			if value.size() >= 1:
				if typeof(value[0]) == TYPE_INT or typeof(value[0]) == TYPE_FLOAT:
					vec.x = int(value[0])
			if value.size() >= 2:
				if typeof(value[1]) == TYPE_INT or typeof(value[1]) == TYPE_FLOAT:
					vec.y = int(value[1])
		TYPE_DICTIONARY:
			var x = value.get("x")
			var y = value.get("y")
			if typeof(x) == TYPE_INT or typeof(x) == TYPE_FLOAT:
				vec.x = int(x)
			if typeof(y) == TYPE_INT or typeof(y) == TYPE_FLOAT:
				vec.y = int(y)
	return vec
	
func vec2_from(value) -> Vector2:
	var vec: Vector2 = Vector2()
	match typeof(value):
		TYPE_ARRAY:
			if value.size() >= 1:
				if typeof(value[0]) == TYPE_INT or typeof(value[0]) == TYPE_FLOAT:
					vec.x = float(value[0])
			if value.size() >= 2:
				if typeof(value[1]) == TYPE_INT or typeof(value[1]) == TYPE_FLOAT:
					vec.y = float(value[1])
		TYPE_DICTIONARY:
			var x = value.get("x")
			var y = value.get("y")
			if typeof(x) == TYPE_INT or typeof(x) == TYPE_FLOAT:
				vec.x = float(x)
			if typeof(y) == TYPE_INT or typeof(y) == TYPE_FLOAT:
				vec.y = float(y)
	return vec
	
func cmdline_arg(arg: String) -> Result:
	if OS.get_cmdline_args().has(arg):
		var i = OS.get_cmdline_args().find(arg)
		if OS.get_cmdline_args().size() > i + 1:
			return Result.ok(OS.get_cmdline_args()[i + 1])
	return Result.fail(FAILED)
	
func parse_kwarg(arg: String, args: Array) -> Result:
	var items: Dictionary = {}
	for item in args:
		if Settings.KWARGS_DELIMITER in item:
			var part: Array = arg.split(Settings.KWARGS_DELIMITER)
			items[part[0]] = part[1]
	if arg in items:
		return Result.ok(items[arg])
	return Result.fail(FAILED)
	
func isometric_factor(radians: float) -> float:
	radians = abs(radians)
	if radians > Settings.NORTH_RADIANS:
		radians = Settings.NORTH_RADIANS - (radians - Settings.NORTH_RADIANS)
	return 1.0 - ((radians / (Settings.NORTH_RADIANS) / Settings.ISOMETRIC_RATIO))
	
	
func delay(lambda: Callable, seconds: float):
	var timer = SelfDestructingTimer.new()
	timer.arm(lambda, seconds) 
	add_child(timer)
	
func coalesce(arg1=null, arg2=null, arg3=null, arg4=null, arg5=null):
	if arg1 != null:
		return arg1
	elif arg2 != null:
		return arg2
	elif arg3 != null:
		return arg3
	elif arg4 != null:
		return arg4
	elif arg5 != null:
		return arg5
	return null
	
	
func mean(data: Array) -> float:
	var sum: float = 0.0
	var length: float = data.size()
	if length > 0.0:
		for item in data:
			sum += item
		return sum / data.size()
	return 0.0
	
	
func stdev(data: Array) -> float: 
	var length: float = data.size()
	if length > 0:
		var mn: float = mean(data)
		var deviations: Array = []
		for item in data:
			deviations.append(pow(item - mn, 2))
		var sum: float = 0.0
		for item in deviations:
			sum += item
		return sum / length
	return 0.0
