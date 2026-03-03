extends Node2D


export (String) var custom_music_name
export (String) var nsf_music_file
export (int) var nsf_track_num = 0
export (float,-8.0,8.0,.1) var nsf_volume_adjustment = 0.0
export (bool) var mute_music_in_debug=false
export (bool) var mute_boss_music_in_debug=false

var reinaAudioPlayer

func _ready():
	if CheckpointPlayerStats.lastPlayedStage != 100:
		CheckpointPlayerStats.watchedBossIntro = false
		CheckpointPlayerStats.lastPlayedStage = 100
		
	get_tree().set_screen_stretch(SceneTree.STRETCH_MODE_2D,SceneTree.STRETCH_ASPECT_KEEP,Vector2(1280,720))
	Input.set_mouse_mode(Input.MOUSE_MODE_HIDDEN)
	
	reinaAudioPlayer = ReinaAudioPlayer.new(self)
	#playMusic_2()
	
	
	var player = get_player()
	player.set_physics_process(false)
	#Godot is very annoying so it's easier to keep FadeIn visible
	#by default and then set the camera to the player
	var tw = create_tween()
	tw.tween_property($GameplayLayer/Boss,"visible",false,0.0)
	tw.tween_callback($Camera2D,"make_current")
	tw.tween_property($FadeIn/ColorRect,"color:a",0.0,0.5).from(1.0)
	tw.tween_property($FadeIn/ColorRect,"visible",false,0.0)
	
	tw.tween_property(player,"position:y",432.0,.5).set_trans(Tween.TRANS_QUAD).from(-100.0)
	tw.tween_callback($"WARNING intro","run_event",[$GameplayLayer/Player])
	tw.tween_callback(player,"set_physics_process",[true])

func playBossMusic():
	if OS.is_debug_build() and mute_boss_music_in_debug:
		return
	print("playing boss music")
	reinaAudioPlayer.load_song(custom_music_name,nsf_music_file,nsf_track_num,nsf_volume_adjustment)

#This is only ever used for the boss doors honestly
func fadeMusic(time:float=2):
	print("Got FadeMusic command")
	reinaAudioPlayer.fade_music(time)
	#var seq := get_tree().create_tween()

		#$AudioStreamPlayer.stop()
		
func stopMusic():
	reinaAudioPlayer.stop_music()

func get_player():
	return $GameplayLayer/Player
