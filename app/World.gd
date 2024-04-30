extends Node2D

@onready var network = Scene.Network.instantiate()
@onready var campaign_controller = Scene.CampaignController.instantiate()
@onready var camera = Scene.Camera.instantiate()

func _ready() -> void:
	# Temporary hard-coded values
	Cache.campaign = "base" # TODO delete
	Cache.tilemap = "baseTileMap" # TODO delete

	network.connect("server_established", use_server_established)
	network.connect("peer_connected", use_peer_connected)
	network.connect(
		"client_established", 
		use_client_established
	)
	add_child(network)
	add_child(campaign_controller)
	add_child(camera)

func use_server_established() -> void:
	campaign_controller.spawn_tilemap(Cache.campaign, Cache.tilemap)
	spawn_actor({"peer_id": network.multiplayer.get_unique_id(), "sprite": "baseSprite"})

func use_client_established() -> void:
	pass
	
func use_peer_connected(peer_id: int) -> void:
	campaign_controller.rpc_id(peer_id, "spawn_tilemap", Cache.campaign, Cache.tilemap)
	spawn_actor({"peer_id": peer_id, "sprite": "baseSprite"})

func spawn_actor(data: Dictionary) -> void:
	var actor = Scene.Actor.instantiate()
	actor.set_name(str(data["peer_id"]))
	actor.set_sprite(data["sprite"])
	add_child(actor)
