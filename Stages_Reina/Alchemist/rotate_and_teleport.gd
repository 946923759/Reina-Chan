extends StaticBody2D

onready var tilemap = get_parent()
onready var root = get_node("/root/Node2D")

var event_ID = Globals.EVENT_TILES.CUSTOM_EVENT
var disabled:bool=false #Needed for event tiles, ignore it
#var running:bool=false

#export (String) var custom_music_name
#export (String) var nsf_music_file
#export (int) var nsf_track_num = 0

export (int) var leftBound = 0;
export (int) var topBound = 0;
export (int) var rightBound = 0;
export (int) var bottomBound = 0;

#export (Vector2) var current_room
export (Vector2) var destination_room_offset


var player
func run_event(_player:KinematicBody2D):
	print("Triggered!!!")
	if not disabled:
		disabled=true
		player = _player
		player.lockMovement(3,Vector2(0,0))
		set_process(true)
		#Doesn't work
		var seq := TweenSequence.new(get_tree())
		seq.append(tilemap,'rotation_degrees',180,3).set_trans(Tween.TRANS_QUAD)
		root.reinaAudioPlayer.fade_music()
		#var tween = $Tween;
		#tween.interpolate_property(tilemap, 'rotation_degrees',
		#null, 90, .25, Tween.TRANS_QUAD, Tween.EASE_OUT);
		#tween.start();
		seq.append_callback(self,"teleport_2")
		
func teleport_2():
		var cc = player.get_node("Camera2D")
		#LEFT,TOP,RIGHT,BOTTOM
		#cc.adjustCamera([-99999,-99999,99999,99999],0)
		cc.adjustCamera([leftBound*64,topBound*64,rightBound*64,bottomBound*64], 0)
		#var dest = (destination_room-current_room)
		#print("Teleported to"+String(dest))
		#The scale size is 64 and there are 20 blocks, so width is 1280
		#Additionally, the height is 12 blocks so 64*12
		player.position+=Vector2(destination_room_offset.x*1280,destination_room_offset.y*64*12)
		
		var custom_music_name = root.custom_music_name_pt2
		var nsf_music_file = root.nsf_music_file_pt2
		var nsf_track_num = root.nsf_track_num_pt2
		if !root.mute_music_in_debug or !OS.is_debug_build():
			root.reinaAudioPlayer.load_song(custom_music_name,nsf_music_file,nsf_track_num)
		#root.reinaAudioPlayer.play_music()

func _ready():
	
	"""if start_seconds == 1:
		spr.frame = 2
	elif start_seconds == 2:
		spr.frame = 1
	else:
		spr.frame = 0"""
	#spr.frame = 3-start_seconds
	#time=start_seconds
	set_process(false)
