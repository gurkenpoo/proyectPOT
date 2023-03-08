extends Node

@onready var mainMenu = $CanvasLayer/mainMenu
@onready var entry = $CanvasLayer/mainMenu/MarginContainer/VBoxContainer/addressentry
@onready var hud = $CanvasLayer/HUD
@onready var health_bar = $CanvasLayer/HUD/healthBar

const Player = preload("res://player.tscn")
const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()


func _on_host_button_pressed():
	mainMenu.hide()
	hud.show()
	
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(addPlayer)
	multiplayer.peer_disconnected.connect(remove_player)
	
	addPlayer(multiplayer.get_unique_id())
	
	upnp_setup()

func _on_join_button_pressed():
	mainMenu.hide()
	hud.show()
	enet_peer.create_client(entry.text, PORT)
	multiplayer.multiplayer_peer = enet_peer
	
func addPlayer(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)
	if player.is_multiplayer_authority():
		player.health_changed.connect(update_health_bar)
		
func remove_player(peer_id):
	var player = get_node_or_null(str(peer_id))
	if player:
		player.queue_free()
		
func update_health_bar(health_value):
	health_bar.value = health_value


func _on_multiplayer_spawner_spawned(node):
	if node.is_multiplayer_authority():
		node.health_changed.connect(update_health_bar)
		
func upnp_setup():
	var upnp = UPNP.new()
	
	var discover_result = upnp.discover()
	assert(discover_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP error! %s" % discover_result)
	
	assert(upnp.get_gateway() and upnp.get_gateway().is_valid_gateway(), \
		"UPNP invalid Gateway!")
		
	var map_result = upnp.add_port_mapping(PORT)
	assert(map_result == UPNP.UPNP_RESULT_SUCCESS, \
		"UPNP Port mapping failed Error %s" % map_result)
		
	print("Success! Join Address: %s" % upnp.query_external_address())
