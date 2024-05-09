extends Node2D

@onready var network = Scene.Network.instantiate()
@onready var camera = Scene.Camera.instantiate()
@onready var profile = Scene.Profile.instantiate()


func _enter_tree() -> void:
	Campaign.load_from_archive()

func _ready() -> void:
	network.server_established.connect(use_server_established)
	network.peer_connected.connect(use_peer_connected)
	network.client_established.connect(use_client_established)
	network.peer_disconnected.connect(use_peer_disconnected)
	network.server_disconnected.connect(use_server_disconnected)
	add_child(camera)
	add_child(network)
	add_child(profile)

@rpc("authority", "reliable")
func spawn_tilemap(campaign: String, tilemap_key: String) -> void:
	Cache.campaign = campaign
	var isometric_tilemap: TileMap = Scene.IsometricTileMap.instantiate().build(self, tilemap_key)
	add_child(isometric_tilemap)

func use_server_established() -> void:
	spawn_tilemap(Cache.campaign, "baseTileMap")
	var data: Dictionary = profile.to_dict()
	data["peer_id"] = network.multiplayer.get_unique_id()
	sync_actor(data)

func use_client_established() -> void:
	var data: Dictionary = profile.to_dict()
	data["peer_id"] = network.multiplayer.get_unique_id()
	get_tree().create_timer(0.1).timeout.connect(func(): rpc("sync_actor", data))

func use_peer_connected(peer_id: int) -> void:
	rpc_id(peer_id, "spawn_tilemap", Cache.campaign, "baseTileMap")
	
func use_peer_disconnected(peer_id: int) -> void:
	var actor = get_node_or_null(str(peer_id))
	if actor != null:
		actor.queue_free()
		
func use_server_disconnected() -> void:
	pass

@rpc("call_local", "any_peer", "reliable")
func sync_actor(data: Dictionary) -> void:
	var actor = _get_or_spawn_actor(data["peer_id"])
	var actor_data = Campaign.get_Actor(data["actor"])
	actor.set_name(str(data["peer_id"]))
	actor.set_sprite(actor_data["sprite"])
	actor.set_polygon(actor_data["polygon"])
	if !has_node(str(data["peer_id"])):
		add_child(actor)

func _get_or_spawn_actor(peer_id: int) -> CharacterBody2D:
	var actor = get_node_or_null(str(peer_id))
	if actor != null:
		return actor
	actor = Scene.Actor.instantiate()
	actor.set_name(str(peer_id))
	return actor
	
	
