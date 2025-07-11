extends Node2D
#Every day I wonder why I didn't just inherit the base script and modify it


#You CANNOT EDIT THESE VALUES IN THE SCRIPT!!!!
#Because this script is overriding a base scene
#you still need to edit the exported values in the node
#properties or it will be ignored!
export(int,-2,255) var LADDER_TILE_ID = -2
export(int,-2,255) var LADDER_TOP_TILE_ID = -2
export(int,-2,255) var SPIKES_TILE_ID = -2
export(int,-2,255) var DEATH_TILE_ID = -2 #Unlike spikes, these have no invincibility frames

export(bool) var adjust_camera = false

export (int) var leftBound = 0;
export (int) var topBound = 0;
export (int) var rightBound;
export (int) var bottomBound;

#var CAMERA_SCALE:float = 64;
const CAMERA_SCALE = 64;
const ROOM_WIDTH = 20
const ROOM_HEIGHT = 12

export (String) var custom_music_name
export (String) var nsf_music_file
export (int) var nsf_track_num = 0

export (String) var custom_music_name_pt2
export (String) var nsf_music_file_pt2
export (int) var nsf_track_num_pt2 = 0

export (bool) var mute_music_in_debug=false
export (bool) var mute_boss_music_in_debug=false

export (Globals.Weapons) var weapon_to_unlock=0

var debug_warp_points
#Not a wily stage obviously so it's 0
const wily_stage_num=0

var reinaAudioPlayer
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
	
	#set_process(true)
	if CheckpointPlayerStats.checkpointSet:
		print("There is a checkpoint, not adjusting the camera.")
	elif adjust_camera: #TODO: WHY IS THIS HERE INSTEAD OF CALLING CAMERACONTROLLERV2
		var c = player.get_node("Camera2D")
		#assert(c,"Hey genius, you have to name the player \"Player\" for the camera to work!")
		
		#We don't want to overwrite leftBound,rightBound, etc so keep the changed variables in a new array.
		var boundsArray = [null,null,null,null]
		if rightBound == -999:
			boundsArray[2] = leftBound*CAMERA_SCALE+Globals.gameResolution.x
		else:
			boundsArray[2] = rightBound*CAMERA_SCALE
			
		if leftBound == -999:
			boundsArray[0] = rightBound-Globals.gameResolution.x
		else:
			boundsArray[0] = leftBound*CAMERA_SCALE;
			#print("WARN: Left and right bounds are not defined. The camera won't work.")
		if bottomBound == -999:
			boundsArray[3] = topBound*CAMERA_SCALE+Globals.gameResolution.y
		else:
			boundsArray[3] = bottomBound*CAMERA_SCALE
		if topBound == -999:
			boundsArray[1] = bottomBound*CAMERA_SCALE-Globals.gameResolution.y
		else:
			boundsArray[1] = topBound*CAMERA_SCALE;
		
		assert(boundsArray[0] < boundsArray[2]);
		assert(boundsArray[1] < boundsArray[3]);
		c.adjustCamera(boundsArray, 0)
	
	reinaAudioPlayer = ReinaAudioPlayer.new(self)
	#var music = Globals.get_custom_music(custom_music_name) if custom_music_name != "" else null
	#load_song(_node:Node, custom_music_name:String, nsf_music_file:String, nsf_track_num:int)
	if !mute_music_in_debug or !OS.is_debug_build():
		if player.global_position.y < 84*64:
			reinaAudioPlayer.load_song(custom_music_name,nsf_music_file,nsf_track_num)
		else:
			reinaAudioPlayer.load_song(custom_music_name_pt2,nsf_music_file_pt2,nsf_track_num_pt2)

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

func playBossMusic():
	if OS.is_debug_build() and mute_boss_music_in_debug:
		return
	reinaAudioPlayer.load_song("Boss","Rockman 6 UH.nsf",30)

# null this out, bosses call it if the stage doesn't get finished but 
# There's already a music handler in this stage
func playMusic_2():
	pass
	
func fadeMusic():
	print("Got FadeMusic command")
	reinaAudioPlayer.fade_music(2)
		
func stopMusic():
	reinaAudioPlayer.stop_music()

func get_player()->KinematicBody2D:
	return player

onready var tile_scale = $TileMap.scale
func pos2cell(pos):
	#TODO: Offset is wrong, fix it for real
	#pos minus 30 (why?) divided by quadrant size divided by tile scale
	return Vector2(round((pos.x-32)/16/tile_scale.x), round((pos.y-32)/16/tile_scale.y));
func get_closest_room(glb_pos:Vector2):
	return Vector2(
		floor(glb_pos.x/CAMERA_SCALE/ROOM_WIDTH)*ROOM_WIDTH,
		floor(glb_pos.y/CAMERA_SCALE/ROOM_HEIGHT)*ROOM_HEIGHT
	)
	pass

func get_closest_room_border(glb_pos:Vector2)->Rect2:
	var topLeft = get_closest_room(glb_pos)
	var size = Vector2(topLeft.x+ROOM_WIDTH,topLeft.y+ROOM_HEIGHT)
	return Rect2(topLeft, size)
