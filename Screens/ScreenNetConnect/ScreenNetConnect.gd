extends Control

# Default game server port. Can be any number between 1024 and 49151.
# Not present on the list of registered or common ports as of December 2022:
# https://en.wikipedia.org/wiki/List_of_TCP_and_UDP_port_numbers
#const DEFAULT_PORT = 8910

var peer = null

onready var buttonHost:Button = $VBoxContainer/HBoxNetServer/ButtonHost
onready var textboxHostPort:SpinBox = $VBoxContainer/HBoxNetServer/SpinBoxHostPort
onready var netServerStatus:Label = $VBoxContainer/LabelNetServerStatus
onready var buttonConnect:Button = $VBoxContainer/HBoxNetClient/ButtonClientConnect
onready var textboxClientAddress:TextEdit = $VBoxContainer/HBoxNetClient/TextEditClientDestination

func _ready():
	Input.set_mouse_mode(Input.MOUSE_MODE_VISIBLE)
	
	textboxHostPort.value = Globals.networkPort
	get_tree().connect("network_peer_connected", self, "_player_connected")
	#get_tree().connect("connected_to_server",self,"_connected_to_server")
	get_tree().connect("connection_failed",self,"_client_connection_failed")
	
	if Globals.networkMode == Globals.NetworkMode.SERVER:
		_on_ButtonHost_pressed()
	elif Globals.networkMode == Globals.NetworkMode.CLIENT:
		textboxClientAddress.text = Globals.networkClientAddress
		_on_ButtonClientConnect_pressed()

func _player_connected(peer_id):
	if get_tree().is_network_server():
		rpc("net_begin_game")

func _client_connection_failed():
	netServerStatus.text = "Failed to connect to host. Is it available?"

func _on_ButtonHost_pressed():
	#print(textboxHostPort.value)
	if peer:
		peer = null
		get_tree().network_peer = null
		buttonHost.text = "Host"
		netServerStatus.text = "Status: Inactive"
		buttonConnect.disabled = false
	else:
		peer = NetworkedMultiplayerENet.new()
		peer.create_server(textboxHostPort.value, 1) #Allow 1 more player to connect
		get_tree().network_peer = peer
		
		buttonHost.text = "Cancel"
		netServerStatus.text = "Waiting for a connection..."
		buttonConnect.disabled = true
	pass # Replace with function body.


func _on_ButtonClientConnect_pressed():
	if peer:
		peer = null
		get_tree().network_peer = null
		buttonConnect.text = "Connect"
		netServerStatus.text = "Status: Inactive"
		buttonHost.disabled = false
		return
		
	
	var ip_address = textboxClientAddress.text
	if not ip_address:
		ip_address = "127.0.0.1"
	
	var net_port = textboxHostPort.value
	if ":" in ip_address:
		var splits = ip_address.split(":")
		ip_address = splits[0]
		net_port = int(splits[1])
	
	#if not ip_address.is_valid_ip_address():
	#	netServerStatus.text = "IP address "+ip_address+" is invalid."
	#	return
	if net_port < 0 or net_port > 65535:
		netServerStatus.text = "Port "+net_port+" is invalid."
		return
		
	netServerStatus.text = "Connecting to "+ip_address+":"+String(net_port)+"..."
	peer = NetworkedMultiplayerENet.new()
	peer.create_client(ip_address,net_port)
	get_tree().network_peer = peer
	
	buttonConnect.text = "Cancel"
	buttonHost.disabled = true


remotesync func net_begin_game():
	Globals.change_screen(get_tree(),"ScreenSelectCharacter2P")

