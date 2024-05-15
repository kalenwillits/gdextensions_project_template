extends Node

var _scene: String
var _actor: String
var _name: String

func _ready() -> void:
	load_or_create_new(Cache.profile)

func _on_tree_exited():
	save()

func load_or_create_new(profile_name: String):
	io.use_dir(Settings.PROFILES_DIR)
	var profile_path: String = Settings.PROFILES_DIR + profile_name
	var profile: Dictionary
	if FileAccess.file_exists(profile_path):
		profile = io.load_json(profile_path).unwrap()
	else:
		profile = _generate_default_profile(profile_name)
		io.save_json(profile_path, profile)
	from_dict(profile)
	return profile
	
func save() -> void:
	io.save_json(Settings.PROFILES_DIR + Cache.profile, to_dict())

func _generate_default_profile(profile_name: String) -> Dictionary:
	var maindata: Dictionary = Campaign.get_Main()
	return {
		"actor": maindata["actor"],
		"scene": maindata["scene"],
		"name": profile_name,
	}

func active_scene() -> String:
	return _scene
	
func from_actor(actor: Node):
	pass # TODO
	
func to_dict() -> Dictionary:
	return {
		"scene": _scene,
		"actor": _actor,
		"name": _name
	}
	
func from_dict(data: Dictionary) -> void:
	_scene = data["scene"]
	_actor = data["actor"]
	_name = data["name"]


