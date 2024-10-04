extends Node
#class_name Globals

#TODO: There's no need for these as they can be inserted into the OPTIONS table
var isFullscreen = false

# This value is set when you init a stage.
# Because M16 does not have cutscenes yet. So we need
# to disable it for her.
var playCutscenes = true

var flipButtons = false
#var textSpeed = 100

var eventMode = false

enum OPTION_FLAG {
	PC = 1       # Resolution options, quit game
	MOBILE = 2,  # Touch screen usually, quit game
	CONSOLE = 4, # No quit game button
	
	ALL = 7 #If not specified, will be this
}

#Access a value using OPTIONS[key]['value']
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
		"default":false,
		"flag":OPTION_FLAG.PC
	},
	"vsync":{
		"type":"bool",
		"default":false,
		"flag":OPTION_FLAG.PC
	},
	"language":{
		"type":"list",
		"choices":["en","es","kr","ja","zh"],
		"localizeKey":"Language",
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
	"Touchscreen":{
		"type":"bool",
		"default":true,
		"flag" : OPTION_FLAG.MOBILE
	}
}

enum Difficulty {
	BEGINNER=0,
	EASY,
	MEDIUM,
	HARD,
	SUPERHERO
}
#If you rearrange these for some reason you have to rearrange weaponColorSwaps
#This has to match the names in ScreenSelectStage too!
enum Weapons {
	Buster=0,
	Architect,
	Alchemist,
	Ouroboros,
	Scarecrow,
	NotAssigned,
	NotAssigned2,
	NotAssigned3,
	NotAssigned4,
	Glorylight,
	LENGTH_WEAPONS #Put this last
}
enum SpecialAbilities {
	AirDash=0,
	Grenade,
	LENGTH_ABILITIES #Put this last
}
var stagesToString = [ #Yeah it's stupid, I can't use macros so...
	"Buster",
	"Architect",
	"Alchemist",
	"Ouroboros",
	"Scarecrow",
	"???",
	"???",
	"???",
	"???",
	"Clear And Fail"
]
var abilitiesToString = [
	"Air Dash",
	"Grenade",
	"???",
	"???",
	"???",
	"???",
	"???",
	"???",
	"???"
]

# Weapon energy is some unknown number (Metal Blade from MM2 has 112 uses)
# but I think 144 is enough for everything.
# I think weapon energy in mega man is a float and it's 32, but since it's
# 144 here that means ammo restores 45 points.
# Either that or weapon energy is a different number for each weapon... Idk lol
var weaponEnergyCost = [
	0, #Buster
	9, #Architect 144/9 = 16 uses
	4, #Alchemist, 24 uses for dash
	6, #Ouroboros
	6, #Scarecrow
	0,
	0,
	0,
	0,
	24  #Glorylight
]

var weaponColorSwaps = [
	#R,G,B out of 100
	#UMP9 has two hair colors, so you have to adjust both!
	#Also colors are from 0 to 1.0
	[ #Default.... Also m16 default is in 8bitplayer because I'm dumb
		Color(.608,.467,.388),
		Color(.604,.627,.592)
	],
	[	#Architect 2
		Color(.949,.184,.184),
		Color(1,.51,.51)
		
	],
	[ #Alchemist
		Color(.964,.556,.19),
		Color(1,.718,.522)
	],
	[ #Ouroboros
		Color(0.564706, 0.027451, 0.368627),
		Color(0.768627, 0.313726, 0.752941)
	],
	[ #Scarecrow
		Color(0.235294, 0.235294, 0.235294),
		Color(0.627451, 0.627451, 0.627451)
	]
]

#Renaming this enum will break language files, so DON'T DO IT!
enum Characters {
	UMP9,
	M16A1,
	Ultimate_M16,
	LENGTH_CHARACTERS
}

func characterToString(d:int=playerData.currentCharacter)->String:
	return Characters.keys()[d]
