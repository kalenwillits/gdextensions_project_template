extends CharacterBody2D
class_name ActorReplica

const SPEED_NORMAL: float = 700.0

var pk: int
var zone_pk: int
var origin: Vector2
var destination: Vector2
var speed_mod: float = 1.0
var heading: String = Settings.DEFAULT_HEADING 
var state: String = "idle"
var peer_id: int = 0
var Campaign: Node
var data: Dictionary = {}

var _ticks: float = 0.0
var _previous_heading: String

signal on_touch(actor)
signal heading_change(heading)

func _ready() -> void:
	Campaign = get_tree().get_first_node_in_group(Settings.CAMPAIGN_CONTROLLER_GROUP)
	$Label.set_text(str(peer_id))  # TODO - Replace label with real name
	$Sprite.set_sprite_frames(SpriteFrames.new())
	add_to_group(name)
	set_multiplayer_authority(peer_id)
	if is_multiplayer_authority():
		get_tree().get_first_node_in_group(Settings.CAMERA_GROUP).set_target(self)
	call_deferred("_use_animate_polygons", heading)
	
func _physics_process(delta) -> void:
	use_state()
	use_animation()
	use_movement(delta)
	#if is_multiplayer_authority():
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


func set_pk(value: int) -> void:
	pk = value
	
func set_zone_pk(value: int) -> void:
	zone_pk = value
	
func set_peer_id(value) -> void:
	if typeof(value) == TYPE_INT:
		peer_id = value
	else:
		peer_id = 0
	
func set_heading(value: String) -> void:
	heading = value

func set_speed_mod(value: float) -> void:
	speed_mod = value

func set_sprite(sprite_key: String) -> Result:
	var sprite = Campaign.get_sprite(sprite_key).unwrap()
	var src = sprite.get("src")
	if !Cache.textures.get(src):
		io\
		.load_asset(src)\
		.then(func(texture): Cache.textures[src] = texture; return OK)\
		.catch(func(_err): push_error("error loading texture %s" % src))
		
	var texture = Cache.textures.get(src)
	var sprite_frames: SpriteFrames = SpriteFrames.new()
	if texture != null:
		var animation: Dictionary = Campaign\
		.get_animation(sprite.get("animation"))\
		.unwrap_or(func(): return {})
		if animation.get("default") == null:
			# Inject a default animation if one does not exist.
			animation["default"] = {"_": [0]}
		for animation_key in animation.keys():
			if animation_key == "key":
				continue
			var columns: int = sprite.get("columns", 1)
			for radial in animation[animation_key].keys():
				var animation_name: String = "%s:%s" % [animation_key, radial]
				if animation_name.contains("default"):
					animation_name = "default"
				else:
					sprite_frames.add_animation(animation_name)
				for frame in animation[animation_key][radial]:
					sprite_frames.add_frame(
						animation_name, 
						std.build_frame(
							frame, 
							columns, 
							std.vec2i_from(sprite.get("size")),
							sprite.get("src", Settings.MISSING_VALUE),
						)
					);
		$Sprite.offset = _calculate_sprite_offset(sprite)
		$Sprite.set_sprite_frames(sprite_frames)
		$Sprite.set_animation("default")
		$Sprite.play()
	return Result.ok(OK)
	
func _calculate_sprite_offset(sprite) -> Vector2i:
	var full_size: Vector2i = std.vec2i_from(sprite.get("size"))
	var margin: Vector2i = std.vec2i_from(sprite.get("margin"))
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
