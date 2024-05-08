extends Node2D

@onready var network = Scene.Network.instantiate()
@onready var campaign_controller = Scene.CampaignController.instantiate()
@onready var camera = Scene.Camera.instantiate()
@onready var profile = Scene.Profile.instantiate()


func _ready() -> void:
	network.connect("server_established", use_server_established)
	network.connect("peer_connected", use_peer_connected)
	network.connect(
		"client_established", 
		use_client_established
	)
	campaign_controller.ready.connect(func(): add_child(profile))
	add_child(campaign_controller)
	add_child(camera)
	add_child(network)

func use_server_established() -> void:
	campaign_controller.spawn_tilemap(Cache.campaign, "baseTileMap")
	var data: Dictionary = profile.to_dict()
	data["peer_id"] = network.multiplayer.get_unique_id()
	sync_actor(data)
	#use_establish_network()

func use_client_established() -> void:
	var data: Dictionary = profile.to_dict()
	data["peer_id"] = network.multiplayer.get_unique_id()
	get_tree().create_timer(0.1).timeout.connect(func(): rpc_id(1, "sync_actor", data))
	

func use_peer_connected(peer_id: int) -> void:
	campaign_controller.rpc_id(peer_id, "spawn_tilemap", Cache.campaign, "baseTileMap")

@rpc("call_local", "any_peer", "reliable")
func sync_actor(data: Dictionary) -> void:
	var actor = _get_or_spawn_actor(data["peer_id"])
	var actor_data = campaign_controller.get_Actor(data["actor"])
	actor.set_name(str(data["peer_id"]))
	actor.set_sprite(actor_data["sprite"])
	actor.set_polygon(actor_data["polygon"])
	add_child(actor)

func _get_or_spawn_actor(peer_id: int) -> CharacterBody2D:
	var actor = get_node_or_null(str(peer_id))
	if actor != null:
		return actor
	actor = Scene.Actor.instantiate()
	actor.set_name(str(peer_id))
	return actor
	
	
