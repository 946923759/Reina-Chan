extends Node2D

export(int,-2,255) var LADDER_TILE_ID = -2
export(int,-2,255) var LADDER_TOP_TILE_ID = -2
export(int,-2,255) var SPIKES_TILE_ID = -2
export(int,-2,255) var DEATH_TILE_ID = -2 #Unlike spikes, these have no invincibility frames

export(bool) var adjust_camera = false

export (int) var leftBound = 0;
export (int) var topBound = 0;
export (int) var rightBound;
export (int) var bottomBound;
var cameraScale:float = 64;

export (String) var custom_music_name
export (String) var nsf_music_file
export (int) var nsf_track_num = 0
export (float,-8.0,8.0,.1) var nsf_volume_adjustment = 0.0
export (bool) var mute_music_in_debug=false
export (bool) var mute_boss_music_in_debug=false
#export (bool) var completely_disable_music=false
#var camera_multiplier = 16
export (Globals.Weapons) var weapon_to_unlock=0

#Why don't I just enumerate checkpoints?
#Because the checkpoints aren't in order and adding them to a checkpoint
#group or something takes more effort
var debug_warp_points
#This should probably be stored in the player right? I dunno lol
#var last_warped=0

var reinaAudioPlayer
#var curCharacter
var player:KinematicBody2D

func _ready():
	
	assert($PlayerHolder,"Hey genius, PlayerHolder is invalid!")
	assert($PlayerHolder.player,"Hey genius, there's no player!")
	player = $PlayerHolder.player
	
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D,SceneTree.STRETCH_ASPECT_KEEP,Vector2(1280,720))
	
	if $DebugWarpPoints.get_child_count()==0:
		debug_warp_points=[Vector2(0,0)]
	else:
		debug_warp_points = []
		for c in $DebugWarpPoints.get_children():
			debug_warp_points.append(c.global_position)
		
	update_easytiles()
	#else:
	#	print("Diff: "+Globals.difficultyToString(Globals.playerData.gameDifficulty))
	
	#set_process(true)
	if CheckpointPlayerStats.checkpointSet:
		print("There is a checkpoint, not adjusting the camera.")
	elif adjust_camera: #TODO: WHY IS THIS HERE INSTEAD OF CALLING CAMERACONTROLLERV2
		var c = player.get_node("Camera2D")
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
	
	reinaAudioPlayer = ReinaAudioPlayer.new(self)
	#var music = Globals.get_custom_music(custom_music_name) if custom_music_name != "" else null
	#load_song(_node:Node, custom_music_name:String, nsf_music_file:String, nsf_track_num:int)
	if !mute_music_in_debug or !OS.is_debug_build():
		reinaAudioPlayer.load_song(custom_music_name,nsf_music_file,nsf_track_num,nsf_volume_adjustment)

func update_easytiles():
	var easyTiles:TileMap = $EasyTiles
	if Globals.playerData.gameDifficulty > Globals.Difficulty.EASY:
		for i in range(8):
			easyTiles.set_collision_mask_bit(i,false)
			easyTiles.set_collision_layer_bit(i,false)
		easyTiles.visible=false
	else:
		easyTiles.set_collision_layer_bit(4,true)
		easyTiles.set_collision_layer_bit(5,true)
		easyTiles.set_collision_mask_bit(0,true)
		easyTiles.visible=true

#In case of multiplayer or future changes, always use this
#function
func get_player()->KinematicBody2D:
	return player

func playBossMusic(isM16:bool=false):
	if OS.is_debug_build() and mute_boss_music_in_debug:
		return
	print("playing boss music")
	reinaAudioPlayer.load_song("Boss","Rockman 6 UH.nsf",30)

func playMusic(cdAudioFileName:String,nsfAudioFileName:String,nsfAudioTrack:int=0):
	reinaAudioPlayer.load_song(cdAudioFileName,nsfAudioFileName,nsfAudioTrack)

#This is only ever used for the boss doors honestly
func fadeMusic(time:float=2):
	print("Got FadeMusic command")
	reinaAudioPlayer.fade_music(time)
	#var seq := get_tree().create_tween()

		#$AudioStreamPlayer.stop()
		
func stopMusic():
	reinaAudioPlayer.stop_music()

onready var tile_scale = $TileMap.scale
func pos2cell(pos):
	#TODO: Offset is wrong, fix it for real
	#pos minus 30 (why?) divided by quadrant size divided by tile scale
	return Vector2(round((pos.x-32)/16/tile_scale.x), round((pos.y-32)/16/tile_scale.y));

func cell2pos(pos:Vector2)->Vector2:
	return pos*16*tile_scale
