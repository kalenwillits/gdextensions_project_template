extends Node

func _ready() -> void:
	add_child(Scene.Network.instantiate())
	add_child(Scene.Campaign.instantiate())
