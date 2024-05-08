extends Node

enum NetworkMode {
	HOST,
	SERVER,
	CLIENT,
}

# Launcher fields
var campaign: String = Settings.DEFAULT_CAMPAIGN
var uri: String = Settings.DEFAULT_URI
var port: int = Settings.DEFAULT_PORT
var profile: String = Settings.DEFAULT_PROFILE
var network_mode: NetworkMode = NetworkMode.HOST


# Runtime storage
var textures: Dictionary  # Storage of already loaded textures
var camera_zoom: int = Settings.CAMERA_ZOOM_DEFAULT

#func reset() -> void:
	#campaign_name = ""
	#tilemap = ""
	#username = ""
	#password = ""
	#invite = ""
	#instance = ""
	#headers = {}
