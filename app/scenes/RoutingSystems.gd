extends Node

func _ready():
	System.link("route_to_world", route_to_world)

func _on_tree_exiting():
	System.drop("route_to_world")
	
func route_to_world(_kwargs: Dictionary) -> void:
	Route.to(Scene.World)