#DO NOT TRANSLATE WITHIN THIS FUNCTION
#Some language keys use it for stuff like "desc_SUPERHERO"
func difficultyToString(d=playerData.gameDifficulty)->String:
	return Difficulty.keys()[d]

var playerData={
	gameDifficulty = Difficulty.EASY,
	currentCharacter = Characters.UMP9,
	isMultiplayer = false,
	
	#These values will get overwritten when you start a new save file,
	#So you can set them all to true for debugging purposes.
	#Setting a weapon to true that doesn't exist yet will crash the game.
	availableWeapons = [
		true,  #Buster (duh)
		true,  #Architect Rocket
		true,  #Alchemist Weapon
		true, #Ouroboros
		true,  #Scarecrow
		false,
		false,
		false,
		false,
		false,
		false #bonus stage (10)
	],
	specialAbilities = [
		true, #AirDash
		true, #Grenade
		
		#The rest are just in case I need to add future abilities.
		#But to be honest, I probably should have used a bit field
		#so this doesn't happen
		false, 
		false, 
		false,
		false,
		false,
		false
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

func reset_player_data():
	#Start at 1, the buster is always available!
	for i in range(1,len(playerData.availableWeapons)):
		playerData.availableWeapons[i]=false
	for i in range(len(playerData.specialAbilities)):
		playerData.specialAbilities[i]=false
	for i in range(len(playerData.ReinaChanEmblems)):
		playerData.ReinaChanEmblems[i]=false
	playerData.wilyStageNum = 0

#EXCLUDING THE OPTIONS! This is the 'extras' in the json.
var systemData:Dictionary = {
	if_you_can_see_this_you_are_a_cheater=false, #No, setting it to true won't do anything.
	unlocked_ZeroMode=false,
	unlocked_M16A1=true,
	unlocked_M16_Ultimate=false
}
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
		flipButtons=OPTIONS['flipButtons']['value']
		
		#Actually, this should only be set when the player pressed continue
		#gameDifficulty=dataToLoad['playerdata']['difficulty']
		#availableWeapons=dataToLoad['playerdata']['weapons']
		if 'extras' in dataToLoad:
			unlockedZeroMode=dataToLoad['extras']['zeroMode']
		save_game.close()
		print("System save data loaded.")
		#print(dataToLoad.options)
		return true

func load_player_game()->bool:
	var save_game = File.new()
	if not save_game.file_exists(get_save_directory('playerData')):
		return false
	save_game.open(get_save_directory('playerData'), File.READ)
	playerData=parse_json(save_game.get_as_text())
	if playerData.specialAbilities.size()<10:
		playerData.specialAbilities.resize(10)
	for i in range(10):
		if typeof(playerData.specialAbilities[i])!=TYPE_BOOL:
			playerData.specialAbilities[i]=false
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
		#"playerdata":playerData,
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
	#This doesn't work, playerHasSaveData will always be false!
	#if !playerHasSaveData:
	#	printerr("Attempted to save the player's game, but there's no savedata loaded!")
	#	return false
	var save_game = File.new()
	var ok = save_game.open(get_save_directory('playerData'),File.WRITE)
	if ok != OK:
		printerr("Warning: could not create file for writing! ERROR ", ok)
		#save_game.close() #Idk if it's still needed if open() failed
		return false
	save_game.store_line(to_json(playerData))
	save_game.close()
	print("Saved to "+get_save_directory('playerData'))
	playerHasSaveData=true
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

static func get_save_directory(fName:String)->String:
	match OS.get_name():
		"Windows","X11","macOS":
			if OS.has_feature("standalone"):
				return OS.get_executable_path().get_base_dir()+"/"+fName+".json"
	#If not compiled or if the platform doesn't allow writing to the game's current directory
	return "user://"+fName+".json"

var stage_cutscene_data:Dictionary = {}

func load_stage_cutscenes()->bool:
	var f = File.new()
	var path = "res://Screens/ScreenCutscene/Embedded/"
	match OS.get_name():
		"Windows","X11","macOS":
			if OS.has_feature("standalone"):
				path = OS.get_executable_path().get_base_dir()+"/GameData/Cutscene/"
				#break
	#"stage_cutscenes_oldSyntax.txt"
	var ok = f.open(path+"stage_cutscenes_oldSyntax.txt", File.READ)
	if ok != OK:
		printerr("Couldn't open the stage cutscenes! Ya done fucked it up! ERROR ", ok)
		printerr(path)
		return false
	
	#var langs = ["en","es","kr","ja","zh"]

	var d={'default':[]}
	var dictKey = "default"
	var langs = ['en']
	var langKeyFound:bool=false
	while !f.eof_reached():
		var line = f.get_line().strip_edges(false,true)
		#print(line)
		if line.begins_with('#KEY'):
			dictKey=line.lstrip("#KEY\t")
			d[dictKey]=[]
		elif !langKeyFound and line.begins_with("#LANGUAGES"):
			langs=line.lstrip("#LANGUAGES\t").split("\t",true)
			langKeyFound=true
		elif !line.empty():
			d[dictKey].push_back(line)
	stage_cutscene_data=d
	stage_cutscene_data['msgColumn']=1
	if INITrans.currentLanguage != "en":
		#print(cutsceneData['lang'])
		for i in range(langs.size()):
			if langs[i]==INITrans.currentLanguage:
				print("Loading from column "+String(i+1)+" ("+INITrans.currentLanguage+")")
				stage_cutscene_data['msgColumn']=i+1
				break
	#print("loaded stage cutscene data")
	return true
	
	
func get_stage_cutscene(key:String):
	if stage_cutscene_data.size() == 0:
		load_stage_cutscenes()
	if playerData.currentCharacter>0: #Search for M16 cutscene first
		if key+"_M16" in stage_cutscene_data:
			return stage_cutscene_data[key+"_M16"]
	if !(key in stage_cutscene_data): #Search for normal cutscene
		printerr("Tried to load cutscene "+key+" which does not exist")
		return stage_cutscene_data['error']
	return stage_cutscene_data[key] #If we got here there is a cutscene, return it

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
	
	var forcedFullscreen = 0
	for arg in OS.get_cmdline_args():
		print("Cmdline arg: "+arg)
		if arg.find("=") > -1:
			var kv = arg.split("=")
			if kv[0]=="--force-res":
				#print("Found cmdline arg --force-res="+kv[1])
				if kv[1].find("x") > -1:
					var w_h = kv[1].split('x')
					if w_h[0].is_valid_integer() and w_h[1].is_valid_integer():
						var w = int(w_h[0])
						var h = int(w_h[1])
						if w>0 and h>0:
							gameResolution=Vector2(w,h)
							OS.window_size = gameResolution
							OS.center_window()
			elif kv[0]=="--fullscreen":
				if kv[1].to_lower()=="true":
					forcedFullscreen=2
				else:
					forcedFullscreen=1
	
	
# warning-ignore:narrowing_conversion
	SCREEN_CENTER_X = gameResolution.x/2
# warning-ignore:narrowing_conversion
	SCREEN_CENTER_Y = gameResolution.y/2
	SCREEN_CENTER=Vector2(SCREEN_CENTER_X,SCREEN_CENTER_Y)
	
	print("Game resolution: "+String(gameResolution))
	
	
	if OS.has_feature("web"):
		NSF_location = "GameData/Music/"
	elif OS.has_feature("standalone"):
		NSF_location = OS.get_executable_path().get_base_dir()+"/GameData/Music/"
	else:
		NSF_location = "res://Music/"
	print(NSF_location)
	
	playerHadSystemData = load_system_data()
	if playerHadSystemData:
		set_audio_levels()
		#INITrans.SetLanguage("kr")
		INITrans.SetLanguage(OPTIONS["language"]['value'])
		#playCutscenes=OPTIONS['playCutscenes']['value']
		flipButtons=OPTIONS['flipButtons']['value']
	else:
		INITrans.SetLanguage("en")

	
	var save_game = File.new()
	playerHasSaveData=save_game.file_exists(get_save_directory('playerData'))
	
	if forcedFullscreen>0:
		print("User specified --fullscreen=true")
		set_fullscreen(forcedFullscreen==2)
	#It's annoying when I'm debugging
	elif !OS.is_debug_build():
		set_fullscreen(OPTIONS['isFullscreen']['value'])
	elif OPTIONS['isFullscreen']['value']:
		print("Fullscreen setting is ignored in debug.")
	
	OS.set_use_vsync(OPTIONS['vsync']['value'])

func _input(_event):
	if Input.is_action_just_pressed("FullscreenButton"):
		set_fullscreen(!OS.window_fullscreen)

func set_fullscreen(b):
	if b:
		OS.set_window_fullscreen(true)
	else:
		OS.set_window_fullscreen(false)
		OS.window_size = gameResolution
		OS.center_window()
#func set_language(new_lang:String=""):
#	if new_lang=="":
#		new_lang=OPTIONS['language']['value']
#	if new_lang!="system":
#		TranslationServer.set_locale(new_lang)
		
func set_audio_levels():
	# Audio starts at -60db (silent) and ends at 0db (max).
	# So the 0~100 volume is scaled to 0~80 then subtracted by 80 to
	# determine what to put the volume level at.
	
	var audios = {
		#The number corresponds to the position in default_bus_layout
		3:OPTIONS['AudioVolume']['value'],
		2:OPTIONS['SFXVolume']['value'],
		4:OPTIONS['SFXVolume']['value'],
		5:OPTIONS['SFXVolume']['value'],
		1:OPTIONS['VoiceVolume']['value']
	}
	for bus_idx in audios:
		var realVolumeLevel = audios[bus_idx]*.3-30
		#print(realVolumeLevel)
		if realVolumeLevel == -30:
			#instead of setting it to -80 just mute the bus to free up CPU
			AudioServer.set_bus_mute(bus_idx,true);
		else:
			AudioServer.set_bus_volume_db(bus_idx,realVolumeLevel)
			AudioServer.set_bus_mute(bus_idx,false)

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
	STAGE_COMPLETED,
	#KILL_PLAYER # Needed for moving death planes
}


# HELPERS
static func get_matching_files(path,fname):
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
		#print(file)
		if file == "":
			dir.list_dir_end()
			return null
		elif file.begins_with(fname):
			print("Found file:"+file)
			#print("Return "+path+file)
			dir.list_dir_end()
			return path+file


static func get_custom_music(fname):
	if !ReinaAudioPlayer.is_nsf_supported():
		return get_matching_files("res://Music/CDAudio/",fname)
	elif OS.has_feature("standalone"):
		return get_matching_files(OS.get_executable_path().get_base_dir()+"/CustomMusic/",fname)

var nsf_player
func _init():
	if ReinaAudioPlayer.is_nsf_supported():
		nsf_player = FLMusicLib.new();
		nsf_player.set_gme_buffer_size(2048*5);#optional
		#print("Init!!")


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

# This will 'reverse' your array because binary is 'right' sided.
# In other words, doing arr[4] would be ret & 1<<4 to check if arr[4] is true.
static func bitArrayToInt32(arr:Array)->int:
	var ret:int = 0;
	var tmp:int;
	for i in range(len(arr)):
		tmp = arr[i]; #0 or 1, this abuses the fact that booleans are '1' if you cast them as ints
		# Bitwise inclusive OR...
		# Shift tmp left by i (so it starts rightmost)
		# then OR it so it sets that bit on ret. If tmp is 0, no effect.
		ret |= tmp<<i;
	return ret;

var SCREENS:Dictionary = {
	"ScreenInit":'res://Screens/ScreenInit/InitLogo.tscn',
	"ScreenDisclaimer":"res://Screens/BetaDisclaimer.tscn",
	"ScreenHowToPlay":"res://Screens/ScreenHowToPlay/ScreenHowToPlay.tscn",
	"ScreenOpening":"res://Screens/ScreenOpening/ScreenOpening.tscn",
	
	"ScreenTitleMenu":"res://Screens/ScreenTitleMenu/ScreenTitleMenuV3.tscn",
	"ScreenTitleJoin":"res://Screens/ScreenTitleJoin/ScreenTitleJoinV3.tscn",
	"ScreenSelectCharacter":"res://Screens/ScreenSelectCharacter/ScreenSelectCharacter.tscn",
	"ScreenSelectStage":"res://Screens/ScreenStageSelectV2/ScreenSelectStage.tscn",
	"ScreenStageIntro":"res://Screens/ScreenStageIntro.tscn",
	"ScreenSangvisIntro":"res://Screens/ScreenStageIntroSangvis/StageIntroSangvis.tscn",
	"ScreenItemGet":"res://Screens/ScreenItemGet/ScreenItemGet.tscn",

	"CutsceneFromFile":"res://Screens/ScreenCutscene/CutsceneFromFile.tscn",
	"CutsceneDemoEnd":"res://Screens/ScreenCutscene/cutsceneWhatever.tscn",
	"ScreenCredits":"res://Screens/Credits.tscn",
	"ScreenJukebox":"res://Screens/ScreenJukebox/ScreenJukebox.tscn",
	
	"ScreenDebugSelect":"res://Screens/ScreenDebugLvSelect/ScreenDebugLvSelect.tscn",
	
	"MMZeroTest":"res://Stages/TestStage/TestStage.tscn",
	"PIURED_ScreenGameplay":"res://Stages_Reina/Clear_And_Fail/PIURED/GameObjects/ScreenGameplay.tscn"
}

var STAGES_REINA:Dictionary = {
	"Alchemist":"res://Stages_Reina/Alchemist/Alchemist_v2.tscn",
	"Architect":"res://Stages_Reina/Architect/StageArchitect_v2.tscn",
	"Ouroboros":"res://Stages_Reina/Ouroboros/StageOuroboros.tscn",
	"Scarecrow":"res://Stages_Reina/Scarecrow/Scarecrow.tscn",
	"None1":"",
	"None2":"",
	"None3":"",
	"None4":"",
	"SF_1":"res://Stages_Reina/Sangvis1/StageSangvis1.tscn",
	"SF_2":"res://Stages_Reina/Sangvis2/StageSangvis2.tscn",
	"SF_3":"res://Stages_Reina/Sangvis3/Sangvis3.tscn",
	"SF_4":"res://Stages_Reina/Sangvis4/Sangvis4.tscn",
	"Talk Hub":"res://Stages_Reina/StageTalkHub.tscn",
	"TEST_STAGE":"res://Stages_Reina/TestStage.tscn",
	"NSF_TEST":"res://Stages_Reina/TestStage_NSF/TestStage_NSF.tscn",
	"NSF_TEST_2":"res://Stages_Reina/TestStage_NSF/TestStage_NSF_2.tscn",
	"SCARECROW_BOSS_TEST":"res://Stages_Reina/ScarecrowTestRoom.tscn",
	"mm2wily1":"res://Stages/mm2wily/stgWily.tscn",
	#"CAMERA_ZOOM_TEST":"res://Stages/IntroStageTest/Stage.tscn"
	"MULTIPLAYER_TEST":"res://Stages_Reina/RoomsTest.tscn"
}

var previous_screen = ""
func change_screen(tree,screen:String)->void:
	tree.change_scene(SCREENS[screen])
