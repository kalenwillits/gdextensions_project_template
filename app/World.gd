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
	spawn_actor({"peer_id": network.multiplayer.get_unique_id()})

func use_client_established() -> void:
	pass
	#spawn_actor({"peer_id": network.multiplayer.get_unique_id()})
	
	
func use_peer_connected(peer_id: int) -> void:
	campaign_controller.rpc_id(peer_id, "spawn_tilemap", Cache.campaign, Cache.tilemap)
	var actor_dataset = get_actor_dataset()
	#actor_dataset.append({
		#"peer_id": peer_id
		#})
	#rpc.call("sync_actors", get_actor_dataset())	if !has_node(actor.get_name()):
	spawn_actor({"peer_id": peer_id})

#@rpc("reliable")
func spawn_actor(data: Dictionary) -> void:
	var actor = Scene.Actor.instantiate()
	actor.set_name(str(data["peer_id"]))
	add_child(actor)
	
@rpc("reliable")
func sync_actors(actors: Array) -> void:
	for actor_data in actors:
		spawn_actor(actor_data)
		
func get_actor_dataset() -> Array:
	var actors: Array = get_tree().get_nodes_in_group(Settings.ACTOR_GROUP)
	var actor_dataset: Array = []
	for actor in actors:
		actor_dataset.append(actor.to_dict())
	return actor_dataset
