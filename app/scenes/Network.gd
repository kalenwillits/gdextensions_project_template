extends Node

func _ready():
	add_to_group(Settings.NETWORK_GROUP)
	Console.link("server.start", start_server)
	Console.link("client.start", start_client)
	
func _on_tree_exiting():
	Console.drop("server.start")
	Console.drop("client.start")
	
	
func start_server(kwargs: Dictionary) -> void:
	establish_server(kwargs.get("uri", Settings.DEFAULT_URI), int(kwargs.get("port", Settings.DEFAULT_PORT)))
	
func start_client(kwargs: Dictionary) -> void:
	establish_client(kwargs.get("uri", Settings.DEFAULT_URI), int(kwargs.get("port", Settings.DEFAULT_PORT)))

# PROPERTIES -------------------------------------------------------------------------------------------------------- #

# A MultiplayerPeer implementation that should be passed to
# MultiplayerAPI.multiplayer_peer after being initialized as either a client,
# server, or mesh. Events can then be handled by connecting to MultiplayerAPI
# signals. See ENetConnection for more information on the ENet library wrapper.

# Note: ENet only uses UDP, not TCP. When forwarding the server port to make
# your server accessible on the public Internet, you only need to forward the
# server port in UDP. You can use the UPNP class to try to forward the server
# port automatically when starting the server.
var peer = ENetMultiplayerPeer.new()
# --------------------------------------------------------------------------------------------------------- PROPERTIES #

# SIGNALS ------------------------------------------------------------------------------------------------------------ #

# Emitted when this MultiplayerAPI's multiplayer_peer fails to establish a
# connection to a server. Only emitted on clients.
signal peer_connected(peer_id)

# Emitted when this MultiplayerAPI's multiplayer_peer disconnects from a
# peer. Clients get notified when other clients disconnect from the same
# server.
signal peer_disconnected(peer_id)

# Emitted when this MultiplayerAPI's multiplayer_peer successfully
# connected to a server. Only emitted on clients.
signal connected_to_server

# Emitted when this MultiplayerAPI's multiplayer_peer fails to establish a
# connection to a server. Only emitted on clients.
signal connection_failed

# Emitted when this MultiplayerAPI's multiplayer_peer disconnects from a
# peer. Clients get notified when other clients disconnect from the same
# server.
signal server_disconnected

signal server_established

signal client_established
# ------------------------------------------------------------------------------------------------------------ SIGNALS #

func establish_server(uri: String = "*", port: int = 5000, max_clients: int = Settings.DEFAULT_MAX_NUM_CLIENTS):
	# 	Create server that listens to connections via port. The port needs to
	# 	be an available, unused port between 0 and 65535. Note that ports below
	# 	1024 are privileged and may require elevated permissions depending on
	# 	the platform.
	if peer.create_server(port, max_clients) != OK:
		Console.println("Failed to create server")
	# The IP used when creating a server. This is set to the wildcard "*" by
	# default, which binds to all available interface.
	peer.set_bind_ip(uri)
	multiplayer.set_multiplayer_peer(peer)
	multiplayer.peer_connected.connect(func(peer_id): peer_connected.emit(peer_id))
	multiplayer.peer_disconnected.connect(func(peer_id): peer_disconnected.emit(peer_id))
	_defer_signal(func(): server_established.emit())

func establish_client(uri: String = "localhost", port: int = 5000):
	# Create client that connects to a server at uri using specified port.
	if peer.create_client(uri, port) != OK:
		Console.println("Failed to create client")
	# The peer object to handle the RPC system (effectively enabling networking
	# when set). 
	multiplayer.set_multiplayer_peer(peer)
	multiplayer.connected_to_server.connect(func(): connected_to_server.emit())
	multiplayer.connection_failed.connect(func(): connection_failed.emit())
	multiplayer.server_disconnected.connect(func(): server_disconnected.emit())
	_defer_signal(func(): client_established.emit())
	
func unestablish():
	multiplayer.set_multiplayer_peer(null)


func _on_connected_to_server():
	Console.println("Connected to server.")


func _on_connection_failed():
	Console.println("Connection failed.")


func _on_peer_connected(peer_id):
	Console.println("Peer connected [%s]." % peer_id)


func _on_peer_disconnected(peer_id):
	Console.println("Peer disconnected [%s]." % peer_id)


func _on_server_disconnected():
	Console.println("Server disconnected.")
	
func _defer_signal(function) -> void:
	function.call_deferred()
