extends Camera2D


var _target: WeakRef
var _has_target: bool = false
var _lock: bool = false


func _ready() -> void:
	add_to_group(Settings.CAMERA_GROUP)
	make_current()
	zoom_update()

func pan_to(vec: Vector2, delta: float) -> void:
	var direction = (vec - position)
	if direction.length() > Settings.CAMERA_TOLERANCE:
		position += (direction.normalized() * delta * (Settings.CAMERA_SPEED / Cache.camera_zoom))
		
func set_target(node: Node2D) -> void:
	_has_target = true
	_target = weakref(node)
	
func get_target() -> Result:
	return Result.ok(_target.get_ref())
	
func clear_target() -> void:
	_has_target = false
	_target = null
		
		
func snap_to(vec: Vector2) -> void:
	position = vec
	
		
func use_margin_panning(delta: float) -> void:
	var cursor = get_viewport().get_mouse_position()
	var viewsize = get_viewport().get_visible_rect().size
	if (cursor.x < Settings.CAMERA_MARGIN) or (cursor.x > (viewsize.x - Settings.CAMERA_MARGIN)):
		pan_to(get_global_mouse_position(), delta)
	elif (cursor.y < Settings.CAMERA_MARGIN) or (cursor.y > (viewsize.y - Settings.CAMERA_MARGIN)):
		pan_to(get_global_mouse_position(), delta)

func _physics_process(delta: float) -> void:
	handle_focus_events(delta)
	handle_zoom_events()
	handle_camera_lock()

func handle_focus_events(delta: float) -> void:
	if _has_target and _lock:
		use_sync_to_target()
	else:
		use_margin_panning(delta)
		
func handle_zoom_events() -> void:
	if Input.is_action_just_pressed("zoom_in"):
		zoom_in()
	elif Input.is_action_just_pressed("zoom_out"):
		zoom_out()

func use_sync_to_target() -> void:
	get_target().then(func(target): snap_to(target.position))
	
func handle_camera_lock() -> void:
	if Input.is_action_just_pressed("camera_lock"):
		_lock = true
	if Input.is_action_just_released("camera_lock"):
		_lock = false


func zoom_in() -> void:
	Cache.camera_zoom = min(Settings.CAMERA_ZOOM_MAX, Cache.camera_zoom + 1)
	zoom_update()


func zoom_out() -> void:
	Cache.camera_zoom = max(Settings.CAMERA_ZOOM_MIN, Cache.camera_zoom - 1)
	zoom_update()
	
func zoom_update() -> void:
	zoom.x = Cache.camera_zoom
	zoom.y = Cache.camera_zoom
