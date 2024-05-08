extends Node

var _scene: String
var _actor: String
var _name: String

func _ready() -> void:
	load_or_create_new.call_deferred(Cache.profile)

func _on_tree_exited():
	save()

func load_or_create_new(profile_name: String):
	io.use_dir(Settings.PROFILES_DIR)
	var profile_path: String = Settings.PROFILES_DIR + profile_name
	var profile: Dictionary
	if FileAccess.file_exists(profile_path):
		io.load_json(profile_path).then(func(data): profile = data)
	else:
		profile = _generate_default_profile(profile_name)
		io.save_json(profile_path, profile)
	return profile
	
func save() -> void:
	pass # TODO

func _generate_default_profile(profile_name: String) -> Dictionary:
	var campaign_controller = get_tree().get_first_node_in_group(Settings.CAMPAIGN_CONTROLLER_GROUP)
	var maindata: Dictionary = campaign_controller.get_Main()
	var new_profile: Dictionary = {}
	_scene = maindata["scene"]
	_actor = maindata["actor"]
	_name = profile_name
	return new_profile
	
func _from_actor(actor: Node):
	pass # TODO
	
func _to_dict() -> Dictionary:
	return {
		"scene": _scene,
		"actor": _actor,
		"name": _name
	}



