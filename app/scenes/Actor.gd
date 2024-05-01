extends CharacterBody2D

const SPEED_NORMAL: float = 700.0

@export var origin: Vector2
@export var destination: Vector2
@export var speed_mod: float = 1.0
@export var heading: String = Settings.DEFAULT_HEADING 
@export var state: String = "idle"
@export var sprite: String

var peer_id: int = 0
var _ticks: float = 0.0
var _previous_heading: String
var _previous_sprite: String

signal on_touch(actor)
signal heading_change(heading)

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
	call_deferred("_use_animate_polygons", heading)
	if is_multiplayer_authority():
		get_tree().get_first_node_in_group(Settings.CAMERA_GROUP).set_target(self)
	
func _physics_process(delta) -> void:
	use_state()
	use_animation()
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
	

	
func set_footprint(footprint_key) -> void:
	pass # TODO
	#Campaign.get_polygon(footprint_key)\
	#.then(
		#func(footprint):
			#for node in get_children().filter(func(node): return node.is_class("CollisionPolygon2D")):
				#node.queue_free()
			#for radial in footprint.keys():
				#if radial == "key":
					#continue
				#if typeof(footprint[radial]) == TYPE_ARRAY:
					#var polygon: CollisionPolygon2D = CollisionPolygon2D.new()
					#polygon.set_polygon(footprint[radial].map(std.vec2_from))
					#polygon.set_name("FootprintPolygon%s" % radial)
					#add_child(polygon)
			#)
	
func set_peer_id(value) -> void:
	if typeof(value) == TYPE_INT:
		peer_id = value
	else:
		peer_id = 0
	
func set_heading(value: String) -> void:
	heading = value

func set_speed_mod(value: float) -> void:
	speed_mod = value
	
#func set_sprite(value: String) -> void:
	#sprite_key = value
	#
func build_frame(index: int, size: Vector2i, source: String) -> AtlasTexture:
	var external_texture: Texture
	var texture: AtlasTexture
	if Cache.textures.has(source):
		external_texture = Cache.textures[source]
	else:
		Cache.textures[source] = io.load_asset(source).unwrap_or_else(func(): push_error("Unable to load texture."))
	var columns: int = external_texture.get_width() / size.x
	texture = AtlasTexture.new()
	texture.set_atlas(external_texture)
	texture.set_region(std.get_region(index, columns, size))
	return texture

@rpc("any_peer", "call_local", "reliable")
func build_sprite(sprite_key: String) -> Result:
	var campaign_controller = get_tree().get_first_node_in_group(Settings.CAMPAIGN_CONTROLLER_GROUP)
	var sprite_data = campaign_controller.get_Sprite(sprite_key)# TODO -> Create a sprite mapper/builder that pulls this out of campaign
	var src = sprite_data.get("src")
	if src == null: return
	if !Cache.textures.get(src):
		io\
		.load_asset(src)\
		.then(func(texture): Cache.textures[src] = texture; return OK)\
		.catch(func(_err): push_error("error loading texture %s" % src))
		
	var texture = Cache.textures.get(src)
	var sprite_frames: SpriteFrames = SpriteFrames.new()
	if texture != null:
		var animation_key: String = sprite_data.get("animation")
		var animation: Dictionary = campaign_controller.get_Animation(animation_key)
		if animation.get("default") == null:
			# Inject a default animation if one does not exist.
			animation["default"] = {"_": [0]}
		for animation_name in animation.keys():
			if animation_name == "key":
				continue  ### TODO - Why? 
			#var columns: int = sprite.get("columns", 1)
			for radial in animation[animation_name].keys():
				var animation_radial_name: String = "%s:%s" % [animation_name, radial]
				if animation_radial_name.contains("default"):
					animation_radial_name = "default"
				else:
					sprite_frames.add_animation(animation_radial_name)
				for frame in animation[animation_name][radial]:
					sprite_frames.add_frame(
						animation_radial_name, 
						build_frame(
							frame, 
							#columns, 
							std.vec2i_from(sprite_data.get("size")),
							sprite_data.get("src", Settings.MISSING_VALUE),
						)
					);
		$Sprite.offset = _calculate_sprite_offset(sprite_data)
		$Sprite.set_sprite_frames(sprite_frames)
		$Sprite.set_animation("default")
		$Sprite.play()
	return Result.ok(OK)
	
func _calculate_sprite_offset(sprite_data: Dictionary) -> Vector2i:
	var full_size: Vector2i = std.vec2i_from(sprite_data.get("size"))
	var margin: Vector2i = std.vec2i_from(sprite_data.get("margin"))
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
			
		
func _use_animate_polygons(radial: String) -> void:
	var updated_active_footprint: bool = false
	var updated_active_hitbox: bool = false
	for node in get_children().filter(func(node): return node.is_class("CollisionPolygon2D")):
		if node.name.ends_with(radial):
			node.disabled = false
			updated_active_footprint = true

		else:
			node.disabled = true
			
	for node in $HitBox.get_children().filter(func(node): return node.is_class("CollisionPolygon2D")):
		if node.name.ends_with(heading):
			node.disabled = false
			node.visible = true
			updated_active_hitbox = true

		else:
			node.disabled = true
			node.visible = false
			
	if !updated_active_footprint:
		var footprint_polygon_default = get_node_or_null("FootprintPolygondefault")
		if footprint_polygon_default:
			footprint_polygon_default.disabled = false
			footprint_polygon_default.visible = true
	if !updated_active_hitbox:
		var hitbox_polygon_default = $HitBox.get_node_or_null("HitBoxPolygondefault")
		if hitbox_polygon_default:
			hitbox_polygon_default.disabled = false
			hitbox_polygon_default.visible = true

func _on_sprite_animation_finished() -> void:
	match state:
		"idle", "run", "dead":  # These are states that do not automatically resolve to idle.
			pass
		_:
			set_state("idle")
			set_animation_speed(1.0)


func _on_heading_change(radial):
	_use_animate_polygons(radial)


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


func _on_multiplayer_synchronizer_synchronized():
	if _previous_sprite != sprite:
		_previous_sprite = sprite
		build_sprite(sprite)
