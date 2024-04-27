extends Node2D


func _ready() -> void:
	# Temporary hard-coded values
	Cache.campaign = "base" # TODO delete
	Cache.tilemap = "baseTileMap" # TODO delete
	var network = Scene.Network.instantiate()
	var campaign_controller = Scene.CampaignController.instantiate()
	var camera = Scene.Camera.instantiate()
	network.connect("server_established", func(): campaign_controller.spawn_tilemap(Cache.campaign, Cache.tilemap))
	network.connect("peer_connected", func(peer_id): campaign_controller.rpc_id(peer_id, "spawn_tilemap", Cache.campaign, Cache.tilemap))
	add_child(network)
	add_child(campaign_controller)
	add_child(camera)
