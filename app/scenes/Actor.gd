extends CharacterBody2D

const SPEED_NORMAL: float = 700.0

@export var origin: Vector2
@export var destination: Vector2
@export var speed_mod: float = 1.0
@export var heading: String = Settings.DEFAULT_HEADING 
@export var state: String = "idle"
@export var sprite: String = ""
@export var polygon: String = ""

var peer_id: int = 0
var _ticks: float = 0.0
var _previous_heading: String
var _previous_sprite: String
var _previous_polygon: String

signal on_touch(actor)
signal heading_change(heading)
signal on_sprite_configured

func to_dict() -> Dictionary:
	return {
		"peer_id": peer_id,
		"name": name
	}
	
func _enter_tree():
	set_multiplayer_authority(str(name).to_int())


func _ready() -> void:
	add_to_group(str(peer_id))
	add_to_group(Settings.ACTOR_GROUP)

	$Label.set_text(name) # TODO - Replace label with real name
	$Sprite.set_sprite_frames(SpriteFrames.new())
	if is_multiplayer_authority():
		get_tree().get_first_node_in_group(Settings.CAMERA_GROUP).set_target(self)
	
func _physics_process(delta) -> void:
	use_state()
	use_animation()
	handle_sprite_change()
	handle_polygon_change()
	if is_multiplayer_authority():
		use_movement(delta)
		click_to_move()
		use_move_directly(delta)

func click_to_move() -> void:
	if Input.is_action_pressed("right_click"):
		set_destination(get_global_mouse_position())

func despawn() -> void:
	set_process(false)
	set_physics_process(false)
	queue_free()

func _clear_on_touch_connections() -> void:
	for sig in on_touch.get_connections():
		on_touch.disconnect(sig.callable)
	
func set_on_touch(action_name) -> void:
	_clear_on_touch_connections()
	pass # TODO
	#if action_name:
		#Campaign.get_action(action_name)\
		#.then(
			#func(action): 
				#for function_name in action.keys():
					#if function_name in $Actions.LIST:
						#on_touch.connect(func(actor): $Actions.call(function_name, actor, action.get(function_name, {})))
						## TODO - Impliment step function for a "next/step/then" parameter
				#return OK
		#).catch(func(err): push_error(err, action_name))

func clear_footprint():
	for node in get_children().filter(func(node): return node.is_class("CollisionPolygon2D")):
		node.queue_free()
		

func set_polygon(value: String) -> void:
	polygon = value

func build_polygon(polygon_key: String) -> void:
	var polygon_data = Campaign.get_Polygon(polygon_key)
	var collision_polygon: CollisionPolygon2D = CollisionPolygon2D.new()
	var vector_array: PackedVector2Array = []
	for vertex_key in polygon_data.get("vertices", []):
		var vertex: Dictionary = Campaign.get_Vertex(vertex_key)
		vector_array.append(Vector2i(vertex.get("x"), vertex.get("y")))
	collision_polygon.set_polygon(vector_array)
	var polygon_name: String = "FootprintPolygon"
	var existing_polygon = get_node_or_null(polygon_name)
	if existing_polygon != null:
		existing_polygon.queue_free()
		remove_child(existing_polygon)
	collision_polygon.set_name(polygon_name)
	add_child(collision_polygon)


func set_peer_id(value) -> void:
	if typeof(value) == TYPE_INT:
		peer_id = value
	else:
		peer_id = 0
	
func set_heading(value: String) -> void:
	heading = value

func set_speed_mod(value: float) -> void:
	speed_mod = value
	
func set_sprite(value: String) -> void:
	sprite = value
	
func build_frame(index: int, size: Vector2i, source: String) -> AtlasTexture:
	var external_texture: Texture
	var texture: AtlasTexture
	if Cache.textures.has(source):
		external_texture = Cache.textures[source]
	else:
		Cache.textures[source] = io.load_asset(Cache.campaign + source).unwrap()
	var columns: int = external_texture.get_width() / size.x
	texture = AtlasTexture.new()
	texture.set_atlas(external_texture)
	texture.set_region(std.get_region(index, columns, size))
	return texture
	
	
func get_sprite_size(sprite_data: Dictionary) -> Vector2i:
	var sprite_size_x: int = Settings.DEFAULT_SPRITE_SIZE_X
	var sprite_size_y: int = Settings.DEFAULT_SPRITE_SIZE_Y
	if sprite_data.get("size") != null:
		var sprite_size_vertex = Campaign.get_Vertex(sprite_data["size"])
		if sprite_size_vertex.get("x") != null:
			sprite_size_x = sprite_size_vertex["x"]
		if sprite_size_vertex.get("y") != null:
			sprite_size_y = sprite_size_vertex["y"]
	return Vector2i(sprite_size_x, sprite_size_y)
	
func get_sprite_margin(sprite_data: Dictionary) -> Vector2i:
	var sprite_margin_x: int = Settings.DEFAULT_SPRITE_MARGIN_X
	var sprite_margin_y: int = Settings.DEFAULT_SPRITE_MARGIN_Y
	if sprite_data.get("margin") != null:
		var sprite_margin_vertex = Campaign.get_Vertex(sprite_data["margin"])
		if sprite_margin_vertex.get("x") != null:
			sprite_margin_x = sprite_margin_vertex["x"]
		if sprite_margin_vertex.get("y") != null:
			sprite_margin_y = sprite_margin_vertex["y"]
	return Vector2i(sprite_margin_x, sprite_margin_y)

