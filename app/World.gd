extends Node2D


func _ready() -> void:
	# Temporary hard-coded values
	Cache.campaign = "base" # TODO delete
	Cache.tilemap = "baseTileMap" # TODO delete
	var network = Scene.Network.instantiate()
	var campaign_controller = Scene.CampaignController.instantiate()
	var camera = Scene.Camera.instantiate()
	var actor = Scene.Actor.instantiate()
	camera.set_target(actor)
	#actor.set_peer_id(network.multiplayer.get_unique_id())
	network.connect("server_established", func(): campaign_controller.spawn_tilemap(Cache.campaign, Cache.tilemap))
	network.connect("peer_connected", func(peer_id): campaign_controller.rpc_id(peer_id, "spawn_tilemap", Cache.campaign, Cache.tilemap))
	network.connect(
		"server_established",
		 func(): 
			actor.set_multiplayer_authority(1)
			add_child(actor)
			)
	network.connect(
		"client_established", 
		func(): 
			actor.set_multiplayer_authority(network.multiplayer.get_unique_id())
			add_child(actor)
	)
	add_child(network)
	add_child(campaign_controller)
	add_child(camera)
