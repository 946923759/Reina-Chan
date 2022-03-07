extends Node
#class_name Globals

#TODO: There's no need for these as they can be inserted into the OPTIONS table
#var AudioVolume = 100
#var SFXVolume = 100
var isFullscreen = false
var playCutscenes = true
var flipButtons = false
#var textSpeed = 100

var OPTIONS = {
	"AudioVolume":{
		"type":"int",
		"choices":[10,20,30,40,50,60,70,80,90,100], #this isn't used at all lol
		"default":100
	},
	"SFXVolume":{
		"type":"int",
		"choices":[10,20,30,40,50,60,70,80,90,100],
		"default":100
	},
	"VoiceVolume":{
		"type":"int",
		"choices":[10,20,30,40,50,60,70,80,90,100],
		"default":90
	},
	"isFullscreen":{
		"type":"bool",
		"default":false
	},
	"language":{
		"type":"list",
		"choices":["en","es","kr","ja","zh"],
		"default":"en"
	},
	"flipButtons":{
		"type":"bool",
		"default":false
	},
	"playCutscenes":{
		"type":"bool",
		"default":true
	},
	"TextSpeed":{
		"type":"int",
		"choices":[10,20,30,40,50,60,70,80,90,100],
		"default":80
	},
	"showTimer":{
		"type":"bool",
		"default":false
	},
	"SFA3Announcer":{
		"type":"bool",
		"default":true
	},
	#"Touchscreen":{
	#	"type":"bool",
	#	"default":(OS.has_feature("mobile"))
	#}
}

enum Difficulty {
	BEGINNER,
	EASY,
	MEDIUM,
	HARD,
	SUPERHERO
}
#If you rearrange these for some reason you have to rearrange weaponColorSwaps
enum Weapons {
	Buster=0,
	Architect,
	Alchemist,
	Scarecrow
}

var playerData={
	gameDifficulty = Difficulty.EASY,
	availableWeapons = [
		true,
		false, #Architect Rocket
		false,
		false,
		false,
		false,
		false,
		false,
		false,
		false,
		false #bonus stage (10)
	],
	wilyStageNum = 0,
	ReinaChanEmblems=[ #U M P 9 C H A N
		false, 
		false,
		false,
		false,
		false,
		false,
		false,
		false
	]
}

#DO NOT TRANSLATE WITHIN THIS FUNCTION
#Some language keys use it for stuff like "desc_SUPERHERO"
func difficultyToString(d=playerData.gameDifficulty)->String:
	return Difficulty.keys()[d]


# Weapon energy is some unknown number (Metal Blade from MM2 has 112 uses)
# but I think 144 is enough for everything.
# I think weapon energy in mega man is a float and it's 32, but since it's
# 144 here that means ammo restores 45 points.
# Either that or weapon energy is a different number for each weapon... Idk lol
var weaponEnergyCost = [
	0,
	9 #144/9 = 16 uses
]

var weaponColorSwaps = [
	#R,G,B out of 100
	#UMP9 has two hair colors, so you have to adjust both!
	#Also colors are from 0 to 1.0
	[ #Default
		Color(.608,.467,.388),
		Color(.604,.627,.592)
	],
	[	#Architect 2
		Color(.949,.184,.184),
		Color(1,.51,.51)
		
	],
	[ #Architect
		Color(.918,.698,.369),
		Color(.918,.788,.060)
	]
]

var unlockedZeroMode:bool=false

var playerHasSaveData:bool=false
var playerHadSystemData:bool=false

func load_system_data()->bool:
	var save_game = File.new()
	if not save_game.file_exists(get_save_directory('systemData')):
		for option in OPTIONS:
			OPTIONS[option]['value'] = OPTIONS[option]['default']
		return false
	else:
		save_game.open(get_save_directory('systemData'), File.READ)
		var dataToLoad=parse_json(save_game.get_as_text())
		#TODO: what if an option gets removed?
		for option in OPTIONS:
			if option in dataToLoad['options']:
				OPTIONS[option]['value'] = dataToLoad['options'][option]
			else:
				OPTIONS[option]['value'] = OPTIONS[option]['default']
		flipButtons=Globals.OPTIONS['flipButtons']['value']
		
		#Actually, this should only be set when the player pressed continue
		#gameDifficulty=dataToLoad['playerdata']['difficulty']
		#availableWeapons=dataToLoad['playerdata']['weapons']
		if 'extras' in dataToLoad:
			unlockedZeroMode=dataToLoad['extras']['zeroMode']
		save_game.close()
		print("System save data loaded.")
		return true

func load_player_game()->bool:
	var save_game = File.new()
	if not save_game.file_exists(get_save_directory('playerData')):
		return false
	save_game.open(get_save_directory('playerData'), File.READ)
	playerData=parse_json(save_game.get_as_text())
	save_game.close()
	print("Player save data loaded.")
	return true

