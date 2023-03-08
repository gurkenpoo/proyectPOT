extends Node

@onready var mainMenu = $CanvasLayer/mainMenu
@onready var entry = $CanvasLayer/mainMenu/MarginContainer/VBoxContainer/addressentry

const Player = preload("res://player.tscn")
const PORT = 9999
var enet_peer = ENetMultiplayerPeer.new()

func _unhandled_input(event):
	if Input.is_action_just_pressed("quit"):
		get_tree().quit()


func _on_host_button_pressed():
	mainMenu.hide()
	
	enet_peer.create_server(PORT)
	multiplayer.multiplayer_peer = enet_peer
	multiplayer.peer_connected.connect(addPlayer)
	
	addPlayer(multiplayer.get_unique_id())

func _on_join_button_pressed():
	mainMenu.hide()
	
	enet_peer.create_client("localhost", PORT)
	multiplayer.multiplayer_peer = enet_peer
func addPlayer(peer_id):
	var player = Player.instantiate()
	player.name = str(peer_id)
	add_child(player)
