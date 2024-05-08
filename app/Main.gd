extends Node

func _ready():
	add_child(Scene.ArgParse.instantiate())
	Route.to(Scene.World)