@rpc("any_peer", "call_local", "reliable")
func build_sprite(sprite_key: String) -> Result:
	var sprite_data = Campaign.get_Sprite(sprite_key)# TODO -> Create a sprite mapper/builder that pulls this out of campaign
	var spritesheet = sprite_data.get("texture")
	if spritesheet == null: return
	if !Cache.textures.get(spritesheet):
		io\
		.load_asset(Cache.campaign + spritesheet)\
		.then(func(texture): Cache.textures[spritesheet] = texture; return OK)\
		.catch(func(_err): push_error("error loading texture %s" % spritesheet))
		
	var texture = Cache.textures.get(spritesheet)
	var sprite_frames: SpriteFrames = SpriteFrames.new()
	if texture != null:
		var animation_key: String = sprite_data.get("animation")
		var animation: Dictionary = Campaign.get_Animation(animation_key)
		for animation_name in animation.keys():
			for radial in animation[animation_name].keys():
				var animation_radial_name: String = "%s:%s" % [animation_name, radial]
				if animation_radial_name == "_":
					animation_radial_name = "default"
				else:
					sprite_frames.add_animation(animation_radial_name)
				for frame in animation[animation_name][radial]:
					sprite_frames.add_frame(
						animation_radial_name, 
						build_frame(
							frame,
							get_sprite_size(sprite_data),
							sprite_data.get("texture"),
						)
					);
		_handle_sprite_config.call_deferred(sprite_data, sprite_frames)
	return Result.ok(OK)
	
func _handle_sprite_config(sprite_data: Dictionary, sprite_frames: SpriteFrames) -> void:
		## Setting up a sprite sheet dynamically is a touchy thing. It must be started in this order.
		$Sprite.offset = _calculate_sprite_offset(sprite_data)
		$Sprite.set_sprite_frames(sprite_frames)
		$Sprite.set_animation("default")

func _calculate_sprite_offset(sprite_data: Dictionary) -> Vector2i:
	var full_size: Vector2i = get_sprite_size(sprite_data)
	var margin: Vector2i = get_sprite_margin(sprite_data)
	var actual_size: Vector2i = full_size - margin
	var result: Vector2i = -actual_size
	result.x += ((full_size.x / 2) - (margin.x))
	return result

func use_movement(delta: float) -> void:
	if position.distance_squared_to(destination) > Settings.DESTINATION_PRECISION:
		var motion = position.direction_to(destination)
		velocity = motion * get_speed(delta) * std.isometric_factor(motion.angle())
		look_at_point(destination)
		move_and_slide()
	else:
		set_destination(position)
		velocity = Vector2.ZERO

func look_at_point(point: Vector2) -> void:
	heading = map_radial(point.angle_to_point(position))
	if _previous_heading != heading:
		_previous_heading = heading
		heading_change.emit(heading)
	
func map_radial(radians: float) -> String:
	return Settings.RADIALS.keys()[snap_radial(radians)]
	
func snap_radial(radians: float) -> int:
	return wrapi(snapped(radians, PI/4) / (PI/4), 0, 8)
	
func get_speed(delta: float) -> float:
	return Settings.BASE_ACTOR_SPEED * delta * speed_mod * SPEED_NORMAL
	
func use_move_directly(_delta) -> void:
	var motion = Input.get_vector("left", "right", "up", "down")
	var new_destination: Vector2 = position + motion

	if motion.length():
		set_destination(new_destination)
		look_at_point(new_destination)
		
	
func set_destination(point: Vector2) -> void:
	destination = point
	
func set_origin(point: Vector2) -> void:
	origin = point
	
func use_animation():
	if $Sprite.sprite_frames.has_animation("%s:%s" % [state, heading]):
		$Sprite.animation = "%s:%s" % [state, heading]
#		$Outline.animation = animation
	elif $Sprite.sprite_frames.has_animation("default:%s" % heading):
		$Sprite.animation = "default:%s" % heading
	else:
		$Sprite.animation = "default"
		
		
func set_remote_transform_target(node: Node) -> void:
	$RemoteTransform2D.remote_path = node.get_path()
	
func clear_remote_transform_target() -> void:
	$RemoteTransform2D.remote_path = null

func set_state(value: String) -> void:
	state = value
	
func set_animation_speed(value: float) -> void:
	$Sprite.speed_scale = value
	
func use_state() -> void:
	match state:
		"idle":
			if !position.is_equal_approx(destination):
				set_animation_speed(std.isometric_factor(velocity.angle()))
				set_state("run")
				
		# TODO -- add walking
		"run": 
			if position.is_equal_approx(destination):
				set_state("idle")
		

func _on_sprite_animation_finished() -> void:
	match state:
		"idle", "run", "dead":  # These are states that do not automatically resolve to idle.
			pass
		_:
			set_state("idle")
			set_animation_speed(1.0)


func _on_heading_change(radial):
	pass


func _on_hit_box_body_entered(actor):
	if actor != self and $HitboxTriggerCooldownTimer.is_stopped():
		$HitboxTriggerCooldownTimer.start()
		on_touch.emit(actor)
		
func set_polygons(disabled: bool) -> void:
	for node in get_children():
		if node.is_class("CollisionPolygon2D"):
			node.disabled = disabled
	for node in $HitBox.get_children():
		if node.is_class("CollisionPolygon2D"):
			node.disabled = disabled

func handle_sprite_change():
	if sprite != "" and _previous_sprite != sprite:
		_previous_sprite = sprite
		build_sprite(sprite)
	
func handle_polygon_change():
	if sprite != "" and _previous_polygon != polygon:
		_previous_polygon = polygon
		build_polygon(polygon)


func _on_sprite_animation_changed():
	$Sprite.play()


func _on_multiplayer_synchronizer_synchronized():
	pass # Replace with function body.
