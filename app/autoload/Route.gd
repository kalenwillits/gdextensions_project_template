extends Node


func scene() -> String:
	return get_tree().get_current_scene().get_name()


func to(packed_scene: PackedScene):
	get_tree().call_deferred("change_scene_to_packed", packed_scene)