func save_system_data()->bool:
	var save_game = File.new()
	var ok = save_game.open(get_save_directory('systemData'),File.WRITE)
	if ok != OK:
		printerr("Warning: could not create file for writing! ERROR ", ok)
		return false
	var dataToSave = {
		"options":{},
		"playerdata":playerData,
		"extras":{
			"zeroMode":unlockedZeroMode
		}
	}
	for option in OPTIONS:
		dataToSave['options'][option]=OPTIONS[option]['value']
	save_game.store_line(to_json(dataToSave))
	save_game.close()
	print("Saved to "+get_save_directory('systemData'))
	return true
	
func save_player_game()->bool:
	var save_game = File.new()
	var ok = save_game.open(get_save_directory('playerData'),File.WRITE)
	if ok != OK:
		printerr("Warning: could not create file for writing! ERROR ", ok)
		#save_game.close() #Idk if it's still needed if open() failed
		return false
	save_game.store_line(to_json(playerData))
	save_game.close()
	print("Saved to "+get_save_directory('playerData'))
	Globals.playerHasSaveData=true
	return true

var gameResolution:Vector2;
var SCREEN_CENTER:Vector2
var SCREEN_CENTER_X:int
var SCREEN_CENTER_Y:int
#onready var GAME_DIRECTORY = OS.get_executable_path().get_base_dir()
# MusicMappings
var NSF_location;

#The stage to load.
var nextStage
#For the item get screen... If 0, item will be skipped
var nextStageWeaponNum:int=0

# The name of the next cutscene to load from Cutscene/ or GameData/Cutscene
# if we're using the "cutscene from file" scene
var nextCutscene:String="cutscene1Data.txt"

func get_save_directory(fName:String)->String:
	match OS.get_name():
		"Windows","X11","macOS":
			if OS.has_feature("standalone"):
				return OS.get_executable_path().get_base_dir()+"/"+fName+".json"
	#If not compiled or if the platform doesn't allow writing to the game's current directory
	return "user://"+fName+".json"

var stage_cutscene_data:Dictionary = {}

func load_stage_cutscenes()->bool:
	var f = File.new()
	var path = "res://Cutscene/"
	match OS.get_name():
		"Windows","X11","macOS":
			if OS.has_feature("standalone"):
				path = OS.get_executable_path().get_base_dir()+"/GameData/Cutscene/"
				#break
	var ok = f.open(path+"stage_cutscenes.txt", File.READ)
	if ok != OK:
		printerr("Couldn't open the stage cutscenes! Ya done fucked it up! ERROR ", ok)
		return false
	
	var langs = ["en","es","kr","ja","zh"]
	var msgColumn:int=1
	if INITrans.currentLanguage != "en":
		#print(cutsceneData['lang'])
		for i in range(langs.size()):
			if langs[i]==INITrans.currentLanguage:
				print("Loading from column "+String(i+1)+" ("+INITrans.currentLanguage+")")
				msgColumn=i+1
				break
	var d={'default':[]}
	var dictKey = "default"
	while !f.eof_reached():
		var line = f.get_line().strip_edges(false,true)
		#print(line)
		if line.begins_with('#KEY'):
			dictKey=line.lstrip("#KEY\t")
			d[dictKey]=[]
		elif !line.empty():
			if line.begins_with('msg'):
				#print(line)
				var aa = line.split('\t',true)
				if msgColumn < aa.size():
					d[dictKey].push_back('msg\t'+aa[msgColumn])
				else:
					d[dictKey].push_back('msg\t'+aa[1])
			else:
				d[dictKey].push_back(line)
	stage_cutscene_data=d
	#print("loaded stage cutscene data")
	return true
	
	
func get_stage_cutscene(key:String):
	if stage_cutscene_data.size() == 0:
		load_stage_cutscenes()
	return stage_cutscene_data[key]

func _ready():
	#print(OS.window_size)
	#print(get_viewport().size)
	#DUDE WHAT IF WE JUST HAD THIS FUNCTION AND NEVER DOCUMENTED IT ANYWHERE
	#EVEN THOUGH IT'S THE ONE YOU ACTUALLY WANT AND YOU HAVE TO CHECK A REDDIT
	#POST TO FIND IT
	# - The godot devs probably
	#print(get_viewport().get_visible_rect().size)
	
	#gameResolution = Vector2(ProjectSettings.get_setting("display/window/size/width"),ProjectSettings.get_setting("display/window/size/height"))
	gameResolution = get_viewport().get_visible_rect().size
# warning-ignore:narrowing_conversion
	SCREEN_CENTER_X = gameResolution.x/2
