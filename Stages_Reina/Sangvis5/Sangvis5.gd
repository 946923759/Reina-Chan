extends Node2D


export (String) var custom_music_name
export (String) var nsf_music_file
export (int) var nsf_track_num = 0
export (float,-8.0,8.0,.1) var nsf_volume_adjustment = 0.0
export (bool) var mute_music_in_debug=false
export (bool) var mute_boss_music_in_debug=false
export (bool) var skip_boss_intro_in_debug=false
export (bool) var mute_announcer_in_debug=false

var reinaAudioPlayer

func _ready():
	#We don't enter this stage normally so it has to be manually reset
	if CheckpointPlayerStats.lastPlayedStage != 100:
		CheckpointPlayerStats.watchedBossIntro = false 
		CheckpointPlayerStats.lastPlayedStage = 100
	if skip_boss_intro_in_debug and OS.is_debug_build():
		CheckpointPlayerStats.watchedBossIntro = true
	if mute_announcer_in_debug and OS.is_debug_build():
		get_node("WARNING intro/FinalRound").volume_db = -INF
	
	Globals.previous_screen = "SF_5"
		
	#Also manually reset this
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
	#Why is this here? It will break skipping the intro.
	#tw.tween_callback(player,"set_physics_process",[true])

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
func stop_music():
	reinaAudioPlayer.stop_music()

func get_player():
	return $GameplayLayer/Player

func finish_stage():
	#is_timer_stopped=true
	#CheckpointPlayerStats.setDeathTimer(timerWithDeath)
	#CheckpointPlayerStats.setTimer(timer)
	#get_player().lockMovement(999,Vector2(),false)
	#invincible=true
	#invincibleTime=9999
	stopMusic()
	#THIS WILL CRASH THE GAME!!!!
	#if is_instance_valid(Globals.nsf_player):
	#	Globals.nsf_player.queue_free()
	
	#$VictorySound.play()
# warning-ignore:return_value_discarded
	#$VictorySound.connect("finished",self,"finishStage_2")
	
	var nextScene = "ScreenEnding"
	Globals.save_player_game()
	
	var tween = create_tween()
	$FadeIn/ColorRect.color = Color.white
	tween.tween_property($FadeIn/ColorRect,"visible",true,0.0).set_delay(1.0)
	tween.tween_property($FadeIn/ColorRect,"color:a",1.0,0.5).from(0.0)
	tween.tween_callback(Globals,"change_screen",[get_tree(),nextScene]).set_delay(1.0)

func shake_camera(amount:float):
	$Camera2D.shake_camera(amount)


func _on_UIElements_timer_expired():
	get_player().die()
