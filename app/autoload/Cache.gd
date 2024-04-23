extends Node

var campaign: String
var tilemap: String
var textures: Dictionary  # Storage of already loaded textures
var uri: String
var port: int
var camera_zoom: int = Settings.CAMERA_ZOOM_DEFAULT

#func reset() -> void:
	#campaign_name = ""
	#tilemap = ""
	#username = ""
	#password = ""
	#invite = ""
	#instance = ""
	#headers = {}