# warning-ignore:narrowing_conversion
	SCREEN_CENTER_Y = gameResolution.y/2
	SCREEN_CENTER=Vector2(SCREEN_CENTER_X,SCREEN_CENTER_Y)
	
	print("Game resolution: "+String(gameResolution))
	
	
	if OS.has_feature("standalone"):
		NSF_location = OS.get_executable_path().get_base_dir()+"/GameData/Music/"
	else:
		NSF_location = "res://Music/"
	
	playerHadSystemData = load_system_data()
	if playerHadSystemData:
		set_audio_levels()
		#INITrans.SetLanguage("kr")
		INITrans.SetLanguage(Globals.OPTIONS["language"]['value'])
		playCutscenes=Globals.OPTIONS['playCutscenes']['value']
		flipButtons=Globals.OPTIONS['flipButtons']['value']
	else:
		INITrans.SetLanguage("en")

	
	var save_game = File.new()
	playerHasSaveData=save_game.file_exists(get_save_directory('playerData'))
	
	#It's annoying when I'm debugging
	if !OS.is_debug_build():
		set_fullscreen(OPTIONS['isFullscreen']['value'])
	else:
		print("Fullscreen setting is ignored in debug.")

func set_fullscreen(b):
	if b:
		OS.set_window_fullscreen(true)
	else:
		OS.set_window_fullscreen(false)
		OS.window_size = gameResolution
		OS.center_window()
		
#func set_language(new_lang:String=""):
#	if new_lang=="":
#		new_lang=Globals.OPTIONS['language']['value']
#	if new_lang!="system":
#		TranslationServer.set_locale(new_lang)
		
func set_audio_levels():
	# Audio starts at -60db (silent) and ends at 0db (max).
	# So the 0~100 volume is scaled to 0~80 then subtracted by 80 to
	# determine what to put the volume level at.
	
	var audios = {
		3:Globals.OPTIONS['AudioVolume']['value'],
		2:Globals.OPTIONS['SFXVolume']['value'],
		1:Globals.OPTIONS['VoiceVolume']['value']
	}
	for d in audios:
		var realVolumeLevel = audios[d]*.3-30
		#print(realVolumeLevel)
		if realVolumeLevel == -30:
			#instead of setting it to -80 just mute the bus to free up CPU
			AudioServer.set_bus_mute(d,true);
		else:
			AudioServer.set_bus_volume_db(d,realVolumeLevel)
			AudioServer.set_bus_mute(d,false)

#DO NOT REARRANGE THIS OR IT WILL BREAK EVERYTHING!!!!!
#The event tile parameters are stored as ints!
enum EVENT_TILES {
	NO_EVENT = 0, #Just so I don't place a tile and have it default to IN_WATER
	IN_WATER, 
	OUT_WATER,
	MESSAGE_BOX,
	MESSAGE_BOX_OPTIONAL, #Press up to view an optional message box.
	MESSAGE_POPUP, #Unlike the message box, this doesn't interrupt gameplay.
	NO_MESSAGE_POPUP, #Remove the popup, if you set it to last forever
	CHECKPOINT,
	CUSTOM_EVENT, #Runs a function run_event() if a player touched it. The player is passed to the event.
	SIGNAL, #It triggers a signal
}


# HELPERS
func get_matching_files(path,fname):
	#var files = []
	var dir = Directory.new()
	print("Opening "+path)
	var ok = dir.open(path)
	if ok != OK:
		printerr("Warning: could not open directory: ERROR ", ok)
		return null
	#print(dir.get_current_dir())
	dir.list_dir_begin(false,true)

	while true:
		var file = dir.get_next()
		print(file)
		if file == "":
			dir.list_dir_end()
			return null
		elif file.begins_with(fname):
			print("Found file:"+file)
			#print("Return "+path+file)
			dir.list_dir_end()
			return path+file

func get_custom_music(fname):
	if !OS.has_feature("standalone"):
		return null
	elif OS.has_feature("console"):
		return Globals.get_matching_files("res://Music/CDAudio/",fname)
	return Globals.get_matching_files(OS.get_executable_path().get_base_dir()+"/CustomMusic/",fname)

var nsf_player
func _init():
	if !OS.has_feature("console"):
		nsf_player = FLMusicLib.new();
		nsf_player.set_gme_buffer_size(2048*5);#optional
		#print("Init!!")

