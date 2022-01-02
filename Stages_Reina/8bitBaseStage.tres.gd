extends Node2D

export(int,-2,255) var LADDER_TILE_ID = -2
export(int,-2,255) var LADDER_TOP_TILE_ID = -2
export(int,-2,255) var SPIKES_TILE_ID = -2

export(bool) var adjust_camera = false

export (int) var leftBound = 0;
export (int) var topBound = 0;
export (int) var rightBound;
export (int) var bottomBound;
var cameraScale:float = 64;

export (String) var custom_music_name
export (String) var nsf_music_file
export (int) var nsf_track_num = 0
export (bool) var mute_music_in_debug=false
export (bool) var mute_boss_music_in_debug=false
#var camera_multiplier = 16

var reinaAudioPlayer

func _ready():
	#set_process(true)
	if CheckpointPlayerStats.checkpointSet:
		print("There is a checkpoint, not adjusting the camera.")
	elif adjust_camera: #TODO: WHY IS THIS HERE INSTEAD OF CALLING CAMERACONTROLLERV2
		var c = $Player/Camera2D
		#assert(c,"Hey genius, you have to name the player \"Player\" for the camera to work!")
		
		#We don't want to overwrite leftBound,rightBound, etc so keep the changed variables in a new array.
		var boundsArray = [null,null,null,null]
		if rightBound == -999:
			boundsArray[2] = leftBound*cameraScale+Globals.gameResolution.x
		else:
			boundsArray[2] = rightBound*cameraScale
			
		if leftBound == -999:
			boundsArray[0] = rightBound-Globals.gameResolution.x
		else:
			boundsArray[0] = leftBound*cameraScale;
			#print("WARN: Left and right bounds are not defined. The camera won't work.")
		if bottomBound == -999:
			boundsArray[3] = topBound*cameraScale+Globals.gameResolution.y
		else:
			boundsArray[3] = bottomBound*cameraScale
		if topBound == -999:
			boundsArray[1] = bottomBound*cameraScale-Globals.gameResolution.y
		else:
			boundsArray[1] = topBound*cameraScale;
		
		assert(boundsArray[0] < boundsArray[2]);
		assert(boundsArray[1] < boundsArray[3]);
		c.adjustCamera(boundsArray, 0)
	
	reinaAudioPlayer = Globals.ReinaAudioPlayer.new(self)
	#var music = Globals.get_custom_music(custom_music_name) if custom_music_name != "" else null
	#load_song(_node:Node, custom_music_name:String, nsf_music_file:String, nsf_track_num:int)
	if !mute_music_in_debug or !OS.is_debug_build():
		reinaAudioPlayer.load_song(custom_music_name,nsf_music_file,nsf_track_num)
		
func playBossMusic():
	if OS.is_debug_build() and mute_boss_music_in_debug:
		return
	reinaAudioPlayer.load_song("Boss","Rockman 6 UH.nsf",30)

func fadeMusic():
	print("Got FadeMusic command")
	reinaAudioPlayer.fade_music()
	#var seq := TweenSequence.new(get_tree())

		#$AudioStreamPlayer.stop()
		
func stopMusic():
	reinaAudioPlayer.stop_music()

onready var tile_scale = $TileMap.scale
func pos2cell(pos):
	#TODO: Offset is wrong, fix it for real
	#pos minus 30 (why?) divided by quadrant size divided by tile scale
	return Vector2(round((pos.x-32)/16/tile_scale.x), round((pos.y-32)/16/tile_scale.y));
