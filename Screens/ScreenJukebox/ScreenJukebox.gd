extends Control

var bitmap = preload("res://ubuntu-font-family/BitmapFont.tscn")
var reinaAudioPlayer

onready var beep = $Beep
onready var audioStreamPlayer = $AudioStreamPlayer
onready var bigScroll1 = $SelectSongBigScroller
onready var bigScroll2 = $SelectSongBigScroller2
onready var smallScroll1 = $SelectSongSmallScroller
onready var smallScroll2 = $SelectSongSmallScroller2

onready var scroller1size:Vector2 = $SelectSongBigScroller/s1.get_size()
onready var scroller2size:Vector2 = $SelectSongSmallScroller/s1.get_size()

var audio_database:Array = []
var selection:int = 0

class music_entry:
	var for_screen:String
	var title:String
	var album:String
	var artist:String
	var audio_file:String
	var track_num:int = -1
	
	func init(for_screen_, title_, album_, artist_, audio_file_, track_num_:int = -1):
		for_screen = for_screen_
		title = title_
		album = album_
		artist = artist_
		audio_file = audio_file_
		track_num = track_num_
	
#func gen_entry(s:String) -> music_entry:
#	var splits = 

func _ready():
	reinaAudioPlayer=ReinaAudioPlayer.new(self)
	
	bigScroll1.get_node("s2").position.x = scroller1size.x
	bigScroll2.get_node("s2").position.x = scroller1size.x
	
	smallScroll1.get_node("s2").position.x = scroller2size.x
	smallScroll2.get_node("s2").position.x = scroller2size.x

	var f = File.new()
	var ok = f.open("res://Music/database.txt",File.READ)
	if ok != OK:
		printerr("Failed to open "+"res://Music/database.txt")
		var o = music_entry.new()
		o.title = "ERROR"
		o.album = "ERROR"
		o.artist = "ERROR"
		o.audio_file = "opening.wav"
		audio_database.append(o)
	else:
		var category_to_search="NSF AUDIO"
		if reinaAudioPlayer.is_nsf_supported() == false:
			category_to_search = "CD AUDIO"
		
		var category="NONE"
		while !f.eof_reached():
			var line:String = f.get_line().strip_edges()
			
			if line.begins_with("--"):
				category = line.substr(2)
				continue
			if category != category_to_search:
				continue
			
			var splits = line.split("\t",true)
			if len(splits) == 5:
				splits.append("-1")
			if len(splits) >= 6:
				var o = music_entry.new()
				o.init(splits[0], splits[1], splits[2], splits[3], splits[4], int(splits[5]))
				audio_database.append(o)
			else:
				print("Invalid entry in audio db: "+String(splits))
				
	var center = $selector/CurrentSelection.get_size("12345678901234567890").x / 2
	$selector/CurrentSelection.position.x = -center
	$selector/leftArrow.position.x = -center - 8*2
	$selector/rightArrow.position.x = center
	update_selection(false)

func update_selection(play_sound:bool=true):
	#selection = new_sel
	#if play_sound:
	#	$Beep.play()
	$selector/CurrentSelection.text = String(selection+1)+". " +audio_database[selection].for_screen
	

func _process(delta):
	#Set y position every frame
	var SCREEN_SIZE = self.rect_size
	bigScroll2.position.y = SCREEN_SIZE.y - scroller1size.y - 10
	smallScroll2.position.y = SCREEN_SIZE.y - scroller2size.y - 80
	
	# Control x position scrolling
	bigScroll1.position.x -= delta * 200;
	if bigScroll1.position.x < -scroller1size.x:
		bigScroll1.position.x += scroller1size.x
		
	smallScroll1.position.x -= delta * 100;
	if smallScroll1.position.x < -scroller2size.x:
		smallScroll1.position.x += scroller2size.x
	
	#Is there a smarter way to do this? Can it be flipped from the above somehow?
	bigScroll2.position.x += delta * 200;
	if bigScroll2.position.x > 0:
		bigScroll2.position.x -= scroller1size.x
	smallScroll2.position.x += delta * 100;
	if smallScroll2.position.x > 0:
		smallScroll2.position.x -= scroller2size.x
	#bigScroll2.position.x = bigScroll1.position.x
	#smallScroll2.position.x = smallScroll1.position.x
		#print("reset")
		
	$NowPlaying.position.x = SCREEN_SIZE.x/2
	$selector.position.x = SCREEN_SIZE.x/2
	if SCREEN_SIZE.y > 720 and SCREEN_SIZE.y < 1000:
		var scale = SCREEN_SIZE.y/720.0
		$NowPlaying.scale = Vector2(scale,scale)
		$NowPlaying.position.y = SCREEN_SIZE.y-300*scale
	pass
	
	var old_sel = selection
	if Input.is_action_just_pressed("ui_left"):
		if selection > 0:
			selection -= 1
		else:
			selection = len(audio_database)-1
	elif Input.is_action_just_pressed("ui_right"):
		if selection < len(audio_database)-1:
			selection += 1
		else:
			selection = 0
	elif Input.is_action_just_pressed("ui_accept"):
		#reinaAudioPlayer.stop_music()
		
		var sel:music_entry = audio_database[selection]
		#print("Playing")
		if sel.track_num < 0:
			reinaAudioPlayer.stop_music()
			
			if reinaAudioPlayer.is_nsf_supported(): #
				#print("Trying to play "+sel.audio_file)
				var music = "res://Music/"+sel.audio_file
				print("Attempting to load "+music)
				audioStreamPlayer.stream = load(music)
				audioStreamPlayer.play()
				audioStreamPlayer.volume_db=0.0
			else:
				var music = Globals.get_custom_music(sel.audio_file)
				if music:
					audioStreamPlayer.stream = ExternalAudio.loadfile(music)
					audioStreamPlayer.play()
				#reinaAudioPlayer.load_song(sel.audio_file,"",0)
		else:
			audioStreamPlayer.stop()
			reinaAudioPlayer.load_song("",sel.audio_file,sel.track_num)
		
		$NowPlaying.set_info(sel.title,sel.album,sel.artist)
	elif Input.is_action_just_pressed("ui_cancel"):
		reinaAudioPlayer.stop_music()
		Globals.change_screen(get_tree(),"ScreenTitleMenu")
	if selection != old_sel:
		update_selection()

func cloneText(orig):
	var inst = bitmap.instance()
	inst.text = orig.text
	inst.wrap_at = orig.wrap_at
	inst.scale_by = orig.scale_by
	inst.modulate = orig.modulate
	return inst
