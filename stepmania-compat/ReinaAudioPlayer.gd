class_name ReinaAudioPlayer

var node:Node;
var audioStreamPlayer;
var nsf_player
var added_nsf_player:bool=false
#var is_fading_music:bool=false

func _init(_node:Node):
	node = _node;
	audioStreamPlayer=node.get_node("AudioStreamPlayer")
	#Remember to comment this out at some point...
	if false:
		var gs = load("res://greenStripe.tscn")
		node.add_child(gs.instance())

func load_song(custom_music_name:String, nsf_music_file:String, nsf_track_num:int,nsf_volume_adjustment:float=0):
	#return
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
		if !is_instance_valid(nsf_player):
			print("The NSF player has expired somehow... Trying to re-init")
			nsf_player = FLMusicLib.new();
			nsf_player.set_gme_buffer_size(2048*5);#optional
			
		nsf_player = nsf_player
		if !added_nsf_player:
			print("adding NSF player")
			node.add_child(nsf_player);
			nsf_player.set_pause_mode(2) #Node.PAUSE_MODE_PROCESS
			added_nsf_player=true
		#print(NSF_location+nsf_music_file)
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
	
# warning-ignore:unreachable_code
	if added_nsf_player:
		#nsf_player.stop_music()
		#print("Stopped NSF player")
		var t := Tween.new()
		node.add_child(t)
		t.set_pause_mode(2) #Node.PAUSE_MODE_PROCESS
		#var realVolumeLevel = OPTIONS['AudioVolume']['value']*.3-30
		t.interpolate_method(nsf_player,"set_volume",0,-15.0,time)
		t.start()
		yield(t,"tween_completed")
		nsf_player.stop_music()
		#nsf_player.set_volume(realVolumeLevel)
		#seq.tween_property(nsf_player,"toDraw",CONST_IMG_WIDTH,2).set_trans(Tween.TRANS_QUAD).set_ease(Tween.EASE_OUT)
	elif audioStreamPlayer.is_playing():
		var seq := node.get_tree().create_tween()
		seq.set_pause_mode(SceneTreeTween.TWEEN_PAUSE_PROCESS)
		seq.tween_property(audioStreamPlayer,"volume_db",-10,time).set_trans(Tween.TRANS_LINEAR).set_ease(Tween.EASE_OUT)
# warning-ignore:return_value_discarded
		seq.tween_callback(audioStreamPlayer,"stop")
		
func stop_music():
	#return
	#print("Stopping ReinaAudioPlayer")
	if added_nsf_player and is_instance_valid(nsf_player):
		#print("Stopped NSF")
		nsf_player.stop_music()
	else:
		#print("Stopped CDAudio")
		audioStreamPlayer.stop()
		
func pause_music():
	pass