class ReinaAudioPlayer:
	var node:Node;
	var audioStreamPlayer;
	var nsf_player
	var added_nsf_player:bool=false
	#var is_fading_music:bool=false
	
	func _init(_node:Node):
		node = _node;
		audioStreamPlayer=node.get_node("AudioStreamPlayer")
	
	func load_song(custom_music_name:String, nsf_music_file:String, nsf_track_num:int,nsf_volume_adjustment:float=0):
		
		var music = Globals.get_custom_music(custom_music_name) if custom_music_name != "" else null
		if music != null:
			print("Attempting to load "+music)
			if music.ends_with(".import"):
				audioStreamPlayer.stream = load(music.replace('.import', ''))
			else:
				audioStreamPlayer.stream = ExternalAudio.loadfile(music)
			audioStreamPlayer.play()
			audioStreamPlayer.volume_db=0.0
		elif nsf_music_file != "" and !OS.has_feature("console"):
			if !is_instance_valid(Globals.nsf_player):
				print("The NSF player has expired somehow... Trying to re-init")
				Globals.nsf_player = FLMusicLib.new();
				Globals.nsf_player.set_gme_buffer_size(2048*5);#optional
				
			nsf_player = Globals.nsf_player
			if !added_nsf_player:
				node.add_child(nsf_player);
				nsf_player.set_pause_mode(2) #Node.PAUSE_MODE_PROCESS
				added_nsf_player=true
			#print(Globals.NSF_location+nsf_music_file)
			print("(NSF) Trying to play "+Globals.NSF_location+nsf_music_file)
			nsf_player.play_music(Globals.NSF_location+nsf_music_file,nsf_track_num,false,0,0,0);
			var realVolumeLevel = Globals.OPTIONS['AudioVolume']['value']*.3-30
			#print("Volume level is "+String(realVolumeLevel))
			nsf_player.set_volume(realVolumeLevel+nsf_volume_adjustment);
		else:
			print("No custom music specified and this platform doesn't support NSF. That means there's no music!")
	
	#This is actually a terrible idea because if you play a new song before this tween finishes
	#the music stays at a really low volume
	func fade_music(time:float=3.0):
		stop_music()
		return
		
		if added_nsf_player:
			#nsf_player.stop_music()
			#print("Stopped NSF player")
			var t := Tween.new()
			node.add_child(t)
			t.set_pause_mode(2) #Node.PAUSE_MODE_PROCESS
			#var realVolumeLevel = Globals.OPTIONS['AudioVolume']['value']*.3-30
			t.interpolate_method(nsf_player,"set_volume",0,-15.0,time)
			t.start()
			yield(t,"tween_completed")
			nsf_player.stop_music()
			#nsf_player.set_volume(realVolumeLevel)
			#seq.append(nsf_player,"toDraw",CONST_IMG_WIDTH,2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
		elif audioStreamPlayer.is_playing():
			var seq := TweenSequence.new(node.get_tree())
			seq._tween.pause_mode = Node.PAUSE_MODE_PROCESS
			seq.append(audioStreamPlayer,"volume_db",-10,time).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
# warning-ignore:return_value_discarded
			seq.append_callback(audioStreamPlayer,"stop")
			
	func stop_music():
		#print("Stopping ReinaAudioPlayer")
		if nsf_player != null:
			#print("Stopped NSF")
			nsf_player.stop_music()
		else:
			#print("Stopped CDAudio")
			audioStreamPlayer.stop()
			
	func pause_music():
		pass


#https://godotengine.org/qa/32785/is-there-simple-way-to-convert-seconds-to-hh-mm-ss-format-godot
enum TimeFormat {
	FORMAT_HOURS   = 1 << 0,
	FORMAT_MINUTES = 1 << 1,
	FORMAT_SECONDS = 1 << 2,
	FORMAT_MILISECONDS = 1 << 3
}
#var FORMAT_DEFAULT = TimeFormat.FORMAT_HOURS | TimeFormat.FORMAT_MINUTES | TimeFormat.FORMAT_SECONDS
var FORMAT_DEFAULT = TimeFormat.FORMAT_MINUTES|TimeFormat.FORMAT_SECONDS|TimeFormat.FORMAT_MILISECONDS

func format_time(time, format = FORMAT_DEFAULT, digit_format = "%02d"):
	var digits = []

	if format & TimeFormat.FORMAT_HOURS:
		var hours = digit_format % [time / 3600]
		digits.append(hours)

	if format & TimeFormat.FORMAT_MINUTES:
		var minutes = digit_format % [time / 60]
		digits.append(minutes)

	if format & TimeFormat.FORMAT_SECONDS:
		var seconds = digit_format % [int(floor(time)) % 60]
		digits.append(seconds)

	var formatted = String()
	var colon = ":"

	for digit in digits:
		formatted += digit + colon

	if not formatted.empty():
		formatted = formatted.rstrip(colon)
	
	if format & TimeFormat.FORMAT_MILISECONDS:
		var ms:float = fmod(time,1.0)*1000
		formatted+=".%03d"%ms
		#formatted+=String(time)

	return formatted
